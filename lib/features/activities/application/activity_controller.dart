import '../domain/diagnostic_quiz_activity.dart';

typedef DiagnosticQuizSubmitter =
    Future<DiagnosticQuizResult> Function(List<DiagnosticQuizAnswer> answers);

abstract interface class ActivityApi {
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  });

  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  });
}

class ActivityController {
  const ActivityController(this._api);

  final ActivityApi _api;

  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) {
    final trimmedSubjectId = subjectId.trim();

    if (trimmedSubjectId.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    return _api.startNextActivity(
      subjectId: trimmedSubjectId,
      knowledgeUnitId: knowledgeUnitId,
    );
  }

  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) {
    if (answers.isEmpty) {
      throw ArgumentError('At least one answer is required');
    }

    return _api.submitResult(sessionId: sessionId, answers: answers);
  }
}

class DiagnosticQuizSessionController {
  DiagnosticQuizSessionController({required this.activity, this.submitter});

  final DiagnosticQuizActivity activity;
  final DiagnosticQuizSubmitter? submitter;
  final Map<String, Set<String>> _selectedChoiceIdsByQuestion = {};

  DiagnosticQuizResult? _result;
  Object? _submitError;
  bool _isSubmitting = false;
  Future<void>? _activeSubmit;

  DiagnosticQuizResult? get result => _result;
  Object? get submitError => _submitError;
  bool get isSubmitting => _isSubmitting;
  int get answeredCount => activity.questions
      .where((question) => _isQuestionComplete(question))
      .length;
  bool get hasCorrection => _result != null;

  bool get canSubmit {
    return submitter != null &&
        !_isSubmitting &&
        _result == null &&
        activity.questions.isNotEmpty &&
        activity.questions.every(_isQuestionComplete);
  }

  String? selectedChoiceIdFor(String questionId) {
    final selectedChoiceIds = selectedChoiceIdsFor(questionId);
    return selectedChoiceIds.isEmpty ? null : selectedChoiceIds.first;
  }

  List<String> selectedChoiceIdsFor(String questionId) {
    final selectedChoiceIds = _selectedChoiceIdsByQuestion[questionId];
    if (selectedChoiceIds == null || selectedChoiceIds.isEmpty) {
      return const [];
    }

    final question = _questionById(questionId);
    if (question == null) {
      return selectedChoiceIds.toList(growable: false);
    }

    return question.choices
        .where((choice) => selectedChoiceIds.contains(choice.id))
        .map((choice) => choice.id)
        .toList(growable: false);
  }

  void selectChoice({required String questionId, required String choiceId}) {
    if (_result != null || _isSubmitting) {
      return;
    }

    final question = _questionById(questionId);
    if (question == null) {
      return;
    }

    if (!question.choices.any((choice) => choice.id == choiceId)) {
      return;
    }

    if (question.selectionMode == DiagnosticQuizSelectionMode.multiple) {
      _toggleMultipleChoice(question: question, choiceId: choiceId);
    } else {
      _selectedChoiceIdsByQuestion[questionId] = {choiceId};
    }

    _submitError = null;
  }

  Future<void> submit() {
    final activeSubmit = _activeSubmit;
    if (activeSubmit != null) {
      return activeSubmit;
    }

    if (!canSubmit) {
      return Future.value();
    }

    _isSubmitting = true;
    _submitError = null;

    final future = _submitSelectedAnswers();
    _activeSubmit = future;

    return future;
  }

  Future<void> _submitSelectedAnswers() async {
    try {
      final result = await submitter!(
        activity.questions
            .map((question) => _answerForQuestion(question))
            .toList(growable: false),
      );
      _result = result;
    } catch (error) {
      _submitError = error;
    } finally {
      _isSubmitting = false;
      _activeSubmit = null;
    }
  }

  void _toggleMultipleChoice({
    required DiagnosticQuizQuestion question,
    required String choiceId,
  }) {
    final selectedChoiceIds = {...?_selectedChoiceIdsByQuestion[question.id]};

    if (selectedChoiceIds.contains(choiceId)) {
      selectedChoiceIds.remove(choiceId);
    } else if (selectedChoiceIds.length < question.maxSelections) {
      selectedChoiceIds.add(choiceId);
    }

    if (selectedChoiceIds.isEmpty) {
      _selectedChoiceIdsByQuestion.remove(question.id);
      return;
    }

    _selectedChoiceIdsByQuestion[question.id] = selectedChoiceIds;
  }

  bool _isQuestionComplete(DiagnosticQuizQuestion question) {
    final selectedChoiceIds = _selectedChoiceIdsByQuestion[question.id];
    if (selectedChoiceIds == null) {
      return false;
    }

    if (question.selectionMode == DiagnosticQuizSelectionMode.multiple) {
      return selectedChoiceIds.length >= question.minSelections &&
          selectedChoiceIds.length <= question.maxSelections;
    }

    return selectedChoiceIds.length == 1;
  }

  DiagnosticQuizAnswer _answerForQuestion(DiagnosticQuizQuestion question) {
    final selectedChoiceIds = selectedChoiceIdsFor(question.id);

    if (question.selectionMode == DiagnosticQuizSelectionMode.multiple) {
      return DiagnosticQuizAnswer(
        questionId: question.id,
        choiceIds: selectedChoiceIds,
      );
    }

    return DiagnosticQuizAnswer(
      questionId: question.id,
      choiceId: selectedChoiceIds.first,
    );
  }

  DiagnosticQuizQuestion? _questionById(String questionId) {
    for (final question in activity.questions) {
      if (question.id == questionId) {
        return question;
      }
    }

    return null;
  }
}
