import 'package:dio/dio.dart';

import '../application/today_controller.dart';
import '../domain/today_plan.dart';

class HttpTodayRepository implements TodayRepository {
  HttpTodayRepository({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpTodayRepository._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<TodayPlan> getTodayPlan() async {
    final response = await _dio.get<Object?>(
      '/today',
      options: await _authorizedOptions(),
    );

    return _TodayPlanJson(response.data).toPlan();
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required for today plan');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}

class _TodayPlanJson {
  const _TodayPlanJson(this.value);

  final Object? value;

  TodayPlan toPlan() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid today response');
    }

    final generatedAt = json['generatedAt'];
    final items = json['items'];

    if (generatedAt is! String || items is! List) {
      throw const FormatException('Invalid today response');
    }

    return TodayPlan(
      generatedAt: DateTime.parse(generatedAt),
      items: items
          .map((item) => _TodayPlanItemJson(item).toItem())
          .toList(growable: false),
    );
  }
}

class _TodayPlanItemJson {
  const _TodayPlanItemJson(this.value);

  final Object? value;

  TodayPlanItem toItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid today item response');
    }

    final subjectId = json['subjectId'];
    final subjectName = json['subjectName'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final knowledgeUnitTitle = json['knowledgeUnitTitle'];
    final masteryScore = json['masteryScore'];
    final action = json['action'];
    final estimatedMinutes = json['estimatedMinutes'];

    if (subjectId is! String ||
        subjectName is! String ||
        knowledgeUnitId is! String ||
        knowledgeUnitTitle is! String ||
        masteryScore is! num ||
        action is! String ||
        estimatedMinutes is! int) {
      throw const FormatException('Invalid today item response');
    }

    return TodayPlanItem(
      subjectId: subjectId,
      subjectName: subjectName,
      knowledgeUnitId: knowledgeUnitId,
      knowledgeUnitTitle: knowledgeUnitTitle,
      masteryScore: masteryScore.toDouble(),
      action: action,
      estimatedMinutes: estimatedMinutes,
    );
  }
}
