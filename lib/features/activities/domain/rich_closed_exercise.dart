const richClosedExerciseType = 'rich_closed_exercise';
const richClosedExerciseVersion = 'rich-closed-question-v1';

class RichClosedExerciseParseException implements Exception {
  const RichClosedExerciseParseException(this.message);

  final String message;

  @override
  String toString() => 'RichClosedExerciseParseException: $message';
}

enum RichClosedQuestionKind {
  singleChoice('single_choice'),
  multipleChoice('multiple_choice'),
  matching('matching'),
  ordering('ordering'),
  caseQualification('case_qualification'),
  errorDetection('error_detection'),
  timeline('timeline'),
  dateSlider('date_slider'),
  trueFalseGrid('true_false_grid'),
  causeConsequence('cause_consequence'),
  institutionMatrix('institution_matrix'),
  diagramLabeling('diagram_labeling'),
  calculationMcq('calculation_mcq');

  const RichClosedQuestionKind(this.wireValue);

  final String wireValue;

  static RichClosedQuestionKind parse(Object? value) {
    for (final kind in values) {
      if (value == kind.wireValue) {
        return kind;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed question kind',
    );
  }
}

enum RichClosedDifficulty {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH');

  const RichClosedDifficulty(this.wireValue);

  final String wireValue;

  static RichClosedDifficulty parse(Object? value) {
    for (final difficulty in values) {
      if (value == difficulty.wireValue) {
        return difficulty;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed difficulty',
    );
  }
}

enum RichClosedCognitiveSkill {
  memorization('memorization'),
  comprehension('comprehension'),
  comparison('comparison'),
  classification('classification'),
  caseApplication('case_application'),
  procedure('procedure'),
  errorDetection('error_detection'),
  causality('causality');

  const RichClosedCognitiveSkill(this.wireValue);

  final String wireValue;

  static RichClosedCognitiveSkill parse(Object? value) {
    for (final skill in values) {
      if (value == skill.wireValue) {
        return skill;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed cognitive skill',
    );
  }
}

enum RichClosedDiagramLayout {
  verticalFlow('vertical_flow'),
  twoColumn('two_column'),
  cycle('cycle'),
  hierarchy('hierarchy'),
  plain('plain');

  const RichClosedDiagramLayout(this.wireValue);

  final String wireValue;

  static RichClosedDiagramLayout parse(Object? value) {
    for (final layout in values) {
      if (value == layout.wireValue) {
        return layout;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed diagram layout',
    );
  }
}

enum RichClosedDiagramAnchorType {
  node('node'),
  edge('edge');

  const RichClosedDiagramAnchorType(this.wireValue);

  final String wireValue;

  static RichClosedDiagramAnchorType parse(Object? value) {
    for (final type in values) {
      if (value == type.wireValue) {
        return type;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed diagram anchor type',
    );
  }
}

enum RichClosedCalculationMode {
  absoluteMajorityThreshold('absolute_majority_threshold'),
  largestRemainderTargetPartySeats('largest_remainder_target_party_seats');

  const RichClosedCalculationMode(this.wireValue);

  final String wireValue;

  static RichClosedCalculationMode parse(Object? value) {
    for (final mode in values) {
      if (value == mode.wireValue) {
        return mode;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed calculation mode',
    );
  }
}

enum RichClosedComplexityProfile {
  standard('standard'),
  exam('exam'),
  advanced('advanced');

  const RichClosedComplexityProfile(this.wireValue);

  final String wireValue;
}

class RichClosedExercise {
  const RichClosedExercise({
    required this.sessionId,
    required this.type,
    required this.id,
    required this.version,
    required this.title,
    required this.subjectId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.questions,
  });

  factory RichClosedExercise.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed exercise response');
    _assertNoPreSubmitLeaks(json);

    final type = _readString(json['type'], 'Invalid rich closed exercise type');
    final version = _readString(
      json['version'],
      'Invalid rich closed exercise version',
    );
    final questions = _readList(
      json['questions'],
      'Invalid rich closed exercise questions',
    );

    if (type != richClosedExerciseType ||
        version != richClosedExerciseVersion) {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed exercise envelope',
      );
    }

    if (questions.isEmpty) {
      throw const RichClosedExerciseParseException(
        'Rich closed exercise must contain questions',
      );
    }

    return RichClosedExercise(
      sessionId: _readString(
        json['sessionId'],
        'Invalid rich closed exercise session id',
      ),
      type: type,
      id: _readString(json['id'], 'Invalid rich closed exercise id'),
      version: version,
      title: _readString(json['title'], 'Invalid rich closed exercise title'),
      subjectId: _readString(
        json['subjectId'],
        'Invalid rich closed exercise subject id',
      ),
      documentId: _readOptionalString(json['documentId']),
      knowledgeUnitId: _readString(
        json['knowledgeUnitId'],
        'Invalid rich closed exercise knowledge unit id',
      ),
      questions: questions
          .map(RichClosedQuestion.fromJson)
          .toList(growable: false),
    );
  }

  final String sessionId;
  final String type;
  final String id;
  final String version;
  final String title;
  final String subjectId;
  final String? documentId;
  final String knowledgeUnitId;
  final List<RichClosedQuestion> questions;
}

sealed class RichClosedQuestion {
  const RichClosedQuestion({
    required this.id,
    required this.questionKind,
    required this.prompt,
    required this.difficulty,
    required this.cognitiveSkill,
    required this.sourceChunkIds,
  });

  factory RichClosedQuestion.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed question response');
    final kind = RichClosedQuestionKind.parse(json['questionKind']);
    final base = RichClosedQuestionBase.fromJson(json, kind);

