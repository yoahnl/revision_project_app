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
  final Map<String, String> _selectedChoiceIdsByQuestion = {};

  DiagnosticQuizResult? _result;
  Object? _submitError;
  bool _isSubmitting = false;
  Future<void>? _activeSubmit;

  DiagnosticQuizResult? get result => _result;
  Object? get submitError => _submitError;
  bool get isSubmitting => _isSubmitting;
  int get answeredCount => _selectedChoiceIdsByQuestion.length;
  bool get hasCorrection => _result != null;

  bool get canSubmit {
    return submitter != null &&
        !_isSubmitting &&
        _result == null &&
        activity.questions.isNotEmpty &&
        _selectedChoiceIdsByQuestion.length == activity.questions.length;
  }

  String? selectedChoiceIdFor(String questionId) {
    return _selectedChoiceIdsByQuestion[questionId];
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

    _selectedChoiceIdsByQuestion[questionId] = choiceId;
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
            .map(
              (question) => DiagnosticQuizAnswer(
                questionId: question.id,
                choiceId: _selectedChoiceIdsByQuestion[question.id]!,
              ),
            )
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

  DiagnosticQuizQuestion? _questionById(String questionId) {
    for (final question in activity.questions) {
      if (question.id == questionId) {
        return question;
      }
    }

    return null;
  }
}
