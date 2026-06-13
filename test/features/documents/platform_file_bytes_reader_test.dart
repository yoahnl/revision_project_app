import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/documents/presentation/platform_file_bytes_reader.dart';

void main() {
  test('reads selected file bytes from memory when available', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);

    final readBytes = await readPlatformFileBytes(
      PlatformFile(name: 'cours.pdf', size: bytes.length, bytes: bytes),
    );

    expect(readBytes, bytes);
  });

  test('reads selected file bytes from path when bytes are absent', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'revision-document-import-',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    final pickedFile = File('${tempDirectory.path}/cours.pdf');
    await pickedFile.writeAsBytes([4, 5, 6]);

    final readBytes = await readPlatformFileBytes(
      PlatformFile(name: 'cours.pdf', path: pickedFile.path, size: 3),
    );

    expect(readBytes, Uint8List.fromList([4, 5, 6]));
  });
}
