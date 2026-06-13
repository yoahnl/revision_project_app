import 'package:dio/dio.dart';

import '../application/auth_controller.dart';

typedef FirebaseIdTokenProvider = Future<String> Function();

class HttpStudentProfileBootstrapper implements AuthProfileBootstrapper {
  HttpStudentProfileBootstrapper({
    required String apiBaseUrl,
    required this.getIdToken,
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: apiBaseUrl));

  final Dio _dio;
  final FirebaseIdTokenProvider getIdToken;

  @override
  Future<void> bootstrapCurrentStudent() async {
    final token = (await getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required');
    }

    await _dio.get<void>(
      '/students/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
