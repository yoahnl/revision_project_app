import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

class RichClosedCorrectionPresentationException implements Exception {
  const RichClosedCorrectionPresentationException(this.message);

  final String message;

  @override
  String toString() => 'RichClosedCorrectionPresentationException: $message';
}

class RichClosedCorrectionPresenter {
  const RichClosedCorrectionPresenter();

  RichClosedCorrectionViewModel present({
    required RichClosedExercise exercise,
    required RichClosedExerciseResult result,
  }) {
    final questionsById = {
      for (final question in exercise.questions) question.id: question,
    };

    final items = <RichClosedCorrectionItemViewModel>[
      for (final item in result.items)
        _presentItem(
          question: _questionFor(questionsById, item.questionId),
          item: item,
        ),
    ];

    return RichClosedCorrectionViewModel(
      summary: RichClosedResultSummaryViewModel(
        sessionId: result.sessionId,
        status: result.status,
        correctAnswers: result.correctAnswers,
        totalQuestions: result.totalQuestions,
        score: result.score,
      ),
      items: items,
    );
  }

  RichClosedCorrectionItemViewModel _presentItem({
    required RichClosedQuestion question,
    required RichClosedCorrectionItem item,
  }) {
    _assertQuestionContract(question, item);

    return switch (question) {
      RichClosedSingleChoiceQuestion() => _presentSingleChoice(question, item),
      RichClosedMultipleChoiceQuestion() => _presentMultipleChoice(
        question,
        item,
      ),
      RichClosedMatchingQuestion() => _presentMatching(question, item),
      RichClosedOrderingQuestion() => _presentOrdering(question, item),
      RichClosedTimelineQuestion() => _presentTimeline(question, item),
      RichClosedDateSliderQuestion() => _presentDateSlider(question, item),
      RichClosedTrueFalseGridQuestion() => _presentTrueFalseGrid(
        question,
        item,
      ),
      RichClosedCauseConsequenceQuestion() => _presentCauseConsequence(
        question,
        item,
      ),
      RichClosedInstitutionMatrixQuestion() => _presentInstitutionMatrix(
        question,
        item,
      ),
      RichClosedDiagramLabelingQuestion() => _presentDiagramLabeling(
        question,
        item,
      ),
      RichClosedCalculationMcqQuestion() => _presentCalculationMcq(
        question,
        item,
      ),
      RichClosedCaseQualificationQuestion() => _presentCaseQualification(
        question,
        item,
      ),
      RichClosedErrorDetectionQuestion() => _presentErrorDetection(
        question,
        item,
      ),
    };
  }

