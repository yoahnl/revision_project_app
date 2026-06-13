import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../application/documents_controller.dart';
import '../domain/revision_document.dart';

class HttpDocumentsApi implements DocumentsApi {
  HttpDocumentsApi({
    required Dio dio,
    required Future<String?> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpDocumentsApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String?> Function() _getIdToken;

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final response = await _dio.post<Object?>(
      '/documents/course-pdf',
      data: FormData.fromMap({
        'subjectId': subjectId,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType('application', 'pdf'),
        ),
      }),
      options: await _authorizedOptions(
        'A Firebase ID token is required to upload documents',
      ),
    );

    return _DocumentJson(response.data).toDocument();
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    final response = await _dio.get<Object?>(
      '/subjects/$subjectId/documents',
      options: await _authorizedOptions(
        'A Firebase ID token is required to load documents',
      ),
    );
    final rawDocuments = response.data;

    if (rawDocuments is! List) {
      throw const FormatException('Invalid documents response');
    }

    return rawDocuments
        .map((document) => _DocumentJson(document).toDocument())
        .toList(growable: false);
  }

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    final response = await _dio.get<Object?>(
      '/documents/$documentId',
      options: await _authorizedOptions(
        'A Firebase ID token is required to load documents',
      ),
    );

    return _DocumentJson(response.data).toDocument();
  }

  Future<Options> _authorizedOptions(String missingTokenMessage) async {
    final token = (await _getIdToken())?.trim();

    if (token == null || token.isEmpty) {
      throw StateError(missingTokenMessage);
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}

class _DocumentJson {
  const _DocumentJson(this.value);

  final Object? value;

  RevisionDocument toDocument() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid document response');
    }

    final id = json['id'];
    final subjectId = json['subjectId'];
    final kind = json['kind'];
    final fileName = json['fileName'];
    final status = json['status'];
    final mimeType = json['mimeType'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        subjectId is! String ||
        kind is! String ||
        fileName is! String ||
        status is! String ||
        mimeType is! String ||
        (errorCode != null && errorCode is! String)) {
      throw const FormatException('Invalid document response');
    }

    return RevisionDocument(
      id: id,
      subjectId: subjectId,
      kind: kind,
      fileName: fileName,
      status: status,
      mimeType: mimeType,
      errorCode: errorCode as String?,
    );
  }
}
