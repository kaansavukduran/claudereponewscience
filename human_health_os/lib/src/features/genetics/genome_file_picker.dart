import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// A file the person chose, read only when asked.
class PickedGenomeFile {
  const PickedGenomeFile({
    required this.name,
    required this.read,
    this.openRead,
  });

  final String name;
  final Future<Uint8List> Function() read;

  /// The file as a stream, for files too large to hold at once (ClinVar);
  /// null when the platform gives bytes only.
  final Stream<List<int>> Function()? openRead;
}

/// Chooses a file for the genetics screen. Behind an interface so tests and
/// the browser smoke need no native dialog (G001, D-021).
abstract interface class GenomeFilePicker {
  /// Null when the person cancelled.
  Future<PickedGenomeFile?> pick({required String title});

  /// Drops any copy the chooser made (mobile choosers copy a file to a cache
  /// folder). Called after a file was read.
  Future<void> release();
}

/// The system's file dialog. No extension filter: a name is not trusted, the
/// content is checked by the reader.
class SystemGenomeFilePicker implements GenomeFilePicker {
  const SystemGenomeFilePicker();

  @override
  Future<PickedGenomeFile?> pick({required String title}) async {
    final f = await FilePicker.pickFile(dialogTitle: title);
    if (f == null) return null;
    return PickedGenomeFile(
      name: f.name,
      read: f.readAsBytes,
      openRead: f.readAsByteStream,
    );
  }

  @override
  Future<void> release() async {
    try {
      await FilePicker.clearTemporaryFiles();
    } catch (_) {
      // Nothing to clear on this platform.
    }
  }
}
