import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../app/app_services.dart';
import '../../core/capabilities.dart';

/// Saves a copy of a backup, export or summary where the person can find it
/// (M002, G-68). On phones the app's own folder is private, so the system
/// "save as" dialog lets the person pick Downloads, a cloud folder or a USB
/// drive; nothing is sent anywhere by the app itself.
abstract interface class SaveCopy {
  /// False when the person cancelled.
  Future<bool> save({
    required String fileName,
    required String text,
    required String mimeType,
    required String title,
  });
}

class SystemSaveCopy implements SaveCopy {
  const SystemSaveCopy();

  @override
  Future<bool> save({
    required String fileName,
    required String text,
    required String mimeType,
    required String title,
  }) async {
    final where = await FilePicker.saveFile(
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(text)),
      mimeType: mimeType,
      dialogTitle: title,
    );
    return where != null;
  }
}

/// Phones only: desktop builds already save into a folder the person can
/// open (G-68 is about the app-private folder).
SaveCopy? saveCopyFor(AppServices s) =>
    s.saveCopy ??
    (s.registry.platform == HostPlatform.android ||
            s.registry.platform == HostPlatform.ios
        ? const SystemSaveCopy()
        : null);

/// A file just saved inside the app that may be copied out.
typedef Copyable = ({String name, String text, String mime});