    return switch (kind) {
      RichClosedQuestionKind.singleChoice => RichClosedSingleChoiceQuestion(
        base: base,
        choices: _choices(json['choices']),
      ),
      RichClosedQuestionKind.multipleChoice => RichClosedMultipleChoiceQuestion(
        base: base,
        choices: _choices(json['choices']),
        minSelections: _readInt(
          json['minSelections'],
          'Invalid multiple choice min selections',
        ),
        maxSelections: _readInt(
          json['maxSelections'],
          'Invalid multiple choice max selections',
        ),
      ).._validateSelectionBounds(),
      RichClosedQuestionKind.matching => RichClosedMatchingQuestion(
        base: base,
        leftItems: _labelItems(json['leftItems'], 'Invalid matching left'),
        rightItems: _labelItems(json['rightItems'], 'Invalid matching right'),
      ),
      RichClosedQuestionKind.ordering => RichClosedOrderingQuestion(
        base: base,
        items: _labelItems(json['items'], 'Invalid ordering items'),
      ),
      RichClosedQuestionKind.timeline => RichClosedTimelineQuestion(
        base: base,
        instruction: _readOptionalString(json['instruction']),
        events: _timelineEvents(json['events']),
      ).._validateEvents(),
      RichClosedQuestionKind.dateSlider => RichClosedDateSliderQuestion(
        base: base,
        instruction: _readOptionalString(json['instruction']),
        minYear: _readInt(json['minYear'], 'Invalid date slider min year'),
        maxYear: _readInt(json['maxYear'], 'Invalid date slider max year'),
        step: _readInt(json['step'], 'Invalid date slider step'),
        toleranceYears: _readInt(
          json['toleranceYears'],
          'Invalid date slider tolerance',
        ),
      ).._validateBounds(),
      RichClosedQuestionKind.trueFalseGrid => RichClosedTrueFalseGridQuestion(
        base: base,
        instruction: _readOptionalString(json['instruction']),
        rows: _trueFalseRows(json['rows']),
      ).._validateRows(),
      RichClosedQuestionKind.causeConsequence =>
        RichClosedCauseConsequenceQuestion(
          base: base,
          instruction: _readOptionalString(json['instruction']),
          causes: _causeConsequenceItems(
            json['causes'],
            'Invalid cause/consequence causes',
          ),
          consequences: _causeConsequenceItems(
            json['consequences'],
            'Invalid cause/consequence consequences',
          ),
        ).._validateItems(),
      RichClosedQuestionKind.institutionMatrix =>
        RichClosedInstitutionMatrixQuestion(
          base: base,
          instruction: _readOptionalString(json['instruction']),
          rows: _institutionMatrixAxisItems(
            json['rows'],
            'Invalid institution matrix rows',
          ),
          columns: _institutionMatrixAxisItems(
            json['columns'],
            'Invalid institution matrix columns',
          ),
          cells: _institutionMatrixCells(json['cells']),
        ).._validateMatrix(),
      RichClosedQuestionKind.diagramLabeling =>
        RichClosedDiagramLabelingQuestion(
          base: base,
          instruction: _readOptionalString(json['instruction']),
          diagram: RichClosedDiagram.fromJson(json['diagram']),
          slots: _diagramLabelingSlots(json['slots']),
        ).._validateDiagram(),
      RichClosedQuestionKind.calculationMcq => RichClosedCalculationMcqQuestion(
        base: base,
        instruction: _readOptionalString(json['instruction']),
        scenario: _readString(json['scenario'], 'Invalid calculation scenario'),
        calculation: RichClosedCalculationData.fromJson(json['calculation']),
        choices: _calculationChoices(json['choices']),
      ).._validateCalculation(),
      RichClosedQuestionKind.caseQualification =>
        RichClosedCaseQualificationQuestion(
          base: base,
          caseText: _readString(
            json['caseText'],
            'Invalid case qualification text',
          ),
          choices: _choices(json['choices']),
        ),
      RichClosedQuestionKind.errorDetection => RichClosedErrorDetectionQuestion(
        base: base,
        statement: _readString(
          json['statement'],
          'Invalid error detection statement',
        ),
        errorOptions: _choices(json['errorOptions']),
      ),
    };
  }

