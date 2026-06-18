import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PickedCoursePdf {
  const PickedCoursePdf({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

abstract interface class CoursePdfPicker {
  Future<PickedCoursePdf?> pickPdf();
}

final coursePdfPickerProvider = Provider<CoursePdfPicker>((ref) {
  return const FilePickerCoursePdfPicker();
});

class FilePickerCoursePdfPicker implements CoursePdfPicker {
  const FilePickerCoursePdfPicker();

  @override
  Future<PickedCoursePdf?> pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
      allowMultiple: false,
    );

    final file = result?.files.singleOrNull;
    final bytes = file?.bytes;

    if (file == null || bytes == null || bytes.isEmpty) {
      return null;
    }

    return PickedCoursePdf(fileName: file.name, bytes: bytes);
  }
}
