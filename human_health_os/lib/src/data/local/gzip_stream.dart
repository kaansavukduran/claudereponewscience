/// Picks the gzip reader for the platform at compile time.
library;

export 'gzip_stream_io.dart'
    if (dart.library.js_interop) 'gzip_stream_web.dart';
