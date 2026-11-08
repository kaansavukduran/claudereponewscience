import 'dart:io';

/// Decompresses a .gz byte stream as it is read (no whole file in memory).
Stream<List<int>> gunzipStream(Stream<List<int>> bytes) =>
    bytes.transform(gzip.decoder);

const bool canGunzip = true;
