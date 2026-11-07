/// Picks the appearance store for the platform at compile time.
library;

export 'appearance_store_io.dart'
    if (dart.library.js_interop) 'appearance_store_web.dart';
