import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';
import '../domain/rich_closed_exercise.dart';

class DemoActivityApi implements ActivityApi {
  static const DiagnosticQuizActivity _activity = DiagnosticQuizActivity(
    sessionId: 'demo-session-1',
    title: 'Diagnostic rapide',
    questions: [
      DiagnosticQuizQuestion(
        id: 'question-1',
        prompt:
            'Quelle structure est principalement responsable de la contraction cardiaque ?',
        choices: [
          DiagnosticQuizChoice(id: 'a', label: 'Myocarde'),
          DiagnosticQuizChoice(id: 'b', label: 'Pericarde'),
        ],
      ),
    ],
  );

  static const OpenQuestionActivity _openQuestionActivity =
      OpenQuestionActivity(
        sessionId: 'demo-open-session-1',
        type: 'open_question',
        version: 1,
        subjectId: 'demo-subject',
        documentId: null,
        knowledgeUnitId: 'demo-unit',
        question: OpenQuestion(
          id: 'demo-open-question-1',
          prompt: 'Explique avec tes mots le point principal de cette notion.',
          instructions: 'Réponds en quelques phrases structurées.',
          maxAnswerLength: 4000,
        ),
      );

  static final RichClosedExercise _richClosedExercise = RichClosedExercise(
    sessionId: 'demo-rich-session-1',
    type: richClosedExerciseType,
    id: 'demo-rich-exercise-1',
    version: richClosedExerciseVersion,
    title: 'Questions riches de démonstration',
    subjectId: 'demo-subject',
    documentId: null,
    knowledgeUnitId: 'demo-unit',
    questions: [
      RichClosedSingleChoiceQuestion(
        base: _base(
          id: 'demo-single-1',
          prompt: 'Quel critère caractérise un régime parlementaire ?',
          skill: RichClosedCognitiveSkill.classification,
        ),
        choices: const [
          RichClosedChoice(id: 'choice-a', label: 'Responsabilité politique'),
          RichClosedChoice(id: 'choice-b', label: 'Séparation étanche'),
        ],
      ),
      RichClosedMultipleChoiceQuestion(
        base: _base(
          id: 'demo-multiple-1',
          prompt: 'Quels indices orientent vers un régime parlementaire ?',
          skill: RichClosedCognitiveSkill.comparison,
        ),
        choices: const [
          RichClosedChoice(
            id: 'choice-a',
            label: 'Responsabilité du gouvernement',
          ),
          RichClosedChoice(id: 'choice-b', label: 'Collaboration des pouvoirs'),
          RichClosedChoice(id: 'choice-c', label: 'Indépendance absolue'),
        ],
        minSelections: 2,
        maxSelections: 2,
      ),
      RichClosedMatchingQuestion(
        base: _base(
          id: 'demo-matching-1',
          prompt: 'Associe chaque mécanisme à sa fonction.',
          skill: RichClosedCognitiveSkill.comparison,
        ),
        leftItems: const [
          RichClosedLabelItem(id: 'left-1', label: 'Motion de censure'),
          RichClosedLabelItem(id: 'left-2', label: 'Dissolution'),
          RichClosedLabelItem(id: 'left-3', label: 'Contrôle constitutionnel'),
        ],
        rightItems: const [
          RichClosedLabelItem(id: 'right-1', label: 'Responsabilité politique'),
          RichClosedLabelItem(
            id: 'right-2',
            label: 'Fin anticipée d’une chambre',
          ),
          RichClosedLabelItem(id: 'right-3', label: 'Vérification d’une norme'),
        ],
      ),
      RichClosedOrderingQuestion(
        base: _base(
          id: 'demo-ordering-1',
          prompt: 'Ordonne les étapes du raisonnement.',
          skill: RichClosedCognitiveSkill.procedure,
        ),
        items: const [
          RichClosedLabelItem(id: 'item-1', label: 'Repérer les organes'),
          RichClosedLabelItem(id: 'item-2', label: 'Analyser les moyens'),
          RichClosedLabelItem(id: 'item-3', label: 'Qualifier le régime'),
        ],
      ),
      RichClosedCaseQualificationQuestion(
        base: _base(
          id: 'demo-case-1',
          prompt: 'Choisis la qualification la plus pertinente.',
          skill: RichClosedCognitiveSkill.caseApplication,
        ),
        caseText:
            'Un gouvernement doit conserver la confiance d’une chambre élue.',
        choices: const [
          RichClosedChoice(id: 'choice-a', label: 'Régime parlementaire'),
          RichClosedChoice(id: 'choice-b', label: 'Régime présidentiel'),
        ],
      ),
      RichClosedErrorDetectionQuestion(
        base: _base(
          id: 'demo-error-1',
          prompt: 'Repère l’erreur dominante.',
          skill: RichClosedCognitiveSkill.errorDetection,
        ),
        statement:
            'Un régime présidentiel se définit par la responsabilité politique du gouvernement devant le Parlement.',
        errorOptions: const [
          RichClosedChoice(
            id: 'error-a',
            label: 'Confusion avec le parlementarisme',
          ),
          RichClosedChoice(
            id: 'error-b',
            label: 'Confusion avec le fédéralisme',
          ),
        ],
      ),
    ],
  );

