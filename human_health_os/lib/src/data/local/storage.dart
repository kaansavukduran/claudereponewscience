/// Picks the storage adapter for the current platform at compile time.
library;

export 'storage_io.dart' if (dart.library.js_interop) 'storage_web.dart';
