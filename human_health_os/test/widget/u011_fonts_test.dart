// U011@v0.32: a reading font (device, Atkinson Hyperlegible Next, or
// OpenDyslexic) and wider spacing, one click each; the fonts are bundled,
// licensed (OFL) and cover Turkish letters.
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('choosing OpenDyslexic and wide spacing applies at once', (
    tester,
  ) async {
    final c = await launchWith(tester);
    await tapKey(tester, 'open-settings');
    await tapKey(tester, 'set-font-dyslexic');
    await tapKey(tester, 'set-wide-spacing');
    final ctx = tester.element(find.byKey(const ValueKey('screen-settings')));
    final body = Theme.of(ctx).textTheme.bodyMedium!;
    expect(body.fontFamily, 'OpenDyslexic');
    expect(body.letterSpacing, greaterThan(1));
    expect(body.height, 1.5);
    expect(c.value.font, FontChoice.dyslexic);
    await tapKey(tester, 'set-font-legible');
    expect(
      Theme.of(tester.element(find.byKey(const ValueKey('screen-settings'))))
          .textTheme
          .bodyMedium!
          .fontFamily,
      'AtkinsonHyperlegibleNext',
    );
  });

  test('font choices map to bundled families; the device font stays null', () {
    expect(fontFamilyFor(FontChoice.system), isNull);
    expect(fontFamilyFor(FontChoice.legible), 'AtkinsonHyperlegibleNext');
    expect(fontFamilyFor(FontChoice.dyslexic), 'OpenDyslexic');
    const s = AppearanceSettings(font: FontChoice.dyslexic, wideSpacing: true);
    expect(AppearanceSettings.fromJson(s.toJson()), s);
  });

  test('the bundled font files are the reviewed ones (D-025) and their '
      'licences sit beside them', () {
    const expected = {
      'OpenDyslexic-Regular.otf':
          '32f5840fb2bf844bdabafe372591ddfb9286e98117f5b21950aaf54ea856919a',
      'OpenDyslexic-Bold.otf':
          '5d690ea4c87ccb0d5d5d81487826a395e9b20a6c1d606f1f262c060d2bef4f03',
      'AtkinsonHyperlegibleNext-Regular.ttf':
          '88ed5c31a71584c7772963b02d04bef1eb7e3d2e9c8b9cb204339b1f82cf432c',
      'AtkinsonHyperlegibleNext-Bold.ttf':
          '994414047df66bb4998d01c1cb1eeb4a2ddc4622d1aa56bbb8adbeca7645b041',
    };
    expected.forEach((name, sha) {
      final bytes = File('assets/fonts/$name').readAsBytesSync();
      expect(sha256.convert(bytes).toString(), sha, reason: name);
    });
    for (final l in [
      'OpenDyslexic-OFL.txt',
      'AtkinsonHyperlegibleNext-OFL.txt',
    ]) {
      expect(
        File('assets/fonts/$l').readAsStringSync(),
        contains('SIL Open Font License'),
      );
    }
  });

  test('font words judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.settingsFont,
        s.fontLegible,
        s.fontDyslexic,
        s.settingsWideSpacing,
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
