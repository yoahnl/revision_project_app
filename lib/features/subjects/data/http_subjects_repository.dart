import 'package:dio/dio.dart';

import '../application/subjects_controller.dart';
import '../domain/subject.dart';

class HttpSubjectsRepository implements SubjectsRepository {
  HttpSubjectsRepository({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpSubjectsRepository._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<List<Subject>> listSubjects() async {
    final response = await _dio.get<Object?>(
      '/subjects',
      options: await _authorizedOptions(),
    );
    final rawSubjects = response.data;

    if (rawSubjects is! List) {
      throw const FormatException('Invalid subjects response');
    }

    return rawSubjects
        .map((subject) => _SubjectJson(subject).toSubject())
        .toList(growable: false);
  }

  @override
  Future<Subject> getSubject(String id) async {
    final response = await _dio.get<Object?>(
      '/subjects/$id',
      options: await _authorizedOptions(),
    );

    return _SubjectJson(response.data).toSubject();
  }

  @override
  Future<Subject> createSubject({
    required String name,
    required int priority,
    int weeklyMinutes = 0,
  }) async {
    final response = await _dio.post<Object?>(
      '/subjects',
      data: {'name': name, 'priority': priority},
      options: await _authorizedOptions(),
    );

    final subject = _SubjectJson(response.data).toSubject();

    return Subject(
      id: subject.id,
      name: subject.name,
      priority: subject.priority,
      weeklyMinutes: weeklyMinutes,
    );
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required to load subjects');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}

class _SubjectJson {
  const _SubjectJson(this.value);

  final Object? value;

  Subject toSubject() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid subject response');
    }

    final id = json['id'];
    final name = json['name'];
    final priority = json['priority'];
    final weeklyMinutes = json['weeklyMinutes'];

    if (id is! String || name is! String || priority is! int) {
      throw const FormatException('Invalid subject response');
    }

    return Subject(
      id: id,
      name: name,
      priority: priority,
      weeklyMinutes: weeklyMinutes is int ? weeklyMinutes : 0,
    );
  }
}