  final String id;
  final RichClosedQuestionKind questionKind;
  final String prompt;
  final RichClosedDifficulty difficulty;
  final RichClosedCognitiveSkill cognitiveSkill;
  final List<String> sourceChunkIds;
}

class RichClosedSingleChoiceQuestion extends RichClosedQuestion {
  RichClosedSingleChoiceQuestion({
    required RichClosedQuestionBase base,
    required this.choices,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.singleChoice,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedChoice> choices;
}

class RichClosedMultipleChoiceQuestion extends RichClosedQuestion {
  RichClosedMultipleChoiceQuestion({
    required RichClosedQuestionBase base,
    required this.choices,
    required this.minSelections,
    required this.maxSelections,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.multipleChoice,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedChoice> choices;
  final int minSelections;
  final int maxSelections;

  void _validateSelectionBounds() {
    if (minSelections < 1 ||
        maxSelections < minSelections ||
        maxSelections > choices.length) {
      throw const RichClosedExerciseParseException(
        'Invalid multiple choice selection bounds',
      );
    }
  }
}

class RichClosedMatchingQuestion extends RichClosedQuestion {
  RichClosedMatchingQuestion({
    required RichClosedQuestionBase base,
    required this.leftItems,
    required this.rightItems,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.matching,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedLabelItem> leftItems;
  final List<RichClosedLabelItem> rightItems;
}

class RichClosedOrderingQuestion extends RichClosedQuestion {
  RichClosedOrderingQuestion({
    required RichClosedQuestionBase base,
    required this.items,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.ordering,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedLabelItem> items;
}

class RichClosedTimelineQuestion extends RichClosedQuestion {
  RichClosedTimelineQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.events,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.timeline,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final List<RichClosedTimelineEvent> events;

  void _validateEvents() {
    final eventIds = events.map((event) => event.id).toSet();
    if (events.length < 3 || eventIds.length != events.length) {
      throw const RichClosedExerciseParseException('Invalid timeline events');
    }
  }
}

class RichClosedDateSliderQuestion extends RichClosedQuestion {
  RichClosedDateSliderQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.minYear,
    required this.maxYear,
    required this.step,
    required this.toleranceYears,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.dateSlider,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final int minYear;
  final int maxYear;
  final int step;
  final int toleranceYears;

  void _validateBounds() {
    if (minYear >= maxYear || step < 1 || toleranceYears < 0) {
      throw const RichClosedExerciseParseException(
        'Invalid date slider bounds',
      );
    }
  }
}

class RichClosedTrueFalseGridQuestion extends RichClosedQuestion {
  RichClosedTrueFalseGridQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.rows,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.trueFalseGrid,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final List<RichClosedTrueFalseRow> rows;

  void _validateRows() {
    final rowIds = rows.map((row) => row.id).toSet();
    if (rows.length < 3 || rows.length > 8 || rowIds.length != rows.length) {
      throw const RichClosedExerciseParseException(
        'Invalid true/false grid rows',
      );
    }
  }
}

class RichClosedCauseConsequenceQuestion extends RichClosedQuestion {
  RichClosedCauseConsequenceQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.causes,
    required this.consequences,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.causeConsequence,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final List<RichClosedCauseConsequenceItem> causes;
  final List<RichClosedCauseConsequenceItem> consequences;

  void _validateItems() {
    final causeIds = causes.map((cause) => cause.id).toSet();
    final consequenceIds = consequences
        .map((consequence) => consequence.id)
        .toSet();
    if (causes.length < 3 ||
        consequences.length < 3 ||
        consequences.length < causes.length ||
        causeIds.length != causes.length ||
        consequenceIds.length != consequences.length) {
      throw const RichClosedExerciseParseException(
        'Invalid cause/consequence items',
      );
    }
  }
}

class RichClosedInstitutionMatrixQuestion extends RichClosedQuestion {
  RichClosedInstitutionMatrixQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.rows,
    required this.columns,
    required this.cells,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.institutionMatrix,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final List<RichClosedInstitutionMatrixAxisItem> rows;
  final List<RichClosedInstitutionMatrixAxisItem> columns;
  final List<RichClosedInstitutionMatrixCell> cells;

  void _validateMatrix() {
    final rowIds = rows.map((row) => row.id).toSet();
    final columnIds = columns.map((column) => column.id).toSet();
    final cellIds = cells.map((cell) => cell.id).toSet();

    if (rows.length < 2 ||
        rows.length > 5 ||
        rowIds.length != rows.length ||
        columns.length < 2 ||
        columns.length > 5 ||
        columnIds.length != columns.length ||
        cells.length < 3 ||
        cells.length > rows.length * columns.length ||
        cellIds.length != cells.length) {
      throw const RichClosedExerciseParseException(
        'Invalid institution matrix contract',
      );
    }

    final cellCoordinates = <String>{};
    for (final cell in cells) {
      final coordinate = '${cell.rowId}\u0000${cell.columnId}';
      final optionIds = cell.options.map((option) => option.id).toSet();
      if (!cellCoordinates.add(coordinate) ||
          !rowIds.contains(cell.rowId) ||
          !columnIds.contains(cell.columnId) ||
          cell.options.length < 2 ||
          cell.options.length > 6 ||
          optionIds.length != cell.options.length) {
        throw const RichClosedExerciseParseException(
          'Invalid institution matrix contract',
        );
      }
    }
  }
}

class RichClosedDiagramLabelingQuestion extends RichClosedQuestion {
  RichClosedDiagramLabelingQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.diagram,
    required this.slots,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.diagramLabeling,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final RichClosedDiagram diagram;
  final List<RichClosedDiagramLabelingSlot> slots;

  void _validateDiagram() {
    final nodeIds = diagram.nodes.map((node) => node.id).toSet();
    final groupIds = diagram.groups.map((group) => group.id).toSet();
    final edgeIds = diagram.edges.map((edge) => edge.id).toSet();
    final slotIds = slots.map((slot) => slot.id).toSet();

    if (diagram.nodes.length < 2 ||
        diagram.nodes.length > 8 ||
        nodeIds.length != diagram.nodes.length ||
        diagram.groups.length > 4 ||
        groupIds.length != diagram.groups.length ||
        diagram.edges.length > 12 ||
        edgeIds.length != diagram.edges.length ||
        slots.length < 2 ||
        slots.length > 8 ||
        slotIds.length != slots.length) {
      throw const RichClosedExerciseParseException(
        'Invalid diagram labeling contract',
      );
    }

    for (final node in diagram.nodes) {
      final groupId = node.groupId;
      if (groupId != null && !groupIds.contains(groupId)) {
        throw const RichClosedExerciseParseException(
          'Invalid diagram labeling contract',
        );
      }
    }

    for (final edge in diagram.edges) {
      if (!nodeIds.contains(edge.fromNodeId) ||
          !nodeIds.contains(edge.toNodeId)) {
        throw const RichClosedExerciseParseException(
          'Invalid diagram labeling contract',
        );
      }
    }

    for (final slot in slots) {
      final optionIds = slot.options.map((option) => option.id).toSet();
      final anchorExists = switch (slot.anchorType) {
        RichClosedDiagramAnchorType.node => nodeIds.contains(slot.anchorId),
        RichClosedDiagramAnchorType.edge => edgeIds.contains(slot.anchorId),
      };

      if (!anchorExists ||
          slot.options.length < 2 ||
          slot.options.length > 6 ||
          optionIds.length != slot.options.length) {
        throw const RichClosedExerciseParseException(
          'Invalid diagram labeling contract',
        );
      }
    }
  }
}

class RichClosedCalculationMcqQuestion extends RichClosedQuestion {
  RichClosedCalculationMcqQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.scenario,
    required this.calculation,
    required this.choices,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.calculationMcq,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final String scenario;
  final RichClosedCalculationData calculation;
  final List<RichClosedCalculationChoice> choices;

  void _validateCalculation() {
    final choiceIds = choices.map((choice) => choice.id).toSet();
    final choiceValues = choices.map((choice) => choice.value).toSet();

    if (choices.length < 2 ||
        choices.length > 6 ||
        choiceIds.length != choices.length ||
        choiceValues.length != choices.length) {
      throw const RichClosedExerciseParseException(
        'Invalid calculation choices',
      );
    }

    switch (calculation) {
      case RichClosedAbsoluteMajorityThresholdCalculation(:final validVotes):
        if (validVotes < 1) {
          throw const RichClosedExerciseParseException(
            'Invalid calculation data',
          );
        }
      case RichClosedLargestRemainderTargetPartySeatsCalculation(
        :final totalSeats,
        :final targetPartyId,
        :final parties,
      ):
        final partyIds = parties.map((party) => party.id).toSet();
        if (totalSeats < 1 ||
            parties.length < 2 ||
            parties.length > 8 ||
            partyIds.length != parties.length ||
            !partyIds.contains(targetPartyId) ||
            parties.any((party) => party.votes < 0)) {
          throw const RichClosedExerciseParseException(
            'Invalid calculation data',
          );
        }
    }
  }
}

class RichClosedCaseQualificationQuestion extends RichClosedQuestion {
  RichClosedCaseQualificationQuestion({
    required RichClosedQuestionBase base,
    required this.caseText,
    required this.choices,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.caseQualification,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String caseText;
  final List<RichClosedChoice> choices;
}

class RichClosedErrorDetectionQuestion extends RichClosedQuestion {
  RichClosedErrorDetectionQuestion({
    required RichClosedQuestionBase base,
    required this.statement,
    required this.errorOptions,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.errorDetection,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String statement;
  final List<RichClosedChoice> errorOptions;
}

class RichClosedQuestionBase {
  const RichClosedQuestionBase({
    required this.id,
    required this.prompt,
    required this.difficulty,
    required this.cognitiveSkill,
    required this.sourceChunkIds,
  });

  factory RichClosedQuestionBase.fromJson(
    Map<String, Object?> json,
    RichClosedQuestionKind kind,
  ) {
    return RichClosedQuestionBase(
      id: _readString(json['id'], 'Invalid rich closed question id'),
      prompt: _readString(
        json['prompt'],
        'Invalid rich closed question prompt',
      ),
      difficulty: RichClosedDifficulty.parse(json['difficulty']),
      cognitiveSkill: RichClosedCognitiveSkill.parse(json['cognitiveSkill']),
      sourceChunkIds: _stringList(
        json['sourceChunkIds'],
        'Invalid rich closed source chunk ids',
      ),
    );
  }

  final String id;
  final String prompt;
  final RichClosedDifficulty difficulty;
  final RichClosedCognitiveSkill cognitiveSkill;
  final List<String> sourceChunkIds;
}

class RichClosedChoice {
  const RichClosedChoice({required this.id, required this.label});

  factory RichClosedChoice.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed choice');
    if (json.containsKey('feedback')) {
      throw const RichClosedExerciseParseException(
        'Rich closed pre-submit choices cannot contain feedback',
      );
    }

    return RichClosedChoice(
      id: _readString(json['id'], 'Invalid rich closed choice id'),
      label: _readString(json['label'], 'Invalid rich closed choice label'),
    );
  }

  final String id;
  final String label;
}

class RichClosedLabelItem {
  const RichClosedLabelItem({required this.id, required this.label});

  factory RichClosedLabelItem.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed label item');

    return RichClosedLabelItem(
      id: _readString(json['id'], 'Invalid rich closed label item id'),
      label: _readString(json['label'], 'Invalid rich closed label item label'),
    );
  }

  final String id;
  final String label;
}

class RichClosedTimelineEvent {
  const RichClosedTimelineEvent({
    required this.id,
    required this.label,
    required this.description,
  });

  factory RichClosedTimelineEvent.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed timeline event');

    return RichClosedTimelineEvent(
      id: _readString(json['id'], 'Invalid rich closed timeline event id'),
      label: _readString(
        json['label'],
        'Invalid rich closed timeline event label',
      ),
      description: _readOptionalString(json['description']),
    );
  }

  final String id;
  final String label;
  final String? description;
}

class RichClosedTrueFalseRow {
  const RichClosedTrueFalseRow({
    required this.id,
    required this.statement,
    required this.context,
  });

  factory RichClosedTrueFalseRow.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed true/false row');

    return RichClosedTrueFalseRow(
      id: _readString(json['id'], 'Invalid true/false row id'),
      statement: _readString(
        json['statement'],
        'Invalid true/false row statement',
      ),
      context: _readOptionalString(json['context']),
    );
  }

  final String id;
  final String statement;
  final String? context;
}

class RichClosedTrueFalseGridValue {
  const RichClosedTrueFalseGridValue({
    required this.rowId,
    required this.value,
  });

  factory RichClosedTrueFalseGridValue.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed true/false value');

    return RichClosedTrueFalseGridValue(
      rowId: _readString(json['rowId'], 'Invalid true/false row id'),
      value: _readBool(json['value'], 'Invalid true/false value'),
    );
  }

  Map<String, Object?> toJson() => {'rowId': rowId, 'value': value};

  final String rowId;
  final bool value;
}

class RichClosedCauseConsequenceItem {
  const RichClosedCauseConsequenceItem({
    required this.id,
    required this.label,
    required this.description,
  });

  factory RichClosedCauseConsequenceItem.fromJson(Object? value) {
    final json = _readObject(
      value,
      'Invalid rich closed cause/consequence item',
    );

    return RichClosedCauseConsequenceItem(
      id: _readString(json['id'], 'Invalid cause/consequence item id'),
      label: _readString(json['label'], 'Invalid cause/consequence item label'),
      description: _readOptionalString(json['description']),
    );
  }

  final String id;
  final String label;
  final String? description;
}

class RichClosedCauseConsequencePair {
  const RichClosedCauseConsequencePair({
    required this.causeId,
    required this.consequenceId,
  });

  factory RichClosedCauseConsequencePair.fromJson(Object? value) {
    final json = _readObject(
      value,
      'Invalid rich closed cause/consequence pair',
    );

    return RichClosedCauseConsequencePair(
      causeId: _readString(json['causeId'], 'Invalid cause id'),
      consequenceId: _readString(
        json['consequenceId'],
        'Invalid consequence id',
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'causeId': causeId,
    'consequenceId': consequenceId,
  };

  final String causeId;
  final String consequenceId;
}

class RichClosedInstitutionMatrixAxisItem {
  const RichClosedInstitutionMatrixAxisItem({
    required this.id,
    required this.label,
    required this.description,
  });

  factory RichClosedInstitutionMatrixAxisItem.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid institution matrix axis item');

    return RichClosedInstitutionMatrixAxisItem(
      id: _readString(json['id'], 'Invalid institution matrix axis id'),
      label: _readString(
        json['label'],
        'Invalid institution matrix axis label',
      ),
      description: _readOptionalString(json['description']),
    );
  }

  final String id;
  final String label;
  final String? description;
}

class RichClosedInstitutionMatrixCell {
  const RichClosedInstitutionMatrixCell({
    required this.id,
    required this.rowId,
    required this.columnId,
    required this.prompt,
    required this.options,
  });

  factory RichClosedInstitutionMatrixCell.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid institution matrix cell');

    return RichClosedInstitutionMatrixCell(
      id: _readString(json['id'], 'Invalid institution matrix cell id'),
      rowId: _readString(json['rowId'], 'Invalid institution matrix row id'),
      columnId: _readString(
        json['columnId'],
        'Invalid institution matrix column id',
      ),
      prompt: _readOptionalString(json['prompt']),
      options: _choices(json['options']),
    );
  }

  final String id;
  final String rowId;
  final String columnId;
  final String? prompt;
  final List<RichClosedChoice> options;
}

class RichClosedInstitutionMatrixValue {
  const RichClosedInstitutionMatrixValue({
    required this.cellId,
    required this.optionId,
  });

  factory RichClosedInstitutionMatrixValue.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid institution matrix value');

    return RichClosedInstitutionMatrixValue(
      cellId: _readString(json['cellId'], 'Invalid institution matrix cell id'),
      optionId: _readString(
        json['optionId'],
        'Invalid institution matrix option id',
      ),
    );
  }

  Map<String, Object?> toJson() => {'cellId': cellId, 'optionId': optionId};

  final String cellId;
  final String optionId;
}

class RichClosedDiagram {
  const RichClosedDiagram({
    required this.title,
    required this.description,
    required this.layout,
    required this.nodes,
    required this.groups,
    required this.edges,
  });

  factory RichClosedDiagram.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed diagram');

    return RichClosedDiagram(
      title: _readOptionalString(json['title']),
      description: _readOptionalString(json['description']),
      layout: RichClosedDiagramLayout.parse(json['layout']),
      nodes: _diagramNodes(json['nodes']),
      groups: _diagramGroups(json['groups']),
      edges: _diagramEdges(json['edges']),
    );
  }

  final String? title;
  final String? description;
  final RichClosedDiagramLayout layout;
  final List<RichClosedDiagramNode> nodes;
  final List<RichClosedDiagramGroup> groups;
  final List<RichClosedDiagramEdge> edges;
}

class RichClosedDiagramGroup {
  const RichClosedDiagramGroup({
    required this.id,
    required this.label,
    required this.description,
  });

  factory RichClosedDiagramGroup.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed diagram group');

    return RichClosedDiagramGroup(
      id: _readString(json['id'], 'Invalid diagram group id'),
      label: _readString(json['label'], 'Invalid diagram group label'),
      description: _readOptionalString(json['description']),
    );
  }

  final String id;
  final String label;
  final String? description;
}

class RichClosedDiagramNode {
  const RichClosedDiagramNode({
    required this.id,
    required this.label,
    required this.description,
    required this.groupId,
  });

  factory RichClosedDiagramNode.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed diagram node');

    return RichClosedDiagramNode(
      id: _readString(json['id'], 'Invalid diagram node id'),
      label: _readString(json['label'], 'Invalid diagram node label'),
      description: _readOptionalString(json['description']),
      groupId: _readOptionalString(json['groupId']),
    );
  }

  final String id;
  final String label;
  final String? description;
  final String? groupId;
}

class RichClosedDiagramEdge {
  const RichClosedDiagramEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.label,
    required this.description,
  });

  factory RichClosedDiagramEdge.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed diagram edge');

    return RichClosedDiagramEdge(
      id: _readString(json['id'], 'Invalid diagram edge id'),
      fromNodeId: _readString(
        json['fromNodeId'],
        'Invalid diagram edge source node id',
      ),
      toNodeId: _readString(
        json['toNodeId'],
        'Invalid diagram edge target node id',
      ),
      label: _readOptionalString(json['label']),
      description: _readOptionalString(json['description']),
    );
  }

