/// The vault gate (ladder F006): before a staging, production or portable
/// build shows anything, the encrypted vault is created, unlocked or
/// recovered, or the user keeps the session in memory only. Every path is
/// explained without false promises (v0.24 key loss, DR-09).
library;

import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../app/bootstrap.dart';
import '../../core/redact.dart';
import '../../data/crypto/recovery_key.dart';
import '../../data/crypto/vault_crypto.dart' show CryptoFailure;
import '../../data/local/encrypted_vault.dart';
import '../../data/local/vault_envelope.dart' show VaultEnvelopeError;
import '../../domain/ports/storage_status.dart';
import '../../l10n/strings.dart';

enum _Mode { create, recoveryKey, unlock, recover, keyLost, unreadable }

class VaultGateScreen extends StatefulWidget {
  const VaultGateScreen({super.key, required this.gate, required this.onReady});

  final VaultGate gate;

  /// Called once with the app's services (vault opened, or memory only).
  final void Function(AppServices services) onReady;

  @override
  State<VaultGateScreen> createState() => _VaultGateScreenState();
}

class _VaultGateScreenState extends State<VaultGateScreen> {
  late _Mode _mode;
  String? _unreadableCode;
  bool _busy = false;
  String? _error;
  String? _keptAt;
  bool _obscure = true;

  /// Held only between "Continue" and "Create": the recovery key is shown
  /// once, then both are dropped.
  String? _newPassphrase;
  String? _recoveryKey;
  bool _keyWrittenDown = false;

  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _key = TextEditingController();

  /// The passphrase field; it gets the focus back after a wrong try.
  final _passFocus = FocusNode();

  EncryptedVault get _vault => widget.gate.vault;

  @override
  void initState() {
    super.initState();
    final i = widget.gate.inspection;
    _mode = switch (i.access) {
      VaultAccess.create => _Mode.create,
      VaultAccess.unlock => _Mode.unlock,
      VaultAccess.unreadable => _Mode.unreadable,
    };
    _unreadableCode = i.code;
  }

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    _key.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _go(_Mode mode) => setState(() {
    _mode = mode;
    _error = null;
    _pass.clear();
    _confirm.clear();
    _key.clear();
    _obscure = true;
    if (mode != _Mode.recoveryKey) {
      _newPassphrase = null;
      _recoveryKey = null;
      _keyWrittenDown = false;
    }
  });

  /// Checks a new passphrase and its repetition; returns the error text.
  String? _checkNew(S s) {
    if (!passphraseLongEnough(_pass.text)) {
      return s.passphraseTooShort(minPassphraseLength);
    }
    if (_pass.text != _confirm.text) return s.passphrasesDiffer;
    return null;
  }

