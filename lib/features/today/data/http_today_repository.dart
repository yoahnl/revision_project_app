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

    final parsedGeneratedAt = DateTime.tryParse(generatedAt);
    if (parsedGeneratedAt == null) {
      throw const FormatException('Invalid today response');
    }

    return TodayPlan(
      generatedAt: parsedGeneratedAt,
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

    final id = json['id'];
    final subjectId = json['subjectId'];
    final subjectName = json['subjectName'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final knowledgeUnitTitle = json['knowledgeUnitTitle'];
    final masteryScore = json['masteryScore'];
    final action = json['action'];
    final estimatedMinutes = json['estimatedMinutes'];
    final priority = json['priority'];
    final reasonCode = json['reasonCode'];
    final reason = json['reason'];
    final startPayload = json['startPayload'];

    if (id is! String ||
        subjectId is! String ||
        subjectName is! String ||
        (documentId != null && documentId is! String) ||
        (knowledgeUnitId != null && knowledgeUnitId is! String) ||
        (knowledgeUnitTitle != null && knowledgeUnitTitle is! String) ||
        (masteryScore != null && masteryScore is! num) ||
        action is! String ||
        estimatedMinutes is! int ||
        priority is! int ||
        reasonCode is! String ||
        reason is! String) {
      throw const FormatException('Invalid today item response');
    }

    final parsedAction = _parseAction(action);
    final parsedDocumentId = documentId as String?;
    final parsedKnowledgeUnitId = knowledgeUnitId as String?;
    final parsedKnowledgeUnitTitle = knowledgeUnitTitle as String?;
    final parsedMasteryScore = masteryScore as num?;
    final parsedStartPayload = _TodayPlanStartPayloadJson(
      startPayload,
    ).toPayload();

    if (parsedAction == TodayPlanActionType.richClosedExercise &&
        (parsedKnowledgeUnitId == null ||
            parsedKnowledgeUnitId.trim().isEmpty ||
            parsedStartPayload.knowledgeUnitId == null ||
            parsedStartPayload.knowledgeUnitId!.trim().isEmpty)) {
      throw const FormatException('Invalid today rich closed action');
    }

    return TodayPlanItem(
      id: id,
      subjectId: subjectId,
      subjectName: subjectName,
      documentId: _trimOptionalString(parsedDocumentId),
      knowledgeUnitId: parsedKnowledgeUnitId,
      knowledgeUnitTitle: parsedKnowledgeUnitTitle,
      masteryScore: parsedMasteryScore?.toDouble(),
      action: parsedAction,
      estimatedMinutes: estimatedMinutes,
      priority: priority,
      reasonCode: _parseReasonCode(reasonCode),
      reason: reason,
      startPayload: parsedStartPayload,
    );
  }

  TodayPlanActionType _parseAction(String value) {
    return switch (value) {
      'diagnostic_quiz' => TodayPlanActionType.diagnosticQuiz,
      'open_question' => TodayPlanActionType.openQuestion,
      'rich_closed_exercise' => TodayPlanActionType.richClosedExercise,
      'revision_session' => TodayPlanActionType.revisionSession,
      _ => throw const FormatException('Invalid today action'),
    };
  }

  TodayPlanReasonCode _parseReasonCode(String value) {
    return switch (value) {
      'LOW_MASTERY' => TodayPlanReasonCode.lowMastery,
      'STALE_PRACTICE' => TodayPlanReasonCode.stalePractice,
      'HIGH_PRIORITY_SUBJECT' => TodayPlanReasonCode.highPrioritySubject,
      'MIX_ACTIVITY_TYPE' => TodayPlanReasonCode.mixActivityType,
      'RICH_CLOSED_PRACTICE' => TodayPlanReasonCode.richClosedPractice,
      'START_REVISION_SESSION' => TodayPlanReasonCode.startRevisionSession,
      'CONTINUE_PROGRESS' => TodayPlanReasonCode.continueProgress,
      _ => throw const FormatException('Invalid today reason code'),
    };
  }
}

class _TodayPlanStartPayloadJson {
  const _TodayPlanStartPayloadJson(this.value);

  final Object? value;

  TodayPlanStartPayload toPayload() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid today start payload');
    }

    final subjectId = json['subjectId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final preferredAction = json['preferredAction'];

    if (subjectId is! String ||
        subjectId.trim().isEmpty ||
        (documentId != null && documentId is! String) ||
        (knowledgeUnitId != null && knowledgeUnitId is! String) ||
        (preferredAction != null && preferredAction is! String)) {
      throw const FormatException('Invalid today start payload');
    }

    final parsedDocumentId = documentId as String?;
    final parsedKnowledgeUnitId = knowledgeUnitId as String?;
    final parsedPreferredAction = preferredAction as String?;

    return TodayPlanStartPayload(
      subjectId: subjectId.trim(),
      documentId: _trimOptionalString(parsedDocumentId),
      knowledgeUnitId: _trimOptionalString(parsedKnowledgeUnitId),
      preferredAction: parsedPreferredAction == null
          ? null
          : _parsePreferredAction(parsedPreferredAction),
    );
  }

  TodayPlanPreferredAction _parsePreferredAction(String value) {
    return switch (value) {
      'diagnostic_quiz' => TodayPlanPreferredAction.diagnosticQuiz,
      'open_question' => TodayPlanPreferredAction.openQuestion,
      _ => throw const FormatException('Invalid today preferred action'),
    };
  }
}

String? _trimOptionalString(String? value) {
  final trimmedValue = value?.trim();
  return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
}