  final String id;
  final String fromNodeId;
  final String toNodeId;
  final String? label;
  final String? description;
}

class RichClosedDiagramLabelingSlot {
  const RichClosedDiagramLabelingSlot({
    required this.id,
    required this.anchorType,
    required this.anchorId,
    required this.prompt,
    required this.options,
  });

  factory RichClosedDiagramLabelingSlot.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed diagram slot');

    return RichClosedDiagramLabelingSlot(
      id: _readString(json['id'], 'Invalid diagram slot id'),
      anchorType: RichClosedDiagramAnchorType.parse(json['anchorType']),
      anchorId: _readString(json['anchorId'], 'Invalid diagram anchor id'),
      prompt: _readString(json['prompt'], 'Invalid diagram slot prompt'),
      options: _choices(json['options']),
    );
  }

  final String id;
  final RichClosedDiagramAnchorType anchorType;
  final String anchorId;
  final String prompt;
  final List<RichClosedChoice> options;
}

class RichClosedDiagramLabelingValue {
  const RichClosedDiagramLabelingValue({
    required this.slotId,
    required this.optionId,
  });

  factory RichClosedDiagramLabelingValue.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid diagram labeling value');

    return RichClosedDiagramLabelingValue(
      slotId: _readString(json['slotId'], 'Invalid diagram slot id'),
      optionId: _readString(json['optionId'], 'Invalid diagram option id'),
    );
  }

  Map<String, Object?> toJson() => {'slotId': slotId, 'optionId': optionId};

  final String slotId;
  final String optionId;
}

sealed class RichClosedCalculationData {
  const RichClosedCalculationData({required this.mode});