  Future<void> _run(
    Future<AppServices> Function() action,
    S s, {
    String? wrongSecret,
  }) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final services = await action();
      _newPassphrase = null;
      _recoveryKey = null;
      _pass.clear();
      _confirm.clear();
      _key.clear();
      if (mounted) widget.onReady(services);
      return;
    } on CryptoFailure catch (e) {
      final wrong = e.code == 'NOT_AUTHENTIC' && wrongSecret != null;
      _error = wrong ? wrongSecret : s.gateFailed(e.code);
      // A wrong passphrase is cleared so the next try starts empty; a wrong
      // recovery key stays, so a typo in it can be fixed.
      if (wrong && _mode == _Mode.unlock) {
        _pass.clear();
        // Some platforms drop the field's focus while the key is derived;
        // give it back so the next try can be typed at once.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _passFocus.requestFocus();
        });
      }
    } on RecoveryKeyFormatError {
      _error = s.recoveryKeyFormat;
    } on VaultEnvelopeError catch (e) {
      if (e.code == 'VAULT_EXISTS') {
        // Another start created a vault meanwhile: it is never overwritten.
        _go(_Mode.unlock);
      } else {
        _unreadableCode = e.code;
        _mode = _Mode.unreadable;
      }
    } catch (e) {
      logEvent('vault_gate_failed', error: e);
      _error = s.gateFailed(errorCode(e) ?? e.runtimeType.toString());
    }
    if (mounted) setState(() => _busy = false);
  }

  void _memoryOnly(S s) {
    final unreadable = _mode == _Mode.unreadable;
    _run(
      () => widget.gate.memoryOnly(
        unreadable ? StorageReason.vaultUnreadable : StorageReason.sessionOnly,
        detail: unreadable
            ? _unreadableCode
            : (widget.gate.inspection.access == VaultAccess.unlock &&
                      _keptAt == null
                  ? 'LOCKED_VAULT_KEPT'
                  : null),
      ),
      s,
    );
  }

  Future<void> _startNew(S s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.startNewTitle),
        content: Text(s.startNewBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            key: const ValueKey('confirm-start-new'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(s.startNewVault),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final kept = await _vault.setAside();
      _keptAt = kept;
      _go(_Mode.create);
    } catch (e) {
      logEvent('vault_set_aside_failed', error: e);
      _error = s.gateFailed(errorCode(e) ?? e.runtimeType.toString());
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _field(
    TextEditingController c,
    String label, {
    required String key,
    bool secret = true,
    bool newSecret = false,
    bool toggle = false,
    FocusNode? focusNode,
    VoidCallback? onSubmit,
  }) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextField(
      key: ValueKey(key),
      controller: c,
      focusNode: focusNode,
      // Read-only (not disabled) while a key is derived: the field keeps
      // its focus, so after a wrong passphrase the user can type again
      // without clicking back into it.
      readOnly: _busy,
      obscureText: secret && _obscure,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: secret ? TextInputType.visiblePassword : TextInputType.text,
      textCapitalization: secret
          ? TextCapitalization.none
          : TextCapitalization.characters,
      autofillHints: secret
          ? [newSecret ? AutofillHints.newPassword : AutofillHints.password]
          : null,
      onSubmitted: onSubmit == null ? null : (_) => onSubmit(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: toggle
            ? IconButton(
                key: ValueKey('$key-show'),
                tooltip: S.of(context).showPassphrase,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    ),
  );

  List<Widget> _create(S s, TextTheme text) {
    void next() {
      final problem = _checkNew(s);
      if (problem != null) {
        setState(() => _error = problem);
        return;
      }
      final pass = _pass.text;
      _go(_Mode.recoveryKey);
      setState(() {
        _newPassphrase = pass;
        _recoveryKey = newRecoveryKey();
      });
    }

    return [
      _title(s.gateCreateTitle, text),
      Text(s.gateCreateBody, style: text.bodyLarge),
      if (_keptAt != null) ...[
        const SizedBox(height: 8),
        Text(
          s.vaultKeptAt(_keptAt!),
          key: const ValueKey('gate-kept-at'),
          style: text.bodyMedium,
        ),
      ],
      _field(
        _pass,
        s.passphrase,
        key: 'gate-passphrase',
        newSecret: true,
        toggle: true,
      ),
      _field(
        _confirm,
        s.passphraseRepeat,
        key: 'gate-passphrase-confirm',
        newSecret: true,
        onSubmit: next,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          s.passphraseHint(minPassphraseLength),
          style: text.bodySmall,
        ),
      ),
      _errorText(text),
      _primary(s.gateContinue, 'gate-continue', next),
      _secondary(s.gateMemoryOnly, 'gate-memory-only', () => _memoryOnly(s)),
    ];
  }

  List<Widget> _showRecoveryKey(S s, TextTheme text) => [
    _title(s.recoveryKeyTitle, text),
    Text(s.recoveryKeyBody, style: text.bodyLarge),
    const SizedBox(height: 16),
    SelectableText(
      _recoveryKey ?? '',
      key: const ValueKey('gate-recovery-key'),
      style: text.titleMedium?.copyWith(
        fontFamily: 'monospace',
        letterSpacing: 1.2,
      ),
    ),
    const SizedBox(height: 8),
    CheckboxListTile(
      key: const ValueKey('gate-key-written'),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: _keyWrittenDown,
      onChanged: _busy
          ? null
          : (v) => setState(() => _keyWrittenDown = v ?? false),
      title: Text(s.recoveryKeySaved),
    ),
    _errorText(text),
    _primary(
      s.createVault,
      'gate-create-vault',
      _keyWrittenDown
          ? () => _run(
              () async => widget.gate.open(
                await _vault.create(
                  passphrase: _newPassphrase!,
                  recoveryKey: _recoveryKey!,
                ),
              ),
              s,
            )
          : null,
    ),
    _secondary(s.gateBack, 'gate-back', () => _go(_Mode.create)),
  ];

  List<Widget> _unlock(S s, TextTheme text) {
    void go() => _run(
      () async => widget.gate.open(await _vault.unlock(_pass.text)),
      s,
      wrongSecret: s.wrongPassphrase,
    );
    return [
      _title(s.unlockTitle, text),
      Text(s.unlockBody, style: text.bodyLarge),
      _field(
        _pass,
        s.passphrase,
        key: 'gate-passphrase',
        toggle: true,
        focusNode: _passFocus,
        onSubmit: go,
      ),
      _errorText(text),
      _primary(s.unlock, 'gate-unlock', go),
      _secondary(s.useRecoveryKey, 'gate-use-recovery', () {
        _go(_Mode.recover);
      }),
      _secondary(s.gateMemoryOnly, 'gate-memory-only', () => _memoryOnly(s)),
    ];
  }

  List<Widget> _recover(S s, TextTheme text) {
    void go() {
      final problem = _checkNew(s);
      if (problem != null) {
        setState(() => _error = problem);
        return;
      }
      _run(
        () async => widget.gate.open(
          await _vault.recover(
            recoveryKey: _key.text,
            newPassphrase: _pass.text,
          ),
        ),
        s,
        wrongSecret: s.wrongRecoveryKey,
      );
    }

    return [
      _title(s.recoverTitle, text),
      Text(s.recoverBody, style: text.bodyLarge),
      _field(
        _key,
        s.recoveryKeyLabel,
        key: 'gate-recovery-input',
        secret: false,
      ),
      _field(
        _pass,
        s.newPassphrase,
        key: 'gate-passphrase',
        newSecret: true,
        toggle: true,
      ),
      _field(
        _confirm,
        s.newPassphraseRepeat,
        key: 'gate-passphrase-confirm',
        newSecret: true,
        onSubmit: go,
      ),
      _errorText(text),
      _primary(s.recoverButton, 'gate-recover', go),
      _secondary(s.backToUnlock, 'gate-back', () => _go(_Mode.unlock)),
      _secondary(s.lostBoth, 'gate-lost-both', () => _go(_Mode.keyLost)),
    ];
  }

  List<Widget> _keyLost(S s, TextTheme text) => [
    _title(s.keyLostTitle, text),
    Text(s.keyLostBody, style: text.bodyLarge),
    _errorText(text),
    _secondary(s.backToUnlock, 'gate-back', () => _go(_Mode.unlock)),
    _secondary(s.gateMemoryOnly, 'gate-memory-only', () => _memoryOnly(s)),
    if (_vault.canSetAside)
      _secondary(s.startNewVault, 'gate-start-new', () => _startNew(s)),
  ];

  List<Widget> _unreadable(S s, TextTheme text) {
    final code = _unreadableCode ?? 'ENVELOPE_UNREADABLE';
    return [
      _title(s.unreadableTitle, text),
      Text(
        s.unreadableBody(code),
        key: const ValueKey('gate-unreadable-body'),
        style: text.bodyLarge,
      ),
      _errorText(text),
      _secondary(s.gateMemoryOnly, 'gate-memory-only', () => _memoryOnly(s)),
      // A newer vault is the user's data for a newer app: never set aside.
      if (_vault.canSetAside && code != 'ENVELOPE_NEWER')
        _secondary(s.startNewVault, 'gate-start-new', () => _startNew(s)),
    ];
  }

  Widget _title(String t, TextTheme text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        const Icon(Icons.lock_outline),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(t, style: text.headlineSmall),
          ),
        ),
      ],
    ),
  );

  Widget _errorText(TextTheme text) => _error == null
      ? const SizedBox(height: 12)
      : Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              key: const ValueKey('gate-error'),
              style: text.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        );

  Widget _primary(String label, String key, VoidCallback? onPressed) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: FilledButton(
      key: ValueKey(key),
      onPressed: _busy ? null : onPressed,
      child: Text(label),
    ),
  );

  Widget _secondary(String label, String key, VoidCallback onPressed) =>
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: TextButton(
          key: ValueKey(key),
          onPressed: _busy ? null : onPressed,
          child: Text(label, textAlign: TextAlign.center),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final children = switch (_mode) {
      _Mode.create => _create(s, text),
      _Mode.recoveryKey => _showRecoveryKey(s, text),
      _Mode.unlock => _unlock(s, text),
      _Mode.recover => _recover(s, text),
      _Mode.keyLost => _keyLost(s, text),
      _Mode.unreadable => _unreadable(s, text),
    };
    return Scaffold(
      key: ValueKey('vault-gate-${_mode.name}'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ...children,
                if (_busy) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    s.derivingKey,
                    key: const ValueKey('gate-working'),
                    style: text.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
