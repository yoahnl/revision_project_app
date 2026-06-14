import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';

typedef DiagnosticQuizSubmitter =
    Future<DiagnosticQuizResult> Function(List<DiagnosticQuizAnswer> answers);
typedef OpenAnswerSubmitter =
    Future<OpenAnswerSubmissionResult> Function(String answerText);

const openQuestionMinAnswerLength = 12;

abstract interface class ActivityApi {
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  });

  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  });

  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  });

  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
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

  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) {
    final trimmedSubjectId = subjectId.trim();
    final trimmedKnowledgeUnitId = knowledgeUnitId.trim();

    if (trimmedSubjectId.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    if (trimmedKnowledgeUnitId.isEmpty) {
      throw ArgumentError('Knowledge unit id is required');
    }

    return _api.startOpenQuestion(
      subjectId: trimmedSubjectId,
      knowledgeUnitId: trimmedKnowledgeUnitId,
    );
  }

  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) {
    final trimmedSessionId = sessionId.trim();
    final trimmedAnswerText = answerText.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Activity session id is required');
    }

    if (trimmedAnswerText.isEmpty) {
      throw ArgumentError('Open answer text is required');
    }

    return _api.submitOpenAnswer(
      sessionId: trimmedSessionId,
      answerText: trimmedAnswerText,
    );
  }
}

class OpenQuestionSessionController {
  OpenQuestionSessionController({required this.activity, this.submitter});

  final OpenQuestionActivity activity;
  final OpenAnswerSubmitter? submitter;

  String _answerText = '';
  OpenAnswerSubmissionResult? _result;
  Object? _submitError;
  bool _isSubmitting = false;
  Future<void>? _activeSubmit;

  String get answerText => _answerText;
  OpenAnswerSubmissionResult? get result => _result;
  Object? get submitError => _submitError;
  bool get isSubmitting => _isSubmitting;
  bool get hasCorrection => _result != null;

  bool get canSubmit {
    return submitter != null &&
        !_isSubmitting &&
        _result == null &&
        validationMessage == null;
  }

  String? get validationMessage {
    final trimmedAnswer = _answerText.trim();

    if (trimmedAnswer.length < openQuestionMinAnswerLength) {
      return 'Réponse trop courte';
    }

    if (trimmedAnswer.length > activity.question.maxAnswerLength) {
      return 'Réponse trop longue';
    }

    return null;
  }

  String? get submitErrorMessage {
    if (_submitError == null) {
      return null;
    }

    return 'Impossible de récupérer la correction. La correction a peut-être été enregistrée. Réessaie dans un instant.';
  }

  void updateAnswer(String answerText) {
    if (_result != null || _isSubmitting) {
      return;
    }

    _answerText = answerText;
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

    final future = _submitAnswer();
    _activeSubmit = future;

    return future;
  }

  Future<void> _submitAnswer() async {
    try {
      _result = await submitter!(_answerText.trim());
    } catch (error) {
      _submitError = error;
    } finally {
      _isSubmitting = false;
      _activeSubmit = null;
    }
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
