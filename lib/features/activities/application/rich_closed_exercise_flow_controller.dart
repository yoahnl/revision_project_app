import '../domain/rich_closed_exercise.dart';
import 'activity_controller.dart';

enum RichClosedExerciseFlowStatus {
  idle,
  loadingExercise,
  ready,
  submitting,
  completed,
  failed,
}

class RichClosedExerciseFlowState {
  const RichClosedExerciseFlowState({
    required this.status,
    this.exercise,
    this.result,
    this.error,
    this.answeredCount = 0,
    this.totalQuestions = 0,
  });

  const RichClosedExerciseFlowState.idle()
    : status = RichClosedExerciseFlowStatus.idle,
      exercise = null,
      result = null,
      error = null,
      answeredCount = 0,
      totalQuestions = 0;

  final RichClosedExerciseFlowStatus status;
  final RichClosedExercise? exercise;
  final RichClosedExerciseResult? result;
  final Object? error;
  final int answeredCount;
  final int totalQuestions;

  bool get isLoading => status == RichClosedExerciseFlowStatus.loadingExercise;
  bool get isSubmitting => status == RichClosedExerciseFlowStatus.submitting;
  bool get hasResult => result != null;

  bool get canSubmit {
    return status == RichClosedExerciseFlowStatus.ready &&
        exercise != null &&
        result == null &&
        totalQuestions > 0 &&
        answeredCount == totalQuestions;
  }
}

class RichClosedExerciseFlowController {
  RichClosedExerciseFlowController({required this.activityController});

  final ActivityController activityController;
  final Map<String, RichClosedAnswer> _answersByQuestionId = {};
  RichClosedExerciseFlowState _state = const RichClosedExerciseFlowState.idle();
  Future<void>? _activeSubmit;

  RichClosedExerciseFlowState get state => _state;

  List<RichClosedAnswer> get currentAnswers {
    final exercise = _state.exercise;
    if (exercise == null) {
      return const [];
    }

    return _answersFor(exercise) ?? const [];
  }

  Future<void> start({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    _state = const RichClosedExerciseFlowState(
      status: RichClosedExerciseFlowStatus.loadingExercise,
    );

    try {
      final exercise = await activityController.startRichClosedExercise(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
        documentId: documentId,
        questionCount: questionCount,
        complexityProfile: complexityProfile,
        questionTypeMix: questionTypeMix,
      );
      _answersByQuestionId.clear();
      _state = _readyState(exercise);
    } catch (error) {
      _state = RichClosedExerciseFlowState(
        status: RichClosedExerciseFlowStatus.failed,
        error: error,
      );
    }
  }

  Future<void> load({required String sessionId}) async {
    _state = const RichClosedExerciseFlowState(
      status: RichClosedExerciseFlowStatus.loadingExercise,
    );

    try {
      final exercise = await activityController.getRichClosedExercise(
        sessionId,
      );
      _answersByQuestionId.clear();
      _state = _readyState(exercise);
    } catch (error) {
      _state = RichClosedExerciseFlowState(
        status: RichClosedExerciseFlowStatus.failed,
        error: error,
      );
    }
  }

  void refreshAnswers() {
    final exercise = _state.exercise;
    if (exercise == null || _state.result != null) {
      return;
    }

    _state = _readyState(exercise);
  }

  void recordAnswer(RichClosedQuestion question, RichClosedAnswer? answer) {
    final exercise = _state.exercise;
    if (exercise == null || _state.result != null || _state.isSubmitting) {
      return;
    }

    if (answer == null) {
      _answersByQuestionId.remove(question.id);
    } else if (answer.questionId != question.id ||
        answer.questionKind != question.questionKind) {
      _answersByQuestionId.remove(question.id);
    } else {
      _answersByQuestionId[question.id] = answer;
    }

    _state = _readyState(exercise);
  }

  Future<void> submit() {
    final activeSubmit = _activeSubmit;
    if (activeSubmit != null) {
      return activeSubmit;
    }

    final exercise = _state.exercise;
    if (exercise == null) {
      return Future.value();
    }

    final answers = _answersFor(exercise);
    if (answers == null || !_state.canSubmit) {
      return Future.value();
    }

    _state = RichClosedExerciseFlowState(
      status: RichClosedExerciseFlowStatus.submitting,
      exercise: exercise,
      answeredCount: _answeredCount(exercise),
      totalQuestions: exercise.questions.length,
    );

    final future = _submitAnswers(exercise: exercise, answers: answers);
    _activeSubmit = future;

    return future;
  }

  Future<void> _submitAnswers({
    required RichClosedExercise exercise,
    required List<RichClosedAnswer> answers,
  }) async {
    try {
      final result = await activityController.submitRichClosedExercise(
        sessionId: exercise.sessionId,
        answers: answers,
      );
      _state = RichClosedExerciseFlowState(
        status: RichClosedExerciseFlowStatus.completed,
        exercise: exercise,
        result: result,
        answeredCount: exercise.questions.length,
        totalQuestions: exercise.questions.length,
      );
    } catch (error) {
      _state = RichClosedExerciseFlowState(
        status: RichClosedExerciseFlowStatus.failed,
        exercise: exercise,
        error: error,
        answeredCount: _answeredCount(exercise),
        totalQuestions: exercise.questions.length,
      );
    } finally {
      _activeSubmit = null;
    }
  }

  RichClosedExerciseFlowState _readyState(RichClosedExercise exercise) {
    return RichClosedExerciseFlowState(
      status: RichClosedExerciseFlowStatus.ready,
      exercise: exercise,
      answeredCount: _answeredCount(exercise),
      totalQuestions: exercise.questions.length,
    );
  }

  int _answeredCount(RichClosedExercise exercise) {
    return exercise.questions.where(_answerForQuestionExists).length;
  }

  List<RichClosedAnswer>? _answersFor(RichClosedExercise exercise) {
    final answers = <RichClosedAnswer>[];

    for (final question in exercise.questions) {
      final answer = _answerForQuestion(question);
      if (answer == null) {
        return null;
      }
      answers.add(answer);
    }

    return answers;
  }

  bool _answerForQuestionExists(RichClosedQuestion question) {
    return _answerForQuestion(question) != null;
  }

  RichClosedAnswer? _answerForQuestion(RichClosedQuestion question) {
    final recordedAnswer = _answersByQuestionId[question.id];
    if (recordedAnswer != null) {
      return recordedAnswer;
    }

    if (question is RichClosedOrderingQuestion) {
      return RichClosedOrderingAnswer(
        questionId: question.id,
        orderedIds: [for (final item in question.items) item.id],
      );
    }

    if (question is RichClosedTimelineQuestion) {
      return RichClosedTimelineAnswer(
        questionId: question.id,
        orderedEventIds: [for (final event in question.events) event.id],
      );
    }

    if (question is RichClosedDateSliderQuestion) {
      return RichClosedDateSliderAnswer(
        questionId: question.id,
        year: _initialYearFor(question),
      );
    }

    return null;
  }

  int _initialYearFor(RichClosedDateSliderQuestion question) {
    final midpoint =
        question.minYear + ((question.maxYear - question.minYear) / 2).round();

    return _snapYear(question, midpoint);
  }

  int _snapYear(RichClosedDateSliderQuestion question, int year) {
    final clamped = year.clamp(question.minYear, question.maxYear);
    final offset = clamped - question.minYear;
    final stepsFromMin = (offset / question.step).round();
    final snapped = question.minYear + stepsFromMin * question.step;

    if (snapped < question.minYear) {
      return question.minYear;
    }
    if (snapped > question.maxYear) {
      return question.maxYear;
    }
    return snapped;
  }
}
