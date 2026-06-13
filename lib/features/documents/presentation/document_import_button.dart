import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../application/documents_controller.dart';
import 'platform_file_bytes_reader.dart';

typedef DocumentFilePicker = Future<FilePickerResult?> Function();

class DocumentImportButton extends StatefulWidget {
  const DocumentImportButton({
    required this.subjectId,
    required this.controller,
    this.pickFiles,
    this.onImported,
    super.key,
  });

  final String subjectId;
  final DocumentsController controller;
  final DocumentFilePicker? pickFiles;
  final VoidCallback? onImported;

  @override
  State<DocumentImportButton> createState() => _DocumentImportButtonState();
}

class _DocumentImportButtonState extends State<DocumentImportButton> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _isUploading ? null : _importDocument,
      icon: const Icon(Icons.upload_file),
      label: const Text('Importer un cours'),
    );
  }

  Future<void> _importDocument() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final result = await (widget.pickFiles ?? _pickPdf)();
      final file = result?.files.single;

      if (file == null) {
        return;
      }

      final bytes = await readPlatformFileBytes(file);

      await widget.controller.uploadCoursePdf(
        subjectId: widget.subjectId,
        fileName: file.name,
        bytes: bytes,
      );
      widget.onImported?.call();
    } catch (error, stackTrace) {
      debugPrint('Document import failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'importer le document")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<FilePickerResult?> _pickPdf() {
    return FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );
  }
}