  factory RichClosedCalculationData.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed calculation data');
    final mode = RichClosedCalculationMode.parse(json['mode']);

    return switch (mode) {
      RichClosedCalculationMode.absoluteMajorityThreshold =>
        RichClosedAbsoluteMajorityThresholdCalculation(
          validVotes: _readInt(
            json['validVotes'],
            'Invalid calculation valid votes',
          ),
        ),
      RichClosedCalculationMode.largestRemainderTargetPartySeats =>
        RichClosedLargestRemainderTargetPartySeatsCalculation(
          totalSeats: _readInt(
            json['totalSeats'],
            'Invalid calculation total seats',
          ),
          targetPartyId: _readString(
            json['targetPartyId'],
            'Invalid calculation target party',
          ),
          parties: _calculationParties(json['parties']),
        ),
    };
  }

  final RichClosedCalculationMode mode;
}

class RichClosedAbsoluteMajorityThresholdCalculation
    extends RichClosedCalculationData {
  const RichClosedAbsoluteMajorityThresholdCalculation({
    required this.validVotes,
  }) : super(mode: RichClosedCalculationMode.absoluteMajorityThreshold);

  final int validVotes;
}

class RichClosedLargestRemainderTargetPartySeatsCalculation
    extends RichClosedCalculationData {
  const RichClosedLargestRemainderTargetPartySeatsCalculation({
    required this.totalSeats,
    required this.targetPartyId,
    required this.parties,
  }) : super(mode: RichClosedCalculationMode.largestRemainderTargetPartySeats);

  final int totalSeats;
  final String targetPartyId;
  final List<RichClosedCalculationParty> parties;
}

class RichClosedCalculationParty {
  const RichClosedCalculationParty({
    required this.id,
    required this.label,
    required this.votes,
  });

  factory RichClosedCalculationParty.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid calculation party');

    return RichClosedCalculationParty(
      id: _readString(json['id'], 'Invalid calculation party id'),
      label: _readString(json['label'], 'Invalid calculation party label'),
      votes: _readInt(json['votes'], 'Invalid calculation party votes'),
    );
  }

  final String id;
  final String label;
  final int votes;
}

class RichClosedCalculationChoice {
  const RichClosedCalculationChoice({
    required this.id,
    required this.label,
    required this.value,
  });

  factory RichClosedCalculationChoice.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid calculation choice');

    return RichClosedCalculationChoice(
      id: _readString(json['id'], 'Invalid calculation choice id'),
      label: _readString(json['label'], 'Invalid calculation choice label'),
      value: _readInt(json['value'], 'Invalid calculation choice value'),
    );
  }

  final String id;
  final String label;
  final int value;
}

class RichClosedCalculationWorkedStep {
  const RichClosedCalculationWorkedStep({
    required this.id,
    required this.label,
    required this.detail,
    required this.value,
  });

  factory RichClosedCalculationWorkedStep.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid calculation worked step');

    return RichClosedCalculationWorkedStep(
      id: _readString(json['id'], 'Invalid calculation worked step id'),
      label: _readString(
        json['label'],
        'Invalid calculation worked step label',
      ),
      detail: _readString(
        json['detail'],
        'Invalid calculation worked step detail',
      ),
      value: json.containsKey('value')
          ? _readInt(json['value'], 'Invalid calculation worked step value')
          : null,
    );
  }

  final String id;
  final String label;
  final String detail;
  final int? value;
}

class RichClosedPair {
  const RichClosedPair({required this.leftId, required this.rightId});

  factory RichClosedPair.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed pair');

    return RichClosedPair(
      leftId: _readString(json['leftId'], 'Invalid rich closed pair left id'),
      rightId: _readString(
        json['rightId'],
        'Invalid rich closed pair right id',
      ),
    );
  }

  Map<String, Object?> toJson() => {'leftId': leftId, 'rightId': rightId};

  final String leftId;
  final String rightId;
}

sealed class RichClosedAnswer {
  const RichClosedAnswer({
    required this.questionId,
    required this.questionKind,
  });

  factory RichClosedAnswer.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed answer');
    _assertNoAnswerLeaks(json);

    final questionId = _readString(json['questionId'], 'Invalid answer id');
    final kind = RichClosedQuestionKind.parse(json['questionKind']);

    return switch (kind) {
      RichClosedQuestionKind.singleChoice => RichClosedSingleChoiceAnswer(
        questionId: questionId,
        choiceId: _readString(json['choiceId'], 'Invalid single choice answer'),
      ),
      RichClosedQuestionKind.multipleChoice => RichClosedMultipleChoiceAnswer(
        questionId: questionId,
        choiceIds: _nonEmptyStringList(
          json['choiceIds'],
          'Invalid multiple choice answer',
        ),
      ),
      RichClosedQuestionKind.matching => RichClosedMatchingAnswer(
        questionId: questionId,
        pairs: _pairs(json['pairs']),
      ),
      RichClosedQuestionKind.ordering => RichClosedOrderingAnswer(
        questionId: questionId,
        orderedIds: _nonEmptyStringList(
          json['orderedIds'],
          'Invalid ordering answer',
        ),
      ),
      RichClosedQuestionKind.timeline => RichClosedTimelineAnswer(
        questionId: questionId,
        orderedEventIds: _nonEmptyStringList(
          json['orderedEventIds'],
          'Invalid timeline answer',
        ),
      ),
      RichClosedQuestionKind.dateSlider => RichClosedDateSliderAnswer(
        questionId: questionId,
        year: _readInt(json['year'], 'Invalid date slider answer'),
      ),
      RichClosedQuestionKind.trueFalseGrid => RichClosedTrueFalseGridAnswer(
        questionId: questionId,
        values: _trueFalseValues(json['values']),
      ),
      RichClosedQuestionKind.causeConsequence =>
        RichClosedCauseConsequenceAnswer(
          questionId: questionId,
          pairs: _causeConsequencePairs(json['pairs']),
        ),
      RichClosedQuestionKind.institutionMatrix =>
        RichClosedInstitutionMatrixAnswer(
          questionId: questionId,
          values: _institutionMatrixValues(json['values']),
        ),
      RichClosedQuestionKind.diagramLabeling => RichClosedDiagramLabelingAnswer(
        questionId: questionId,
        values: _diagramLabelingValues(json['values']),
      ),
      RichClosedQuestionKind.calculationMcq => RichClosedCalculationMcqAnswer(
        questionId: questionId,
        choiceId: _readString(json['choiceId'], 'Invalid calculation answer'),
      ),
      RichClosedQuestionKind.caseQualification =>
        RichClosedCaseQualificationAnswer(
          questionId: questionId,
          choiceId: _readString(
            json['choiceId'],
            'Invalid case qualification answer',
          ),
        ),
      RichClosedQuestionKind.errorDetection => RichClosedErrorDetectionAnswer(
        questionId: questionId,
        errorId: _readString(json['errorId'], 'Invalid error detection answer'),
      ),
    };
  }

  final String questionId;
  final RichClosedQuestionKind questionKind;

  Map<String, Object?> toJson();
}

class RichClosedSingleChoiceAnswer extends RichClosedAnswer {
  const RichClosedSingleChoiceAnswer({
    required super.questionId,
    required this.choiceId,
  }) : super(questionKind: RichClosedQuestionKind.singleChoice);

  final String choiceId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceId': choiceId,
  };
}

class RichClosedMultipleChoiceAnswer extends RichClosedAnswer {
  const RichClosedMultipleChoiceAnswer({
    required super.questionId,
    required this.choiceIds,
  }) : super(questionKind: RichClosedQuestionKind.multipleChoice);

