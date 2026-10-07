/// Web adapter: a backup or export is handed to the browser as a download
/// (a local Blob; nothing leaves the device). Restoring needs a file chooser
/// and is not built for the browser yet.
library;

import 'dart:js_interop';

import 'backup_bundle.dart';
import 'data_files.dart';

extension type _BlobOptions._(JSObject _) implements JSObject {
  external factory _BlobOptions({JSString type});
}

@JS('Blob')
extension type _Blob._(JSObject _) implements JSObject {
  external factory _Blob(JSArray<JSString> parts, _BlobOptions options);
}

@JS('URL.createObjectURL')
external JSString _createObjectUrl(_Blob blob);

@JS('URL.revokeObjectURL')
external void _revokeObjectUrl(JSString url);

extension type _Anchor._(JSObject _) implements JSObject {
  external set href(JSString value);
  external set download(JSString value);
  external void click();
}

@JS('document.createElement')
external _Anchor _createElement(JSString tag);

class BrowserDataFiles implements DataFiles {
  @override
  bool get canRestore => false;

  @override
  Future<String> save(DataFileKind kind, String fileName, String text) async {
    final blob = _Blob(
      [text.toJS].toJS,
      _BlobOptions(type: 'application/json'.toJS),
    );
    final url = _createObjectUrl(blob);
    final a = _createElement('a'.toJS)
      ..href = url
      ..download = fileName.toJS;
    a.click();
    _revokeObjectUrl(url);
    return 'browser download ($fileName)';
  }

  @override
  Future<List<SavedFile>> backups() async => const [];

  @override
  Future<String> read(SavedFile file) =>
      throw UnsupportedError('Restoring in the browser is not built yet');

  @override
  Future<RestoreOutcome> restore(
    StagedRestore staged, {
    required DateTime now,
  }) => throw UnsupportedError('Restoring in the browser is not built yet');
}
