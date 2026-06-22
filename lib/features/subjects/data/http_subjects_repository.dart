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
      '/subjects/${Uri.encodeComponent(id)}',
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

  @override
  Future<Subject> updateSubject({
    required String id,
    required String name,
    required int priority,
  }) async {
    try {
      final response = await _dio.patch<Object?>(
        '/subjects/${Uri.encodeComponent(id)}',
        data: {'name': name, 'priority': priority},
        options: await _authorizedOptions(),
      );

      return _SubjectJson(response.data).toSubject();
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        throw SubjectLifecycleBlockedException(
          _responseMessage(error) ?? 'Cette matière ne peut pas être modifiée.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<SubjectLifecycleDecision> getSubjectLifecycle(String id) async {
    final response = await _dio.get<Object?>(
      '/subjects/${Uri.encodeComponent(id)}/lifecycle',
      options: await _authorizedOptions(),
    );

    return _SubjectLifecycleDecisionJson(response.data).toDecision();
  }

  @override
  Future<SubjectLifecycleDecision> archiveSubject(String id) async {
    try {
      final response = await _dio.post<Object?>(
        '/subjects/${Uri.encodeComponent(id)}/archive',
        options: await _authorizedOptions(),
      );

      return _SubjectLifecycleDecisionJson(response.data).toDecision();
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        throw SubjectLifecycleBlockedException(
          _responseMessage(error) ?? 'Cette matière ne peut pas être archivée.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteSubject(String id) async {
    try {
      await _dio.delete<Object?>(
        '/subjects/${Uri.encodeComponent(id)}',
        options: await _authorizedOptions(),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        throw SubjectLifecycleBlockedException(
          _responseMessage(error) ??
              'Cette matière ne peut pas être supprimée.',
        );
      }
      rethrow;
    }
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required to load subjects');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String? _responseMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, Object?>) {
      final message = data['message'];
      if (message is String) {
        return message;
      }
    }

    return null;
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

class _SubjectLifecycleDecisionJson {
  const _SubjectLifecycleDecisionJson(this.value);

  final Object? value;

  SubjectLifecycleDecision toDecision() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid subject lifecycle response');
    }

    final subjectId = json['subjectId'];
    final status = json['status'];
    final action = json['recommendedAction'];
    final canDelete = json['canDelete'];
    final canArchive = json['canArchive'];
    final canUpdate = json['canUpdate'];
    final blockingReasons = json['blockingReasons'];
    final userMessage = json['userMessage'];

    if (subjectId is! String ||
        status is! String ||
        action is! String ||
        canDelete is! bool ||
        canArchive is! bool ||
        canUpdate is! bool ||
        blockingReasons is! List ||
        userMessage is! String) {
      throw const FormatException('Invalid subject lifecycle response');
    }

    return SubjectLifecycleDecision(
      subjectId: subjectId,
      status: _parseSubjectLifecycleStatus(status),
      recommendedAction: _parseSubjectLifecycleAction(action),
      canDelete: canDelete,
      canArchive: canArchive,
      canUpdate: canUpdate,
      blockingReasons: blockingReasons.whereType<String>().toList(),
      userMessage: userMessage,
    );
  }
}

SubjectLifecycleStatus _parseSubjectLifecycleStatus(String value) {
  return switch (value) {
    'ACTIVE' => SubjectLifecycleStatus.active,
    'ARCHIVED' => SubjectLifecycleStatus.archived,
    _ => throw const FormatException('Unknown subject lifecycle status'),
  };
}

SubjectLifecycleRecommendedAction _parseSubjectLifecycleAction(String value) {
  return switch (value) {
    'DELETE' => SubjectLifecycleRecommendedAction.delete,
    'ARCHIVE' => SubjectLifecycleRecommendedAction.archive,
    'BLOCK' => SubjectLifecycleRecommendedAction.block,
    _ => throw const FormatException('Unknown subject lifecycle action'),
  };
}
