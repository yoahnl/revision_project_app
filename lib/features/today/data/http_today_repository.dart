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
    final primaryItemId = json['primaryItemId'];
    final continuationItemIds = json['continuationItemIds'];
    final weeklyObjective = json['weeklyObjective'];
    final emptyState = json['emptyState'];

    if (generatedAt is! String ||
        items is! List ||
        (primaryItemId != null && primaryItemId is! String)) {
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
      primaryItemId: _trimOptionalString(primaryItemId as String?),
      continuationItemIds: _parseStringList(continuationItemIds),
      weeklyObjective: _TodayWeeklyObjectiveJson(weeklyObjective).toObjective(),
      emptyState: _TodayEmptyStateJson(emptyState).toEmptyState(),
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
    final role = json['role'];
    final display = json['display'];

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
        reason is! String ||
        (role != null && role is! String)) {
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
      role: role == null ? null : _parseRole(role as String),
      display: _TodayPlanItemDisplayJson(display).toDisplay(),
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

  TodayPlanItemRole _parseRole(String value) {
    return switch (value) {
      'PRIMARY' => TodayPlanItemRole.primary,
      'CONTINUATION' => TodayPlanItemRole.continuation,
      _ => throw const FormatException('Invalid today item role'),
    };
  }
}

class _TodayPlanItemDisplayJson {
  const _TodayPlanItemDisplayJson(this.value);

  final Object? value;

  TodayPlanItemDisplay? toDisplay() {
    final json = value;
    if (json == null) {
      return null;
    }

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid today item display');
    }

    final title = json['title'];
    final subjectLabel = json['subjectLabel'];
    final badgeLabel = json['badgeLabel'];
    final durationLabel = json['durationLabel'];
    final metaLabel = json['metaLabel'];
    final recommendation = json['recommendation'];
    final actionLabel = json['actionLabel'];
    final unavailableReason = json['unavailableReason'];

    if (title is! String ||
        subjectLabel is! String ||
        badgeLabel is! String ||
        (durationLabel != null && durationLabel is! String) ||
        metaLabel is! String ||
        recommendation is! String ||
        actionLabel is! String ||
        (unavailableReason != null && unavailableReason is! String)) {
      throw const FormatException('Invalid today item display');
    }

    return TodayPlanItemDisplay(
      title: title,
      subjectLabel: subjectLabel,
      badgeLabel: badgeLabel,
      durationLabel: _trimOptionalString(durationLabel as String?),
      metaLabel: metaLabel,
      recommendation: recommendation,
      actionLabel: actionLabel,
      unavailableReason: _trimOptionalString(unavailableReason as String?),
    );
  }
}

class _TodayWeeklyObjectiveJson {
  const _TodayWeeklyObjectiveJson(this.value);

  final Object? value;

  TodayWeeklyObjective? toObjective() {
    final json = value;
    if (json == null) {
      return null;
    }

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid today weekly objective');
    }

    final targetMinutes = json['targetMinutes'];
    final completedMinutes = json['completedMinutes'];
    final progressRatio = json['progressRatio'];
    final label = json['label'];
    final status = json['status'];

    if (targetMinutes is! int ||
        (completedMinutes != null && completedMinutes is! int) ||
        (progressRatio != null && progressRatio is! num) ||
        label is! String ||
        status is! String) {
      throw const FormatException('Invalid today weekly objective');
    }

    return TodayWeeklyObjective(
      targetMinutes: targetMinutes,
      completedMinutes: completedMinutes as int?,
      progressRatio: (progressRatio as num?)?.toDouble(),
      label: label,
      status: _parseStatus(status),
    );
  }

  TodayWeeklyObjectiveStatus _parseStatus(String value) {
    return switch (value) {
      'TARGET_ONLY' => TodayWeeklyObjectiveStatus.targetOnly,
      'PROGRESS_AVAILABLE' => TodayWeeklyObjectiveStatus.progressAvailable,
      _ => throw const FormatException('Invalid today weekly objective status'),
    };
  }
}

class _TodayEmptyStateJson {
  const _TodayEmptyStateJson(this.value);

  final Object? value;

  TodayEmptyState? toEmptyState() {
    final json = value;
    if (json == null) {
      return null;
    }

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid today empty state');
    }

    final title = json['title'];
    final message = json['message'];
    final actionLabel = json['actionLabel'];
    final actionKind = json['actionKind'];

    if (title is! String ||
        message is! String ||
        actionLabel is! String ||
        actionKind is! String) {
      throw const FormatException('Invalid today empty state');
    }

    return TodayEmptyState(
      title: title,
      message: message,
      actionLabel: actionLabel,
      actionKind: _parseActionKind(actionKind),
    );
  }

  TodayEmptyActionKind _parseActionKind(String value) {
    return switch (value) {
      'OPEN_COURSES' => TodayEmptyActionKind.openCourses,
      _ => throw const FormatException('Invalid today empty action kind'),
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

List<String> _parseStringList(Object? value) {
  if (value == null) {
    return const [];
  }

  if (value is! List) {
    throw const FormatException('Invalid today string list');
  }

  return value
      .map((item) {
        if (item is! String) {
          throw const FormatException('Invalid today string list');
        }

        return item;
      })
      .toList(growable: false);
}
