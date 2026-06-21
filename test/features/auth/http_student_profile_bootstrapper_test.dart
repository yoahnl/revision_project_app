import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/auth/data/http_student_profile_bootstrapper.dart';

class CapturingHttpClientAdapter implements HttpClientAdapter {
  RequestOptions? capturedOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedOptions = options;

    return ResponseBody.fromString('', 200);
  }
}

void main() {
  test('calls /students/me with a Firebase bearer token', () async {
    final adapter = CapturingHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    final bootstrapper = HttpStudentProfileBootstrapper(
      apiBaseUrl: 'https://api.example.test',
      dio: dio,
      getIdToken: () async => ' firebase-id-token ',
    );

    await bootstrapper.bootstrapCurrentStudent();

    expect(adapter.capturedOptions?.path, '/students/me');
    expect(
      adapter.capturedOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('rejects blank tokens before calling the API', () async {
    final adapter = CapturingHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    final bootstrapper = HttpStudentProfileBootstrapper(
      apiBaseUrl: 'https://api.example.test',
      dio: dio,
      getIdToken: () async => '   ',
    );

    await expectLater(bootstrapper.bootstrapCurrentStudent(), throwsStateError);
    expect(adapter.capturedOptions, isNull);
  });
}