  RichClosedCorrectionItemViewModel _presentSingleChoice(
    RichClosedSingleChoiceQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _singleChoiceAnswer(item);
    final correction = _choiceIdCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: [
        _choiceLabel(question.choices, submitted.choiceId, question.id),
      ],
      correctAnswerLines: [
        _choiceLabel(question.choices, correction.correctChoiceId, question.id),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentMultipleChoice(
    RichClosedMultipleChoiceQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _multipleChoiceAnswer(item);
    final correction = _choiceIdsCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: [
        for (final choiceId in submitted.choiceIds)
          _choiceLabel(question.choices, choiceId, question.id),
      ],
      correctAnswerLines: [
        for (final choiceId in correction.correctChoiceIds)
          _choiceLabel(question.choices, choiceId, question.id),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentMatching(
    RichClosedMatchingQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _matchingAnswer(item);
    final correction = _pairsCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: _matchingLines(question, submitted.pairs),
      correctAnswerLines: _matchingLines(question, correction.correctPairs),
    );
  }

  RichClosedCorrectionItemViewModel _presentOrdering(
    RichClosedOrderingQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _orderingAnswer(item);
    final correction = _orderCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: _orderedLines(question, submitted.orderedIds),
      correctAnswerLines: _orderedLines(question, correction.correctOrder),
    );
  }

  RichClosedCorrectionItemViewModel _presentTimeline(
    RichClosedTimelineQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _timelineAnswer(item);
    final correction = _orderCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: _timelineLines(question, submitted.orderedEventIds),
      correctAnswerLines: _timelineLines(question, correction.correctOrder),
    );
  }

  RichClosedCorrectionItemViewModel _presentDateSlider(
    RichClosedDateSliderQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _dateSliderAnswer(item);
    final correction = _yearCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: ['Année choisie : ${submitted.year}'],
      correctAnswerLines: [
        'Année correcte : ${correction.correctYear}',
        'Plage acceptée : ${correction.minAcceptedYear} - ${correction.maxAcceptedYear}',
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentTrueFalseGrid(
    RichClosedTrueFalseGridQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _trueFalseGridAnswer(item);
    final correction = _trueFalseValuesCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: _trueFalseLines(question, submitted.values),
      correctAnswerLines: _trueFalseLines(question, correction.correctValues),
    );
  }

  RichClosedCorrectionItemViewModel _presentCauseConsequence(
    RichClosedCauseConsequenceQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _causeConsequenceAnswer(item);
    final correction = _causeConsequencePairsCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: _causeConsequenceLines(question, submitted.pairs),
      correctAnswerLines: _causeConsequenceLines(
        question,
        correction.correctPairs,
      ),
    );
  }

  RichClosedCorrectionItemViewModel _presentInstitutionMatrix(
    RichClosedInstitutionMatrixQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _institutionMatrixAnswer(item);
    final correction = _institutionMatrixValuesCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: _institutionMatrixLines(question, submitted.values),
      correctAnswerLines: _institutionMatrixLines(
        question,
        correction.correctValues,
      ),
    );
  }

