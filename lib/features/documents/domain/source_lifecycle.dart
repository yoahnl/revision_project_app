enum SourceLifecycleStatus { active, archived, unknown }

enum SourceLifecycleAction { delete, archive, block, unknown }

class SourceLifecycleDecision {
  const SourceLifecycleDecision({
    required this.documentId,
    required this.courseId,
    required this.status,
    required this.recommendedAction,
    required this.canDelete,
    required this.canArchive,
    required this.blockingReasons,
    required this.userMessage,
  });

  final String documentId;
  final String? courseId;
  final SourceLifecycleStatus status;
  final SourceLifecycleAction recommendedAction;
  final bool canDelete;
  final bool canArchive;
  final List<String> blockingReasons;
  final String userMessage;
}

class SourceLifecycleDecisionJson {
  const SourceLifecycleDecisionJson(this.value);

  final Object? value;

  SourceLifecycleDecision toDecision() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid source lifecycle response');
    }

    final documentId = json['documentId'];
    final courseId = json['courseId'];
    final status = json['status'];
    final recommendedAction = json['recommendedAction'];
    final canDelete = json['canDelete'];
    final canArchive = json['canArchive'];
    final blockingReasons = json['blockingReasons'];
    final userMessage = json['userMessage'];

    if (documentId is! String ||
        (courseId != null && courseId is! String) ||
        status is! String ||
        recommendedAction is! String ||
        canDelete is! bool ||
        canArchive is! bool ||
        blockingReasons is! List ||
        userMessage is! String) {
      throw const FormatException('Invalid source lifecycle response');
    }

    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: courseId as String?,
      status: _parseStatus(status),
      recommendedAction: _parseAction(recommendedAction),
      canDelete: canDelete,
      canArchive: canArchive,
      blockingReasons: blockingReasons.whereType<String>().toList(),
      userMessage: userMessage,
    );
  }

  SourceLifecycleStatus _parseStatus(String value) {
    return switch (value) {
      'ACTIVE' => SourceLifecycleStatus.active,
      'ARCHIVED' => SourceLifecycleStatus.archived,
      _ => SourceLifecycleStatus.unknown,
    };
  }

  SourceLifecycleAction _parseAction(String value) {
    return switch (value) {
      'DELETE' => SourceLifecycleAction.delete,
      'ARCHIVE' => SourceLifecycleAction.archive,
      'BLOCK' => SourceLifecycleAction.block,
      _ => SourceLifecycleAction.unknown,
    };
  }
}

class SourceLifecycleException implements Exception {
  const SourceLifecycleException(this.message);

  final String message;

  @override
  String toString() => message;
}
