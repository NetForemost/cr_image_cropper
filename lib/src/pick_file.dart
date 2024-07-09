import 'package:file_picker/file_picker.dart';

/// Pick a file with [FilePicker]
Future<PlatformFile?> pickFile({
  FileType type = FileType.any,
  List<String>? allowedExtensions,
  bool allowCompression = true,
}) async {
  final result = await FilePicker.platform.pickFiles(
    type: type,
    allowedExtensions: allowedExtensions,
    allowCompression: allowCompression,
  );
  if (result != null && result.isSinglePick) {
    final file = result.files.single;
    final path = file.path;
    if (path != null) {
      return file;
    }
  }

  return null;
}
