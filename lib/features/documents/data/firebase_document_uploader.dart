import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../application/documents_controller.dart';

class FirebaseDocumentUploader implements DocumentUploader {
  FirebaseDocumentUploader({
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    DateTime Function()? now,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _now = now ?? DateTime.now;

  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final DateTime Function() _now;

  @override
  Future<UploadedDocumentFile> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'A signed-in Firebase user is required to upload documents',
      );
    }

    final uploaded = buildCoursePdfUploadMetadata(
      firebaseUid: user.uid,
      subjectId: subjectId,
      fileName: fileName,
      now: _now,
    );
    final ref = _storage.ref().child(uploaded.storagePath);

    await ref.putData(bytes, SettableMetadata(contentType: 'application/pdf'));

    return uploaded;
  }
}

UploadedDocumentFile buildCoursePdfUploadMetadata({
  required String firebaseUid,
  required String subjectId,
  required String fileName,
  DateTime Function()? now,
}) {
  const maxFileNameLength = 255;
  const maxStoragePathLength = 512;

  final storageOwnerId = _validateStorageOwnerId(firebaseUid);
  final canonicalSubjectId = _validateSubjectId(subjectId);
  final safeBaseName = _sanitizeFileName(fileName);
  final timestamp = (now ?? DateTime.now)().millisecondsSinceEpoch.toString();
  final prefix = '$timestamp-';
  final maxBaseNameLength = maxFileNameLength - prefix.length;

  if (maxBaseNameLength < 1) {
    throw ArgumentError('Document file name is too long');
  }

  final finalFileName =
      '$prefix${_truncateFileName(safeBaseName, maxBaseNameLength)}';
  _validateFinalFileName(finalFileName);

  final storagePath =
      'students/$storageOwnerId/subjects/$canonicalSubjectId/$finalFileName';

  if (storagePath.length > maxStoragePathLength) {
    throw ArgumentError('Document storage path is too long');
  }

  return UploadedDocumentFile(
    fileName: finalFileName,
    storagePath: storagePath,
    mimeType: 'application/pdf',
  );
}

String _validateStorageOwnerId(String value) {
  final trimmed = value.trim();

  if (!_isCanonicalSegment(trimmed, allowDots: true)) {
    throw ArgumentError('Firebase uid must be canonical');
  }

  return trimmed;
}

String _validateSubjectId(String value) {
  final trimmed = value.trim();

  if (!_isCanonicalSegment(trimmed, allowDots: false)) {
    throw ArgumentError('Document subjectId must be canonical');
  }

  return trimmed;
}

bool _isCanonicalSegment(String value, {required bool allowDots}) {
  if (value.isEmpty ||
      value == '.' ||
      value == '..' ||
      value.contains('/') ||
      value.contains(r'\') ||
      value.contains('%')) {
    return false;
  }

  return allowDots || !value.contains('.');
}

String _sanitizeFileName(String fileName) {
  final trimmed = fileName.trim();

  if (trimmed.contains('/') ||
      trimmed.contains(r'\') ||
      trimmed.contains('%')) {
    throw ArgumentError('Document file name must be canonical');
  }

  final safeName = trimmed.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

  if (safeName.isEmpty || safeName == '.' || safeName == '..') {
    throw ArgumentError('Document file name must be canonical');
  }

  return safeName;
}

String _truncateFileName(String fileName, int maxLength) {
  if (fileName.length <= maxLength) {
    return fileName;
  }

  final extensionStart = fileName.lastIndexOf('.');
  final hasExtension =
      extensionStart > 0 && extensionStart < fileName.length - 1;

  if (!hasExtension) {
    return fileName.substring(0, maxLength);
  }

  final extension = fileName.substring(extensionStart);

  if (extension.length >= maxLength) {
    return fileName.substring(0, maxLength);
  }

  final baseLength = maxLength - extension.length;
  return '${fileName.substring(0, baseLength)}$extension';
}

void _validateFinalFileName(String fileName) {
  if (fileName.isEmpty ||
      fileName == '.' ||
      fileName == '..' ||
      fileName.length > 255 ||
      fileName.contains('/') ||
      fileName.contains(r'\') ||
      fileName.contains('%')) {
    throw ArgumentError('Document file name must be canonical');
  }
}
