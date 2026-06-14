class DiagnosticQuizActivity {
  const DiagnosticQuizActivity({
    required this.sessionId,
    required this.title,
    required this.questions,
    this.type = 'diagnostic_quiz',
    this.version,
    this.documentId,
    this.subjectId,
  });

  final String sessionId;
  final String type;
  final int? version;
  final String title;
  final String? documentId;
  final String? subjectId;
  final List<DiagnosticQuizQuestion> questions;
}

class DiagnosticQuizQuestion {
  const DiagnosticQuizQuestion({
    required this.id,
    required this.prompt,
    required this.choices,
    this.knowledgeUnitId,
    this.difficulty,
    this.selectionMode = DiagnosticQuizSelectionMode.single,
    int? minSelections,
    int? maxSelections,
    this.sources = const [],
    this.visuals = const [],
  }) : minSelections = minSelections ?? 1,
       maxSelections =
           maxSelections ??
           (selectionMode == DiagnosticQuizSelectionMode.multiple
               ? choices.length
               : 1);

  final String id;
  final String? knowledgeUnitId;
  final String prompt;
  final String? difficulty;
  final DiagnosticQuizSelectionMode selectionMode;
  final int minSelections;
  final int maxSelections;
  final List<DiagnosticQuizChoice> choices;
  final List<DiagnosticQuizSourceRef> sources;
  final List<DiagnosticQuizVisual> visuals;
}

enum DiagnosticQuizSelectionMode { single, multiple }

class DiagnosticQuizChoice {
  const DiagnosticQuizChoice({required this.id, required this.label});

  final String id;
  final String label;
}

class DiagnosticQuizSourceRef {
  const DiagnosticQuizSourceRef({
    required this.chunkId,
    required this.pageNumber,
    required this.index,
  });

  final String chunkId;
  final int? pageNumber;
  final int index;
}

sealed class DiagnosticQuizVisual {
  const DiagnosticQuizVisual({
    required this.id,
    required this.displayOrder,
    this.sources = const [],
  });

  final String id;
  final int displayOrder;
  final List<DiagnosticQuizSourceRef> sources;
}

enum DiagnosticQuizChartType { bar, line, pie, scatter }

class DiagnosticQuizChartVisual extends DiagnosticQuizVisual {
  const DiagnosticQuizChartVisual({
    required super.id,
    required super.displayOrder,
    required this.chartType,
    required this.title,
    required this.data,
    this.description,
    this.xKey,
    this.yKeys = const [],
    super.sources,
  });

  final DiagnosticQuizChartType chartType;
  final String title;
  final String? description;
  final List<Map<String, Object?>> data;
  final String? xKey;
  final List<String> yKeys;
}

class DiagnosticQuizDiagramVisual extends DiagnosticQuizVisual {
  const DiagnosticQuizDiagramVisual({
    required super.id,
    required super.displayOrder,
    required this.title,
    required this.nodes,
    this.description,
    this.edges = const [],
    super.sources,
  });

  final String title;
  final String? description;
  final List<DiagnosticQuizDiagramNode> nodes;
  final List<DiagnosticQuizDiagramEdge> edges;
}

class DiagnosticQuizDiagramNode {
  const DiagnosticQuizDiagramNode({required this.id, required this.label});

  final String id;
  final String label;
}

class DiagnosticQuizDiagramEdge {
  const DiagnosticQuizDiagramEdge({
    required this.from,
    required this.to,
    this.label,
  });

  final String from;
  final String to;
  final String? label;
}

class DiagnosticQuizUnsupportedVisual extends DiagnosticQuizVisual {
  const DiagnosticQuizUnsupportedVisual({
    required super.id,
    required super.displayOrder,
    required this.type,
    super.sources,
  });

  final String type;
}

class DiagnosticQuizAnswer {
  const DiagnosticQuizAnswer({
    required this.questionId,
    this.choiceId,
    this.choiceIds = const [],
  });

  final String questionId;
  final String? choiceId;
  final List<String> choiceIds;
}

class DiagnosticQuizResult {
  const DiagnosticQuizResult({
    required this.correctAnswers,
    required this.totalQuestions,
    this.score,
    this.items = const [],
  });

  final int correctAnswers;
  final int totalQuestions;
  final double? score;
  final List<DiagnosticQuizCorrectionItem> items;
}

class DiagnosticQuizCorrectionItem {
  const DiagnosticQuizCorrectionItem({
    required this.questionId,
    required this.knowledgeUnitId,
    required this.prompt,
    required this.isCorrect,
    required this.explanation,
    this.selectedChoiceId,
    this.correctChoiceId,
    this.selectedChoiceIds = const [],
    this.correctChoiceIds = const [],
    this.partialScore,
    this.choiceFeedback = const [],
    this.sources = const [],
  });

  final String questionId;
  final String? knowledgeUnitId;
  final String prompt;
  final String? selectedChoiceId;
  final String? correctChoiceId;
  final List<String> selectedChoiceIds;
  final List<String> correctChoiceIds;
  final bool isCorrect;
  final double? partialScore;
  final String explanation;
  final List<DiagnosticQuizChoiceFeedback> choiceFeedback;
  final List<DiagnosticQuizCorrectionSource> sources;
}

class DiagnosticQuizChoiceFeedback {
  const DiagnosticQuizChoiceFeedback({
    required this.choiceId,
    required this.feedback,
  });

  final String choiceId;
  final String feedback;
}

class DiagnosticQuizCorrectionSource {
  const DiagnosticQuizCorrectionSource({
    required this.chunkId,
    required this.text,
    required this.pageNumber,
    required this.index,
  });

  final String chunkId;
  final String text;
  final int? pageNumber;
  final int index;
}
