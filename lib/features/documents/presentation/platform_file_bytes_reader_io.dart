import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<Uint8List> readPlatformFileBytes(PlatformFile file) {
  final bytes = file.bytes;

  if (bytes != null) {
    return Future.value(bytes);
  }

  final path = file.path;

  if (path == null || path.isEmpty) {
    throw StateError('Selected document path is unavailable');
  }

  return File(path).readAsBytes();
}