  RichClosedCorrectionItemViewModel _presentDiagramLabeling(
    RichClosedDiagramLabelingQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _diagramLabelingAnswer(item);
    final correction = _diagramLabelingValuesCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: _diagramLabelingLines(question, submitted.values),
      correctAnswerLines: _diagramLabelingLines(
        question,
        correction.correctValues,
      ),
    );
  }

  RichClosedCorrectionItemViewModel _presentCalculationMcq(
    RichClosedCalculationMcqQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _calculationMcqAnswer(item);
    final correction = _calculationMcqCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction == null
          ? question.scenario
          : '${question.instruction}\n${question.scenario}',
      submittedAnswerLines: [
        'Choix envoyé : ${_calculationChoiceLabel(question.choices, submitted.choiceId, question.id)}',
      ],
      correctAnswerLines: [
        'Choix attendu : ${_calculationChoiceLabel(question.choices, correction.correctChoiceId, question.id)}',
        'Valeur attendue : ${correction.expectedValue}',
        for (final step in correction.workedSteps)
          '${step.label} : ${step.detail}',
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentCaseQualification(
    RichClosedCaseQualificationQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _caseQualificationAnswer(item);
    final correction = _choiceIdCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.caseText,
      submittedAnswerLines: [
        _choiceLabel(question.choices, submitted.choiceId, question.id),
      ],
      correctAnswerLines: [
        _choiceLabel(question.choices, correction.correctChoiceId, question.id),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentErrorDetection(
    RichClosedErrorDetectionQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _errorDetectionAnswer(item);
    final correction = _errorIdCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.statement,
      submittedAnswerLines: [
        _choiceLabel(question.errorOptions, submitted.errorId, question.id),
      ],
      correctAnswerLines: [
        _choiceLabel(
          question.errorOptions,
          correction.correctErrorId,
          question.id,
        ),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _baseItem({
    required RichClosedQuestion question,
    required RichClosedCorrectionItem item,
    required List<String> submittedAnswerLines,
    required List<String> correctAnswerLines,
    String? contextText,
  }) {
    return RichClosedCorrectionItemViewModel(
      questionId: question.id,
      questionKind: question.questionKind,
      kindLabel: _kindLabel(question.questionKind),
      prompt: item.prompt,
      contextText: contextText,
      isCorrect: item.isCorrect,
      partialScore: item.partialScore,
      explanation: item.explanation,
      sourceLabels: [
        for (final sourceChunkId in item.sourceChunkIds)
          'Source $sourceChunkId',
      ],
      submittedAnswerLines: submittedAnswerLines,
      correctAnswerLines: correctAnswerLines,
    );
  }

  RichClosedQuestion _questionFor(
    Map<String, RichClosedQuestion> questionsById,
    String questionId,
  ) {
    final question = questionsById[questionId];
    if (question == null) {
      throw RichClosedCorrectionPresentationException(
        'Correction references unknown question $questionId',
      );
    }
    return question;
  }

  void _assertQuestionContract(
    RichClosedQuestion question,
    RichClosedCorrectionItem item,
  ) {
    if (item.questionKind != question.questionKind) {
      throw RichClosedCorrectionPresentationException(
        'Correction kind mismatch for question ${question.id}',
      );
    }

    if (item.submittedAnswer.questionId != question.id ||
        item.submittedAnswer.questionKind != question.questionKind) {
      throw RichClosedCorrectionPresentationException(
        'Submitted answer mismatch for question ${question.id}',
      );
    }
  }

  RichClosedSingleChoiceAnswer _singleChoiceAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedSingleChoiceAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid single choice submitted answer for ${item.questionId}',
    );
  }

  RichClosedMultipleChoiceAnswer _multipleChoiceAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedMultipleChoiceAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid multiple choice submitted answer for ${item.questionId}',
    );
  }

  RichClosedMatchingAnswer _matchingAnswer(RichClosedCorrectionItem item) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedMatchingAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid matching submitted answer for ${item.questionId}',
    );
  }

  RichClosedOrderingAnswer _orderingAnswer(RichClosedCorrectionItem item) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedOrderingAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid ordering submitted answer for ${item.questionId}',
    );
  }

  RichClosedTimelineAnswer _timelineAnswer(RichClosedCorrectionItem item) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedTimelineAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid timeline submitted answer for ${item.questionId}',
    );
  }

  RichClosedDateSliderAnswer _dateSliderAnswer(RichClosedCorrectionItem item) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedDateSliderAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid date slider submitted answer for ${item.questionId}',
    );
  }

  RichClosedTrueFalseGridAnswer _trueFalseGridAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedTrueFalseGridAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid true/false submitted answer for ${item.questionId}',
    );
  }

  RichClosedCauseConsequenceAnswer _causeConsequenceAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedCauseConsequenceAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid cause/consequence submitted answer for ${item.questionId}',
    );
  }

  RichClosedInstitutionMatrixAnswer _institutionMatrixAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedInstitutionMatrixAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid institution matrix submitted answer for ${item.questionId}',
    );
  }

  RichClosedDiagramLabelingAnswer _diagramLabelingAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedDiagramLabelingAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid diagram labeling submitted answer for ${item.questionId}',
    );
  }

  RichClosedCalculationMcqAnswer _calculationMcqAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedCalculationMcqAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid calculation submitted answer for ${item.questionId}',
    );
  }

  RichClosedCaseQualificationAnswer _caseQualificationAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedCaseQualificationAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid case qualification submitted answer for ${item.questionId}',
    );
  }

  RichClosedErrorDetectionAnswer _errorDetectionAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedErrorDetectionAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid error detection submitted answer for ${item.questionId}',
    );
  }

  RichClosedCorrectChoiceIdCorrection _choiceIdCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectChoiceIdCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid choice correction for ${item.questionId}',
    );
  }

  RichClosedCorrectChoiceIdsCorrection _choiceIdsCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectChoiceIdsCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid choices correction for ${item.questionId}',
    );
  }

  RichClosedCorrectPairsCorrection _pairsCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectPairsCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid matching correction for ${item.questionId}',
    );
  }

  RichClosedCorrectOrderCorrection _orderCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectOrderCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid ordering correction for ${item.questionId}',
    );
  }

  RichClosedCorrectYearCorrection _yearCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectYearCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid date slider correction for ${item.questionId}',
    );
  }

  RichClosedCorrectTrueFalseValuesCorrection _trueFalseValuesCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectTrueFalseValuesCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid true/false correction for ${item.questionId}',
    );
  }

  RichClosedCorrectCauseConsequencePairsCorrection
  _causeConsequencePairsCorrection(RichClosedCorrectionItem item) {
    final correction = item.correction;
    if (correction is RichClosedCorrectCauseConsequencePairsCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid cause/consequence correction for ${item.questionId}',
    );
  }

  RichClosedCorrectInstitutionMatrixValuesCorrection
  _institutionMatrixValuesCorrection(RichClosedCorrectionItem item) {
    final correction = item.correction;
    if (correction is RichClosedCorrectInstitutionMatrixValuesCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid institution matrix correction for ${item.questionId}',
    );
  }

  RichClosedCorrectDiagramLabelingValuesCorrection
  _diagramLabelingValuesCorrection(RichClosedCorrectionItem item) {
    final correction = item.correction;
    if (correction is RichClosedCorrectDiagramLabelingValuesCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid diagram labeling correction for ${item.questionId}',
    );
  }

  RichClosedCorrectCalculationMcqCorrection _calculationMcqCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectCalculationMcqCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid calculation correction for ${item.questionId}',
    );
  }

  RichClosedCorrectErrorIdCorrection _errorIdCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectErrorIdCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid error detection correction for ${item.questionId}',
    );
  }

  String _timelineEventLabel(
    List<RichClosedTimelineEvent> events,
    String eventId,
    String questionId,
  ) {
    for (final event in events) {
      if (event.id == eventId) {
        return event.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown timeline event $eventId for question $questionId',
    );
  }

  String _choiceLabel(
    List<RichClosedChoice> choices,
    String choiceId,
    String questionId,
  ) {
    for (final choice in choices) {
      if (choice.id == choiceId) {
        return choice.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown choice $choiceId for question $questionId',
    );
  }

  String _calculationChoiceLabel(
    List<RichClosedCalculationChoice> choices,
    String choiceId,
    String questionId,
  ) {
    for (final choice in choices) {
      if (choice.id == choiceId) {
        return choice.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown calculation choice $choiceId for question $questionId',
    );
  }

  String _causeConsequenceItemLabel(
    List<RichClosedCauseConsequenceItem> items,
    String itemId,
    String questionId,
  ) {
    for (final item in items) {
      if (item.id == itemId) {
        return item.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown cause/consequence item $itemId for question $questionId',
    );
  }

  String _institutionMatrixAxisLabel(
    List<RichClosedInstitutionMatrixAxisItem> items,
    String itemId,
    String questionId,
  ) {
    for (final item in items) {
      if (item.id == itemId) {
        return item.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown institution matrix axis $itemId for question $questionId',
    );
  }

  RichClosedInstitutionMatrixCell _institutionMatrixCell(
    RichClosedInstitutionMatrixQuestion question,
    String cellId,
  ) {
    for (final cell in question.cells) {
      if (cell.id == cellId) {
        return cell;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown institution matrix cell $cellId for question ${question.id}',
    );
  }

  RichClosedDiagramLabelingSlot _diagramLabelingSlot(
    RichClosedDiagramLabelingQuestion question,
    String slotId,
  ) {
    for (final slot in question.slots) {
      if (slot.id == slotId) {
        return slot;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown diagram labeling slot $slotId for question ${question.id}',
    );
  }

  RichClosedDiagramNode _diagramNode(
    RichClosedDiagramLabelingQuestion question,
    String nodeId,
  ) {
    for (final node in question.diagram.nodes) {
      if (node.id == nodeId) {
        return node;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown diagram node $nodeId for question ${question.id}',
    );
  }

  RichClosedDiagramEdge _diagramEdge(
    RichClosedDiagramLabelingQuestion question,
    String edgeId,
  ) {
    for (final edge in question.diagram.edges) {
      if (edge.id == edgeId) {
        return edge;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown diagram edge $edgeId for question ${question.id}',
    );
  }

  String _labelItem(
    List<RichClosedLabelItem> items,
    String itemId,
    String questionId,
  ) {
    for (final item in items) {
      if (item.id == itemId) {
        return item.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown item $itemId for question $questionId',
    );
  }

  List<String> _matchingLines(
    RichClosedMatchingQuestion question,
    List<RichClosedPair> pairs,
  ) {
    return [
      for (final pair in pairs)
        '${_labelItem(question.leftItems, pair.leftId, question.id)} → '
            '${_labelItem(question.rightItems, pair.rightId, question.id)}',
    ];
  }

  List<String> _orderedLines(
    RichClosedOrderingQuestion question,
    List<String> orderedIds,
  ) {
    return [
      for (var index = 0; index < orderedIds.length; index += 1)
        '${index + 1}. ${_labelItem(question.items, orderedIds[index], question.id)}',
    ];
  }

  List<String> _timelineLines(
    RichClosedTimelineQuestion question,
    List<String> orderedEventIds,
  ) {
    return [
      for (var index = 0; index < orderedEventIds.length; index += 1)
        '${index + 1}. ${_timelineEventLabel(question.events, orderedEventIds[index], question.id)}',
    ];
  }

  List<String> _trueFalseLines(
    RichClosedTrueFalseGridQuestion question,
    List<RichClosedTrueFalseGridValue> values,
  ) {
    final valuesByRowId = {for (final value in values) value.rowId: value};

    return [
      for (final row in question.rows)
        '${row.statement} : ${_booleanLabel(valuesByRowId[row.id]?.value, question.id, row.id)}',
    ];
  }

  List<String> _causeConsequenceLines(
    RichClosedCauseConsequenceQuestion question,
    List<RichClosedCauseConsequencePair> pairs,
  ) {
    return [
      for (final pair in pairs)
        '${_causeConsequenceItemLabel(question.causes, pair.causeId, question.id)} → '
            '${_causeConsequenceItemLabel(question.consequences, pair.consequenceId, question.id)}',
    ];
  }

  List<String> _institutionMatrixLines(
    RichClosedInstitutionMatrixQuestion question,
    List<RichClosedInstitutionMatrixValue> values,
  ) {
    return [
      for (final value in values) _institutionMatrixLine(question, value),
    ];
  }

  String _institutionMatrixLine(
    RichClosedInstitutionMatrixQuestion question,
    RichClosedInstitutionMatrixValue value,
  ) {
    final cell = _institutionMatrixCell(question, value.cellId);
    final rowLabel = _institutionMatrixAxisLabel(
      question.rows,
      cell.rowId,
      question.id,
    );
    final columnLabel = _institutionMatrixAxisLabel(
      question.columns,
      cell.columnId,
      question.id,
    );
    final optionLabel = _choiceLabel(cell.options, value.optionId, question.id);

    return '$rowLabel / $columnLabel : $optionLabel';
  }

  List<String> _diagramLabelingLines(
    RichClosedDiagramLabelingQuestion question,
    List<RichClosedDiagramLabelingValue> values,
  ) {
    _assertCompleteDiagramLabelingValues(question, values);

    return [for (final value in values) _diagramLabelingLine(question, value)];
  }

  void _assertCompleteDiagramLabelingValues(
    RichClosedDiagramLabelingQuestion question,
    List<RichClosedDiagramLabelingValue> values,
  ) {
    final expectedSlotIds = question.slots.map((slot) => slot.id).toSet();
    final seenSlotIds = <String>{};

    if (values.length != question.slots.length) {
      throw RichClosedCorrectionPresentationException(
        'Incomplete diagram labeling values for question ${question.id}',
      );
    }

    for (final value in values) {
      if (!expectedSlotIds.contains(value.slotId) ||
          !seenSlotIds.add(value.slotId)) {
        throw RichClosedCorrectionPresentationException(
          'Invalid diagram labeling values for question ${question.id}',
        );
      }
    }
  }

  String _diagramLabelingLine(
    RichClosedDiagramLabelingQuestion question,
    RichClosedDiagramLabelingValue value,
  ) {
    final slot = _diagramLabelingSlot(question, value.slotId);
    final anchorLabel = switch (slot.anchorType) {
      RichClosedDiagramAnchorType.node => _diagramNode(
        question,
        slot.anchorId,
      ).label,
      RichClosedDiagramAnchorType.edge => _diagramEdgeLine(
        question,
        _diagramEdge(question, slot.anchorId),
      ),
    };
    final optionLabel = _choiceLabel(slot.options, value.optionId, question.id);

    return '$anchorLabel : $optionLabel';
  }

  String _diagramEdgeLine(
    RichClosedDiagramLabelingQuestion question,
    RichClosedDiagramEdge edge,
  ) {
    final from = _diagramNode(question, edge.fromNodeId).label;
    final to = _diagramNode(question, edge.toNodeId).label;
    final label = edge.label;
    final endpoints = '$from -> $to';

    if (label == null) {
      return endpoints;
    }
    return '$endpoints / $label';
  }

  String _booleanLabel(bool? value, String questionId, String rowId) {
    if (value == null) {
      throw RichClosedCorrectionPresentationException(
        'Missing true/false value $rowId for question $questionId',
      );
    }

    return value ? 'Vrai' : 'Faux';
  }

  String _kindLabel(RichClosedQuestionKind kind) {
    return switch (kind) {
      RichClosedQuestionKind.singleChoice => 'Choix unique',
      RichClosedQuestionKind.multipleChoice => 'Choix multiples',
      RichClosedQuestionKind.matching => 'Association',
      RichClosedQuestionKind.ordering => 'Ordonnancement',
      RichClosedQuestionKind.caseQualification => 'Qualification',
      RichClosedQuestionKind.errorDetection => 'Erreur à repérer',
      RichClosedQuestionKind.timeline => 'Chronologie',
      RichClosedQuestionKind.dateSlider => 'Curseur temporel',
      RichClosedQuestionKind.trueFalseGrid => 'Vrai / faux',
      RichClosedQuestionKind.causeConsequence => 'Cause / conséquence',
      RichClosedQuestionKind.institutionMatrix => 'Matrice',
      RichClosedQuestionKind.diagramLabeling => 'Schéma',
      RichClosedQuestionKind.calculationMcq => 'Calcul',
    };
  }
}

class RichClosedCorrectionViewModel {
  const RichClosedCorrectionViewModel({
    required this.summary,
    required this.items,
  });

  final RichClosedResultSummaryViewModel summary;
  final List<RichClosedCorrectionItemViewModel> items;
}

class RichClosedResultSummaryViewModel {
  const RichClosedResultSummaryViewModel({
    required this.sessionId,
    required this.status,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
  });

  final String sessionId;
  final String status;
  final int correctAnswers;
  final int totalQuestions;
  final double score;

  String get scoreLabel => score.toString();
  String get answerRatioLabel => '$correctAnswers / $totalQuestions';

  String get message {
    if (score >= 0.85) {
      return 'Excellent résultat.';
    }
    if (score >= 0.6) {
      return 'Solide, avec quelques points à consolider.';
    }
    return 'À retravailler en priorité.';
  }
}

class RichClosedCorrectionItemViewModel {
  const RichClosedCorrectionItemViewModel({
    required this.questionId,
    required this.questionKind,
    required this.kindLabel,
    required this.prompt,
    required this.contextText,
    required this.isCorrect,
    required this.partialScore,
    required this.explanation,
    required this.sourceLabels,
    required this.submittedAnswerLines,
    required this.correctAnswerLines,
  });

  final String questionId;
  final RichClosedQuestionKind questionKind;
  final String kindLabel;
  final String prompt;
  final String? contextText;
  final bool isCorrect;
  final double partialScore;
  final String explanation;
  final List<String> sourceLabels;
  final List<String> submittedAnswerLines;
  final List<String> correctAnswerLines;

  String get statusLabel => isCorrect ? 'Correct' : 'Incorrect';
  String get partialScoreLabel => partialScore.toString();
}
