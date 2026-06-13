import 'package:dio/dio.dart';

import '../application/revision_goals_controller.dart';
import '../domain/revision_goal.dart';

class HttpRevisionGoalsApi implements RevisionGoalsRepository {
  HttpRevisionGoalsApi({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpRevisionGoalsApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<void> saveRevisionGoal(RevisionGoal goal) async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required to save goals');
    }

    await _dio.post<void>(
      '/revision-goals',
      data: {
        'targetDate': goal.targetDate.toUtc().toIso8601String(),
        'weeklyMinutes': goal.weeklyMinutes,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
