/// The browser build has no gzip stream reader; a .gz file is refused with
/// a request to unpack it first.
Stream<List<int>> gunzipStream(Stream<List<int>> bytes) =>
    throw UnsupportedError('gzip');

const bool canGunzip = false;