  static final RichClosedExerciseResult
  _richClosedResult = RichClosedExerciseResult(
    sessionId: 'demo-rich-session-1',
    type: richClosedExerciseType,
    status: 'completed',
    correctAnswers: 6,
    totalQuestions: 6,
    score: 1,
    items: const [
      RichClosedCorrectionItem(
        questionId: 'demo-single-1',
        questionKind: RichClosedQuestionKind.singleChoice,
        prompt: 'Quel critère caractérise un régime parlementaire ?',
        submittedAnswer: RichClosedSingleChoiceAnswer(
          questionId: 'demo-single-1',
          choiceId: 'choice-a',
        ),
        isCorrect: true,
        partialScore: 1,
        explanation:
            'La responsabilité politique est un critère du parlementarisme.',
        sourceChunkIds: ['demo-chunk-1'],
        correction: RichClosedCorrectChoiceIdCorrection(
          correctChoiceId: 'choice-a',
        ),
      ),
      RichClosedCorrectionItem(
        questionId: 'demo-multiple-1',
        questionKind: RichClosedQuestionKind.multipleChoice,
        prompt: 'Quels indices orientent vers un régime parlementaire ?',
        submittedAnswer: RichClosedMultipleChoiceAnswer(
          questionId: 'demo-multiple-1',
          choiceIds: ['choice-a', 'choice-b'],
        ),
        isCorrect: true,
        partialScore: 1,
        explanation:
            'Responsabilité et collaboration des pouvoirs vont ensemble.',
        sourceChunkIds: ['demo-chunk-1'],
        correction: RichClosedCorrectChoiceIdsCorrection(
          correctChoiceIds: ['choice-a', 'choice-b'],
        ),
      ),
      RichClosedCorrectionItem(
        questionId: 'demo-matching-1',
        questionKind: RichClosedQuestionKind.matching,
        prompt: 'Associe chaque mécanisme à sa fonction.',
        submittedAnswer: RichClosedMatchingAnswer(
          questionId: 'demo-matching-1',
          pairs: [
            RichClosedPair(leftId: 'left-1', rightId: 'right-1'),
            RichClosedPair(leftId: 'left-2', rightId: 'right-2'),
            RichClosedPair(leftId: 'left-3', rightId: 'right-3'),
          ],
        ),
        isCorrect: true,
        partialScore: 1,
        explanation: 'Chaque mécanisme est associé à sa fonction.',
        sourceChunkIds: ['demo-chunk-2'],
        correction: RichClosedCorrectPairsCorrection(
          correctPairs: [
            RichClosedPair(leftId: 'left-1', rightId: 'right-1'),
            RichClosedPair(leftId: 'left-2', rightId: 'right-2'),
            RichClosedPair(leftId: 'left-3', rightId: 'right-3'),
          ],
        ),
      ),
      RichClosedCorrectionItem(
        questionId: 'demo-ordering-1',
        questionKind: RichClosedQuestionKind.ordering,
        prompt: 'Ordonne les étapes du raisonnement.',
        submittedAnswer: RichClosedOrderingAnswer(
          questionId: 'demo-ordering-1',
          orderedIds: ['item-1', 'item-2', 'item-3'],
        ),
        isCorrect: true,
        partialScore: 1,
        explanation: 'La qualification vient après l’analyse.',
        sourceChunkIds: ['demo-chunk-3'],
        correction: RichClosedCorrectOrderCorrection(
          correctOrder: ['item-1', 'item-2', 'item-3'],
        ),
      ),
      RichClosedCorrectionItem(
        questionId: 'demo-case-1',
        questionKind: RichClosedQuestionKind.caseQualification,
        prompt: 'Choisis la qualification la plus pertinente.',
        submittedAnswer: RichClosedCaseQualificationAnswer(
          questionId: 'demo-case-1',
          choiceId: 'choice-a',
        ),
        isCorrect: true,
        partialScore: 1,
        explanation:
            'La confiance parlementaire qualifie le régime parlementaire.',
        sourceChunkIds: ['demo-chunk-4'],
        correction: RichClosedCorrectChoiceIdCorrection(
          correctChoiceId: 'choice-a',
        ),
      ),
      RichClosedCorrectionItem(
        questionId: 'demo-error-1',
        questionKind: RichClosedQuestionKind.errorDetection,
        prompt: 'Repère l’erreur dominante.',
        submittedAnswer: RichClosedErrorDetectionAnswer(
          questionId: 'demo-error-1',
          errorId: 'error-a',
        ),
        isCorrect: true,
        partialScore: 1,
        explanation:
            'La responsabilité devant le Parlement relève du parlementarisme.',
        sourceChunkIds: ['demo-chunk-5'],
        correction: RichClosedCorrectErrorIdCorrection(
          correctErrorId: 'error-a',
        ),
      ),
    ],
  );

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    return _activity;
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    final correctAnswers = answers.where((answer) {
      return answer.questionId == 'question-1' && answer.choiceId == 'a';
    }).length;

    return DiagnosticQuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: _activity.questions.length,
    );
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    return _openQuestionActivity;
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    return const OpenAnswerSubmissionResult(
      sessionId: 'demo-open-session-1',
      type: 'open_question',
      status: 'submitted',
      evaluation: OpenAnswerEvaluation(
        id: 'demo-open-evaluation-1',
        status: OpenAnswerEvaluationStatus.ready,
        score: 14,
        maxScore: 20,
        feedback: 'Réponse claire pour une démonstration locale.',
        presentPoints: ['Idée principale identifiée'],
        missingPoints: ['Exemple précis à ajouter'],
        errors: [],
        modelAnswer: 'Une réponse complète définit la notion et l’illustre.',
        advice: 'Ajoute un exemple issu du cours.',
        sources: [],
      ),
    );
  }

  @override
  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    return _richClosedExercise;
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    return _richClosedExercise;
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    return _richClosedResult;
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    return _richClosedResult;
  }
}

RichClosedQuestionBase _base({
  required String id,
  required String prompt,
  required RichClosedCognitiveSkill skill,
}) {
  return RichClosedQuestionBase(
    id: id,
    prompt: prompt,
    difficulty: RichClosedDifficulty.medium,
    cognitiveSkill: skill,
    sourceChunkIds: const ['demo-chunk-1'],
  );
}