  final List<String> choiceIds;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceIds': choiceIds,
  };
}

class RichClosedMatchingAnswer extends RichClosedAnswer {
  const RichClosedMatchingAnswer({
    required super.questionId,
    required this.pairs,
  }) : super(questionKind: RichClosedQuestionKind.matching);

  final List<RichClosedPair> pairs;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'pairs': [for (final pair in pairs) pair.toJson()],
  };
}

class RichClosedOrderingAnswer extends RichClosedAnswer {
  const RichClosedOrderingAnswer({
    required super.questionId,
    required this.orderedIds,
  }) : super(questionKind: RichClosedQuestionKind.ordering);

  final List<String> orderedIds;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'orderedIds': orderedIds,
  };
}

class RichClosedTimelineAnswer extends RichClosedAnswer {
  const RichClosedTimelineAnswer({
    required super.questionId,
    required this.orderedEventIds,
  }) : super(questionKind: RichClosedQuestionKind.timeline);

  final List<String> orderedEventIds;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'orderedEventIds': orderedEventIds,
  };
}

class RichClosedDateSliderAnswer extends RichClosedAnswer {
  const RichClosedDateSliderAnswer({
    required super.questionId,
    required this.year,
  }) : super(questionKind: RichClosedQuestionKind.dateSlider);

  final int year;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'year': year,
  };
}

class RichClosedTrueFalseGridAnswer extends RichClosedAnswer {
  const RichClosedTrueFalseGridAnswer({
    required super.questionId,
    required this.values,
  }) : super(questionKind: RichClosedQuestionKind.trueFalseGrid);

  final List<RichClosedTrueFalseGridValue> values;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'values': [for (final value in values) value.toJson()],
  };
}

class RichClosedCauseConsequenceAnswer extends RichClosedAnswer {
  const RichClosedCauseConsequenceAnswer({
    required super.questionId,
    required this.pairs,
  }) : super(questionKind: RichClosedQuestionKind.causeConsequence);

  final List<RichClosedCauseConsequencePair> pairs;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'pairs': [for (final pair in pairs) pair.toJson()],
  };
}

class RichClosedInstitutionMatrixAnswer extends RichClosedAnswer {
  const RichClosedInstitutionMatrixAnswer({
    required super.questionId,
    required this.values,
  }) : super(questionKind: RichClosedQuestionKind.institutionMatrix);

  final List<RichClosedInstitutionMatrixValue> values;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'values': [for (final value in values) value.toJson()],
  };
}

class RichClosedDiagramLabelingAnswer extends RichClosedAnswer {
  const RichClosedDiagramLabelingAnswer({
    required super.questionId,
    required this.values,
  }) : super(questionKind: RichClosedQuestionKind.diagramLabeling);

  final List<RichClosedDiagramLabelingValue> values;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'values': [for (final value in values) value.toJson()],
  };
}

class RichClosedCalculationMcqAnswer extends RichClosedAnswer {
  const RichClosedCalculationMcqAnswer({
    required super.questionId,
    required this.choiceId,
  }) : super(questionKind: RichClosedQuestionKind.calculationMcq);

  final String choiceId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceId': choiceId,
  };
}

class RichClosedCaseQualificationAnswer extends RichClosedAnswer {
  const RichClosedCaseQualificationAnswer({
    required super.questionId,
    required this.choiceId,
  }) : super(questionKind: RichClosedQuestionKind.caseQualification);

  final String choiceId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceId': choiceId,
  };
}

class RichClosedErrorDetectionAnswer extends RichClosedAnswer {
  const RichClosedErrorDetectionAnswer({
    required super.questionId,
    required this.errorId,
  }) : super(questionKind: RichClosedQuestionKind.errorDetection);

  final String errorId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'errorId': errorId,
  };
}

class RichClosedExerciseSubmission {
  const RichClosedExerciseSubmission({required this.answers});

  final List<RichClosedAnswer> answers;

  Map<String, Object?> toJson() => {
    'answers': [for (final answer in answers) answer.toJson()],
  };
}

class RichClosedExerciseResult {
  const RichClosedExerciseResult({
    required this.sessionId,
    required this.type,
    required this.status,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.items,
  });

  factory RichClosedExerciseResult.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed result response');
    final type = _readString(json['type'], 'Invalid rich closed result type');
    final status = _readString(
      json['status'],
      'Invalid rich closed result status',
    );
    final score = json['score'];

    if (type != richClosedExerciseType || status != 'completed') {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed result envelope',
      );
    }

    if (score is! num) {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed result score',
      );
    }

    return RichClosedExerciseResult(
      sessionId: _readString(json['sessionId'], 'Invalid result session id'),
      type: type,
      status: status,
      correctAnswers: _readInt(
        json['correctAnswers'],
        'Invalid result correct answers',
      ),
      totalQuestions: _readInt(
        json['totalQuestions'],
        'Invalid result total questions',
      ),
      score: score.toDouble(),
      items: _readList(
        json['items'],
        'Invalid rich closed result items',
      ).map(RichClosedCorrectionItem.fromJson).toList(growable: false),
    );
  }

  final String sessionId;
  final String type;
  final String status;
  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final List<RichClosedCorrectionItem> items;
}

class RichClosedCorrectionItem {
  const RichClosedCorrectionItem({
    required this.questionId,
    required this.questionKind,
    required this.prompt,
    required this.submittedAnswer,
    required this.isCorrect,
    required this.partialScore,
    required this.explanation,
    required this.sourceChunkIds,
    required this.correction,
  });

  factory RichClosedCorrectionItem.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed correction item');
    final kind = RichClosedQuestionKind.parse(json['questionKind']);
    final partialScore = json['partialScore'];

    if (partialScore is! num) {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed correction partial score',
      );
    }

    return RichClosedCorrectionItem(
      questionId: _readString(json['questionId'], 'Invalid correction id'),
      questionKind: kind,
      prompt: _readString(json['prompt'], 'Invalid correction prompt'),
      submittedAnswer: RichClosedAnswer.fromJson(json['submittedAnswer']),
      isCorrect: _readBool(json['isCorrect'], 'Invalid correction status'),
      partialScore: partialScore.toDouble(),
      explanation: _readString(
        json['explanation'],
        'Invalid correction explanation',
      ),
      sourceChunkIds: _stringList(
        json['sourceChunkIds'],
        'Invalid correction sources',
      ),
      correction: RichClosedCorrectionPayload.fromJson(
        kind,
        json['correction'],
      ),
    );
  }

  final String questionId;
  final RichClosedQuestionKind questionKind;
  final String prompt;
  final RichClosedAnswer submittedAnswer;
  final bool isCorrect;
  final double partialScore;
  final String explanation;
  final List<String> sourceChunkIds;
  final RichClosedCorrectionPayload correction;
}

sealed class RichClosedCorrectionPayload {
  const RichClosedCorrectionPayload();

  factory RichClosedCorrectionPayload.fromJson(
    RichClosedQuestionKind kind,
    Object? value,
  ) {
    final json = _readObject(value, 'Invalid rich closed correction payload');

    return switch (kind) {
      RichClosedQuestionKind.singleChoice ||
      RichClosedQuestionKind.caseQualification =>
        RichClosedCorrectChoiceIdCorrection(
          correctChoiceId: _readString(
            json['correctChoiceId'],
            'Invalid correct choice id',
          ),
        ),
      RichClosedQuestionKind.multipleChoice =>
        RichClosedCorrectChoiceIdsCorrection(
          correctChoiceIds: _nonEmptyStringList(
            json['correctChoiceIds'],
            'Invalid correct choice ids',
          ),
        ),
      RichClosedQuestionKind.matching => RichClosedCorrectPairsCorrection(
        correctPairs: _pairs(json['correctPairs']),
      ),
      RichClosedQuestionKind.ordering => RichClosedCorrectOrderCorrection(
        correctOrder: _nonEmptyStringList(
          json['correctOrder'],
          'Invalid correct order',
        ),
      ),
      RichClosedQuestionKind.timeline => RichClosedCorrectOrderCorrection(
        correctOrder: _nonEmptyStringList(
          json['correctOrder'],
          'Invalid correct timeline order',
        ),
      ),
      RichClosedQuestionKind.dateSlider => RichClosedCorrectYearCorrection(
        correctYear: _readInt(json['correctYear'], 'Invalid correct year'),
        minAcceptedYear: _readInt(
          json['minAcceptedYear'],
          'Invalid minimum accepted year',
        ),
        maxAcceptedYear: _readInt(
          json['maxAcceptedYear'],
          'Invalid maximum accepted year',
        ),
      ),
      RichClosedQuestionKind.trueFalseGrid =>
        RichClosedCorrectTrueFalseValuesCorrection(
          correctValues: _trueFalseValues(json['correctValues']),
        ),
      RichClosedQuestionKind.causeConsequence =>
        RichClosedCorrectCauseConsequencePairsCorrection(
          correctPairs: _causeConsequencePairs(json['correctPairs']),
        ),
      RichClosedQuestionKind.institutionMatrix =>
        RichClosedCorrectInstitutionMatrixValuesCorrection(
          correctValues: _institutionMatrixValues(json['correctValues']),
        ),
      RichClosedQuestionKind.diagramLabeling =>
        RichClosedCorrectDiagramLabelingValuesCorrection(
          correctValues: _diagramLabelingValues(json['correctValues']),
        ),
      RichClosedQuestionKind.calculationMcq =>
        RichClosedCorrectCalculationMcqCorrection(
          correctChoiceId: _readString(
            json['correctChoiceId'],
            'Invalid correct calculation choice id',
          ),
          expectedValue: _readInt(
            json['expectedValue'],
            'Invalid calculation expected value',
          ),
          workedSteps: _calculationWorkedSteps(json['workedSteps']),
        ),
      RichClosedQuestionKind.errorDetection =>
        RichClosedCorrectErrorIdCorrection(
          correctErrorId: _readString(
            json['correctErrorId'],
            'Invalid correct error id',
          ),
        ),
    };
  }
}

class RichClosedCorrectChoiceIdCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectChoiceIdCorrection({required this.correctChoiceId});

  final String correctChoiceId;
}

class RichClosedCorrectChoiceIdsCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectChoiceIdsCorrection({required this.correctChoiceIds});

  final List<String> correctChoiceIds;
}

class RichClosedCorrectPairsCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectPairsCorrection({required this.correctPairs});

  final List<RichClosedPair> correctPairs;
}

class RichClosedCorrectOrderCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectOrderCorrection({required this.correctOrder});

  final List<String> correctOrder;
}

class RichClosedCorrectYearCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectYearCorrection({
    required this.correctYear,
    required this.minAcceptedYear,
    required this.maxAcceptedYear,
  });

  final int correctYear;
  final int minAcceptedYear;
  final int maxAcceptedYear;
}

class RichClosedCorrectTrueFalseValuesCorrection
    extends RichClosedCorrectionPayload {
  const RichClosedCorrectTrueFalseValuesCorrection({
    required this.correctValues,
  });

  final List<RichClosedTrueFalseGridValue> correctValues;
}

class RichClosedCorrectCauseConsequencePairsCorrection
    extends RichClosedCorrectionPayload {
  const RichClosedCorrectCauseConsequencePairsCorrection({
    required this.correctPairs,
  });

  final List<RichClosedCauseConsequencePair> correctPairs;
}

class RichClosedCorrectInstitutionMatrixValuesCorrection
    extends RichClosedCorrectionPayload {
  const RichClosedCorrectInstitutionMatrixValuesCorrection({
    required this.correctValues,
  });

  final List<RichClosedInstitutionMatrixValue> correctValues;
}

class RichClosedCorrectDiagramLabelingValuesCorrection
    extends RichClosedCorrectionPayload {
  const RichClosedCorrectDiagramLabelingValuesCorrection({
    required this.correctValues,
  });

  final List<RichClosedDiagramLabelingValue> correctValues;
}

class RichClosedCorrectCalculationMcqCorrection
    extends RichClosedCorrectionPayload {
  const RichClosedCorrectCalculationMcqCorrection({
    required this.correctChoiceId,
    required this.expectedValue,
    required this.workedSteps,
  });

  final String correctChoiceId;
  final int expectedValue;
  final List<RichClosedCalculationWorkedStep> workedSteps;
}

class RichClosedCorrectErrorIdCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectErrorIdCorrection({required this.correctErrorId});

  final String correctErrorId;
}

List<RichClosedChoice> _choices(Object? value) {
  final choices = _readList(
    value,
    'Invalid rich closed choices',
  ).map(RichClosedChoice.fromJson).toList(growable: false);

  if (choices.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed choices cannot be empty',
    );
  }

  return choices;
}

List<RichClosedLabelItem> _labelItems(Object? value, String message) {
  final items = _readList(
    value,
    message,
  ).map(RichClosedLabelItem.fromJson).toList(growable: false);

  if (items.isEmpty) {
    throw RichClosedExerciseParseException(message);
  }

  return items;
}

List<RichClosedTimelineEvent> _timelineEvents(Object? value) {
  final events = _readList(
    value,
    'Invalid rich closed timeline events',
  ).map(RichClosedTimelineEvent.fromJson).toList(growable: false);

  if (events.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed timeline events cannot be empty',
    );
  }

  return events;
}

List<RichClosedTrueFalseRow> _trueFalseRows(Object? value) {
  final rows = _readList(
    value,
    'Invalid rich closed true/false rows',
  ).map(RichClosedTrueFalseRow.fromJson).toList(growable: false);

  if (rows.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed true/false rows cannot be empty',
    );
  }

  return rows;
}

List<RichClosedTrueFalseGridValue> _trueFalseValues(Object? value) {
  final values = _readList(
    value,
    'Invalid rich closed true/false values',
  ).map(RichClosedTrueFalseGridValue.fromJson).toList(growable: false);

  if (values.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed true/false values cannot be empty',
    );
  }

  return values;
}

List<RichClosedCauseConsequenceItem> _causeConsequenceItems(
  Object? value,
  String message,
) {
  final items = _readList(
    value,
    message,
  ).map(RichClosedCauseConsequenceItem.fromJson).toList(growable: false);

  if (items.isEmpty) {
    throw RichClosedExerciseParseException(message);
  }

  return items;
}

List<RichClosedCauseConsequencePair> _causeConsequencePairs(Object? value) {
  final pairs = _readList(
    value,
    'Invalid rich closed cause/consequence pairs',
  ).map(RichClosedCauseConsequencePair.fromJson).toList(growable: false);

  if (pairs.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed cause/consequence pairs cannot be empty',
    );
  }

  return pairs;
}

List<RichClosedInstitutionMatrixAxisItem> _institutionMatrixAxisItems(
  Object? value,
  String message,
) {
  final items = _readList(
    value,
    message,
  ).map(RichClosedInstitutionMatrixAxisItem.fromJson).toList(growable: false);

  if (items.isEmpty) {
    throw RichClosedExerciseParseException(message);
  }

  return items;
}

List<RichClosedInstitutionMatrixCell> _institutionMatrixCells(Object? value) {
  final cells = _readList(
    value,
    'Invalid institution matrix cells',
  ).map(RichClosedInstitutionMatrixCell.fromJson).toList(growable: false);

  if (cells.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Institution matrix cells cannot be empty',
    );
  }

  return cells;
}

List<RichClosedInstitutionMatrixValue> _institutionMatrixValues(Object? value) {
  final values = _readList(
    value,
    'Invalid institution matrix values',
  ).map(RichClosedInstitutionMatrixValue.fromJson).toList(growable: false);

  if (values.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Institution matrix values cannot be empty',
    );
  }

  return values;
}

List<RichClosedDiagramNode> _diagramNodes(Object? value) {
  final nodes = _readList(
    value,
    'Invalid rich closed diagram nodes',
  ).map(RichClosedDiagramNode.fromJson).toList(growable: false);

  if (nodes.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed diagram nodes cannot be empty',
    );
  }

  return nodes;
}

List<RichClosedDiagramGroup> _diagramGroups(Object? value) {
  if (value == null) {
    return const [];
  }

  return _readList(
    value,
    'Invalid rich closed diagram groups',
  ).map(RichClosedDiagramGroup.fromJson).toList(growable: false);
}

List<RichClosedDiagramEdge> _diagramEdges(Object? value) {
  if (value == null) {
    return const [];
  }

  return _readList(
    value,
    'Invalid rich closed diagram edges',
  ).map(RichClosedDiagramEdge.fromJson).toList(growable: false);
}

List<RichClosedDiagramLabelingSlot> _diagramLabelingSlots(Object? value) {
  final slots = _readList(
    value,
    'Invalid diagram labeling slots',
  ).map(RichClosedDiagramLabelingSlot.fromJson).toList(growable: false);

  if (slots.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Diagram labeling slots cannot be empty',
    );
  }

  return slots;
}

List<RichClosedDiagramLabelingValue> _diagramLabelingValues(Object? value) {
  final values = _readList(
    value,
    'Invalid diagram labeling values',
  ).map(RichClosedDiagramLabelingValue.fromJson).toList(growable: false);

  if (values.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Diagram labeling values cannot be empty',
    );
  }

  return values;
}

List<RichClosedCalculationChoice> _calculationChoices(Object? value) {
  final choices = _readList(
    value,
    'Invalid calculation choices',
  ).map(RichClosedCalculationChoice.fromJson).toList(growable: false);

  if (choices.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Calculation choices cannot be empty',
    );
  }

  return choices;
}

List<RichClosedCalculationParty> _calculationParties(Object? value) {
  final parties = _readList(
    value,
    'Invalid calculation parties',
  ).map(RichClosedCalculationParty.fromJson).toList(growable: false);

  if (parties.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Calculation parties cannot be empty',
    );
  }

  return parties;
}

List<RichClosedCalculationWorkedStep> _calculationWorkedSteps(Object? value) {
  final steps = _readList(
    value,
    'Invalid calculation worked steps',
  ).map(RichClosedCalculationWorkedStep.fromJson).toList(growable: false);

  if (steps.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Calculation worked steps cannot be empty',
    );
  }

  return steps;
}

List<RichClosedPair> _pairs(Object? value) {
  final pairs = _readList(
    value,
    'Invalid rich closed pairs',
  ).map(RichClosedPair.fromJson).toList(growable: false);

  if (pairs.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed pairs cannot be empty',
    );
  }

  return pairs;
}

Map<String, Object?> _readObject(Object? value, String message) {
  if (value is Map<String, Object?>) {
    return value;
  }

  throw RichClosedExerciseParseException(message);
}

List<Object?> _readList(Object? value, String message) {
  if (value is List) {
    return value.cast<Object?>();
  }

  throw RichClosedExerciseParseException(message);
}

String _readString(Object? value, String message) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

  throw RichClosedExerciseParseException(message);
}

String? _readOptionalString(Object? value) {
  if (value == null) {
    return null;
  }

  return _readString(value, 'Invalid optional rich closed string');
}

int _readInt(Object? value, String message) {
  if (value is int) {
    return value;
  }

  throw RichClosedExerciseParseException(message);
}

bool _readBool(Object? value, String message) {
  if (value is bool) {
    return value;
  }

  throw RichClosedExerciseParseException(message);
}

List<String> _stringList(Object? value, String message) {
  return _readList(
    value,
    message,
  ).map((item) => _readString(item, message)).toList(growable: false);
}

List<String> _nonEmptyStringList(Object? value, String message) {
  final values = _stringList(value, message);
  if (values.isEmpty) {
    throw RichClosedExerciseParseException(message);
  }

  return values;
}

void _assertNoPreSubmitLeaks(Object? value) {
  if (_containsForbiddenPreSubmitField(value)) {
    throw const RichClosedExerciseParseException(
      'Rich closed pre-submit payload contains correction data',
    );
  }
}

void _assertNoAnswerLeaks(Object? value) {
  if (_containsForbiddenAnswerField(value)) {
    throw const RichClosedExerciseParseException(
      'Rich closed answer payload contains forbidden data',
    );
  }
}

bool _containsForbiddenPreSubmitField(Object? value) {
  return _containsForbiddenField(value, _forbiddenPreSubmitKeys);
}

bool _containsForbiddenAnswerField(Object? value) {
  return _containsForbiddenField(value, _forbiddenAnswerKeys);
}

bool _containsForbiddenField(Object? value, Set<String> forbiddenKeys) {
  if (value is List) {
    return value.any((item) => _containsForbiddenField(item, forbiddenKeys));
  }

  if (value is! Map) {
    return false;
  }

  for (final entry in value.entries) {
    final key = entry.key;
    if (key is String &&
        (key.startsWith('correct') || forbiddenKeys.contains(key))) {
      return true;
    }

    if (_containsForbiddenField(entry.value, forbiddenKeys)) {
      return true;
    }
  }

  return false;
}

const _forbiddenPreSubmitKeys = {
  'correctionPayload',
  'correction',
  'explanation',
  'feedback',
  'choiceFeedback',
  'modelAnswer',
  'answerText',
  'freeTextAnswer',
  'textAnswer',
  'score',
  'partialScore',
  'workedSteps',
  'expectedValue',
  'answersPayload',
  'expectedAnswer',
  'expectedAnswers',
  'html',
  'svg',
  'rawSvg',
  'mermaid',
  'markdown',
  'widget',
  'component',
  'render',
  'renderPayload',
  'style',
  'css',
  'script',
  'imageUrl',
  'assetUrl',
  'canvas',
  'code',
  'eval',
  'Function',
  'function',
  'formula',
  'expression',
  'rawFormula',
  'calculationCode',
  'javascript',
  'python',
  'markup',
};

const _forbiddenAnswerKeys = {
  'correctionPayload',
  'correction',
  'explanation',
  'feedback',
  'choiceFeedback',
  'modelAnswer',
  'answerText',
  'freeTextAnswer',
  'textAnswer',
  'score',
  'partialScore',
  'workedSteps',
  'expectedValue',
  'answersPayload',
  'expectedAnswer',
  'expectedAnswers',
  'html',
  'svg',
  'rawSvg',
  'mermaid',
  'markdown',
  'widget',
  'component',
  'render',
  'renderPayload',
  'style',
  'css',
  'script',
  'imageUrl',
  'assetUrl',
  'canvas',
  'code',
  'eval',
  'Function',
  'function',
  'formula',
  'expression',
  'rawFormula',
  'calculationCode',
  'javascript',
  'python',
  'markup',
};
