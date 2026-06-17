import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

class RichClosedCoreAnswerController {
  final Map<String, String> _singleSelections = {};
  final Map<String, Set<String>> _multipleSelections = {};
  final Map<String, Map<String, String>> _matchingSelections = {};
  final Map<String, List<String>> _orderingSelections = {};
  final Map<String, List<String>> _timelineSelections = {};
  final Map<String, int> _dateSliderSelections = {};
  final Map<String, Map<String, bool>> _trueFalseSelections = {};
  final Map<String, Map<String, String>> _causeConsequenceSelections = {};

  String? _message;

  String? get message => _message;

  String? selectedChoiceIdFor(String questionId) {
    return _singleSelections[questionId];
  }

  List<String> selectedChoiceIdsFor(RichClosedMultipleChoiceQuestion question) {
    final selectedIds = _multipleSelections[question.id];
    if (selectedIds == null || selectedIds.isEmpty) {
      return const [];
    }

    return question.choices
        .where((choice) => selectedIds.contains(choice.id))
        .map((choice) => choice.id)
        .toList(growable: false);
  }

  String? selectedRightIdFor(String questionId, String leftId) {
    return _matchingSelections[questionId]?[leftId];
  }

  List<RichClosedPair> matchingPairsFor(RichClosedMatchingQuestion question) {
    final selections = _matchingSelections[question.id];
    if (selections == null || selections.isEmpty) {
      return const [];
    }

    return [
      for (final leftItem in question.leftItems)
        if (selections[leftItem.id] != null)
          RichClosedPair(
            leftId: leftItem.id,
            rightId: selections[leftItem.id]!,
          ),
    ];
  }

  List<String> orderedIdsFor(RichClosedOrderingQuestion question) {
    final orderedIds = _orderingSelections[question.id];
    if (orderedIds == null || !_isCompleteOrdering(question, orderedIds)) {
      return question.items.map((item) => item.id).toList(growable: false);
    }

    return orderedIds.toList(growable: false);
  }

  List<String> orderedEventIdsFor(RichClosedTimelineQuestion question) {
    final orderedEventIds = _timelineSelections[question.id];
    if (orderedEventIds == null ||
        !_isCompleteTimeline(question, orderedEventIds)) {
      return question.events.map((event) => event.id).toList(growable: false);
    }

    return orderedEventIds.toList(growable: false);
  }

  int selectedYearFor(RichClosedDateSliderQuestion question) {
    return _dateSliderSelections.putIfAbsent(
      question.id,
      () => _initialYearFor(question),
    );
  }

  bool? selectedTrueFalseValueFor(String questionId, String rowId) {
    return _trueFalseSelections[questionId]?[rowId];
  }

  List<RichClosedTrueFalseGridValue> trueFalseValuesFor(
    RichClosedTrueFalseGridQuestion question,
  ) {
    final selections = _trueFalseSelections[question.id];
    if (selections == null || selections.isEmpty) {
      return const [];
    }

    return [
      for (final row in question.rows)
        if (selections[row.id] != null)
          RichClosedTrueFalseGridValue(
            rowId: row.id,
            value: selections[row.id]!,
          ),
    ];
  }

  String? selectedConsequenceIdFor(String questionId, String causeId) {
    return _causeConsequenceSelections[questionId]?[causeId];
  }

  List<RichClosedCauseConsequencePair> causeConsequencePairsFor(
    RichClosedCauseConsequenceQuestion question,
  ) {
    final selections = _causeConsequenceSelections[question.id];
    if (selections == null || selections.isEmpty) {
      return const [];
    }

    return [
      for (final cause in question.causes)
        if (selections[cause.id] != null)
          RichClosedCauseConsequencePair(
            causeId: cause.id,
            consequenceId: selections[cause.id]!,
          ),
    ];
  }

  void selectSingleChoice({
    required RichClosedSingleChoiceQuestion question,
    required String choiceId,
  }) {
    if (!_hasChoice(question.choices, choiceId)) {
      return;
    }

    _singleSelections[question.id] = choiceId;
    _message = null;
  }

  void selectCaseQualification({
    required RichClosedCaseQualificationQuestion question,
    required String choiceId,
  }) {
    if (!_hasChoice(question.choices, choiceId)) {
      return;
    }

    _singleSelections[question.id] = choiceId;
    _message = null;
  }

  void selectErrorDetection({
    required RichClosedErrorDetectionQuestion question,
    required String errorId,
  }) {
    if (!_hasChoice(question.errorOptions, errorId)) {
      return;
    }

    _singleSelections[question.id] = errorId;
    _message = null;
  }

  void toggleMultipleChoice({
    required RichClosedMultipleChoiceQuestion question,
    required String choiceId,
  }) {
    if (!_hasChoice(question.choices, choiceId)) {
      return;
    }

    final selectedIds = _multipleSelections.putIfAbsent(
      question.id,
      () => <String>{},
    );

    if (selectedIds.contains(choiceId)) {
      selectedIds.remove(choiceId);
      _message = null;
      return;
    }

    if (selectedIds.length >= question.maxSelections) {
      _message =
          'Tu peux sélectionner ${question.maxSelections} réponses au maximum.';
      return;
    }

    selectedIds.add(choiceId);
    _message = null;
  }

  void setMatchingPair({
    required RichClosedMatchingQuestion question,
    required String leftId,
    required String rightId,
  }) {
    if (!_hasLabelItem(question.leftItems, leftId) ||
        !_hasLabelItem(question.rightItems, rightId)) {
      return;
    }

    final selections = _matchingSelections.putIfAbsent(
      question.id,
      () => <String, String>{},
    );

    selections.removeWhere(
      (existingLeftId, existingRightId) =>
          existingLeftId != leftId && existingRightId == rightId,
    );
    selections[leftId] = rightId;
    _message = null;
  }

  void moveOrderingItemUp({
    required RichClosedOrderingQuestion question,
    required String itemId,
  }) {
    _moveOrderingItem(question: question, itemId: itemId, delta: -1);
  }

  void moveOrderingItemDown({
    required RichClosedOrderingQuestion question,
    required String itemId,
  }) {
    _moveOrderingItem(question: question, itemId: itemId, delta: 1);
  }

  void moveTimelineEventUp({
    required RichClosedTimelineQuestion question,
    required String eventId,
  }) {
    _moveTimelineEvent(question: question, eventId: eventId, delta: -1);
  }

  void moveTimelineEventDown({
    required RichClosedTimelineQuestion question,
    required String eventId,
  }) {
    _moveTimelineEvent(question: question, eventId: eventId, delta: 1);
  }

  void setDateSliderYear({
    required RichClosedDateSliderQuestion question,
    required int year,
  }) {
    _dateSliderSelections[question.id] = _snapYear(question, year);
    _message = null;
  }

  void setTrueFalseValue({
    required RichClosedTrueFalseGridQuestion question,
    required String rowId,
    required bool value,
  }) {
    if (!_hasTrueFalseRow(question.rows, rowId)) {
      return;
    }

    final selections = _trueFalseSelections.putIfAbsent(
      question.id,
      () => <String, bool>{},
    );
    selections[rowId] = value;
    _message = null;
  }

  void setCauseConsequencePair({
    required RichClosedCauseConsequenceQuestion question,
    required String causeId,
    required String consequenceId,
  }) {
    if (!_hasCauseConsequenceItem(question.causes, causeId) ||
        !_hasCauseConsequenceItem(question.consequences, consequenceId)) {
      return;
    }

    final selections = _causeConsequenceSelections.putIfAbsent(
      question.id,
      () => <String, String>{},
    );
    selections.removeWhere(
      (existingCauseId, existingConsequenceId) =>
          existingCauseId != causeId && existingConsequenceId == consequenceId,
    );
    selections[causeId] = consequenceId;
    _message = null;
  }

  bool canSubmitQuestion(RichClosedQuestion question) {
    return switch (question) {
      RichClosedSingleChoiceQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedMultipleChoiceQuestion() => _canSubmitMultipleChoice(question),
      RichClosedCaseQualificationQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedErrorDetectionQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedMatchingQuestion() => _canSubmitMatching(question),
      RichClosedOrderingQuestion() => _canSubmitOrdering(question),
      RichClosedTimelineQuestion() => _canSubmitTimeline(question),
      RichClosedDateSliderQuestion() => true,
      RichClosedTrueFalseGridQuestion() => _canSubmitTrueFalseGrid(question),
      RichClosedCauseConsequenceQuestion() => _canSubmitCauseConsequence(
        question,
      ),
    };
  }

  RichClosedAnswer? answerFor(RichClosedQuestion question) {
    if (!canSubmitQuestion(question)) {
      return null;
    }

    return switch (question) {
      RichClosedSingleChoiceQuestion() => RichClosedSingleChoiceAnswer(
        questionId: question.id,
        choiceId: _singleSelections[question.id]!,
      ),
      RichClosedMultipleChoiceQuestion() => RichClosedMultipleChoiceAnswer(
        questionId: question.id,
        choiceIds: selectedChoiceIdsFor(question),
      ),
      RichClosedCaseQualificationQuestion() =>
        RichClosedCaseQualificationAnswer(
          questionId: question.id,
          choiceId: _singleSelections[question.id]!,
        ),
      RichClosedErrorDetectionQuestion() => RichClosedErrorDetectionAnswer(
        questionId: question.id,
        errorId: _singleSelections[question.id]!,
      ),
      RichClosedMatchingQuestion() => RichClosedMatchingAnswer(
        questionId: question.id,
        pairs: matchingPairsFor(question),
      ),
      RichClosedOrderingQuestion() => RichClosedOrderingAnswer(
        questionId: question.id,
        orderedIds: orderedIdsFor(question),
      ),
      RichClosedTimelineQuestion() => RichClosedTimelineAnswer(
        questionId: question.id,
        orderedEventIds: orderedEventIdsFor(question),
      ),
      RichClosedDateSliderQuestion() => RichClosedDateSliderAnswer(
        questionId: question.id,
        year: selectedYearFor(question),
      ),
      RichClosedTrueFalseGridQuestion() => RichClosedTrueFalseGridAnswer(
        questionId: question.id,
        values: trueFalseValuesFor(question),
      ),
      RichClosedCauseConsequenceQuestion() => RichClosedCauseConsequenceAnswer(
        questionId: question.id,
        pairs: causeConsequencePairsFor(question),
      ),
    };
  }

  bool _canSubmitMultipleChoice(RichClosedMultipleChoiceQuestion question) {
    final selectedCount = _multipleSelections[question.id]?.length ?? 0;
    return selectedCount >= question.minSelections &&
        selectedCount <= question.maxSelections;
  }

  bool _canSubmitMatching(RichClosedMatchingQuestion question) {
    final selections = _matchingSelections[question.id];
    if (selections == null || selections.length != question.leftItems.length) {
      return false;
    }

    final leftIds = question.leftItems.map((item) => item.id).toSet();
    final rightIds = question.rightItems.map((item) => item.id).toSet();
    final selectedRightIds = selections.values.toSet();

    return selections.keys.every(leftIds.contains) &&
        selections.values.every(rightIds.contains) &&
        selectedRightIds.length == selections.length;
  }

  bool _canSubmitOrdering(RichClosedOrderingQuestion question) {
    return _isCompleteOrdering(question, orderedIdsFor(question));
  }

  bool _canSubmitTimeline(RichClosedTimelineQuestion question) {
    return _isCompleteTimeline(question, orderedEventIdsFor(question));
  }

  bool _canSubmitTrueFalseGrid(RichClosedTrueFalseGridQuestion question) {
    final selections = _trueFalseSelections[question.id];
    if (selections == null || selections.length != question.rows.length) {
      return false;
    }

    final rowIds = question.rows.map((row) => row.id).toSet();

    return selections.keys.every(rowIds.contains);
  }

  bool _canSubmitCauseConsequence(RichClosedCauseConsequenceQuestion question) {
    final selections = _causeConsequenceSelections[question.id];
    if (selections == null || selections.length != question.causes.length) {
      return false;
    }

    final causeIds = question.causes.map((cause) => cause.id).toSet();
    final consequenceIds = question.consequences
        .map((consequence) => consequence.id)
        .toSet();
    final selectedConsequenceIds = selections.values.toSet();

    return selections.keys.every(causeIds.contains) &&
        selections.values.every(consequenceIds.contains) &&
        selectedConsequenceIds.length == selections.length;
  }

  void _moveOrderingItem({
    required RichClosedOrderingQuestion question,
    required String itemId,
    required int delta,
  }) {
    if (!_hasLabelItem(question.items, itemId)) {
      return;
    }

    final orderedIds = orderedIdsFor(question).toList();
    final currentIndex = orderedIds.indexOf(itemId);
    final nextIndex = currentIndex + delta;

    if (currentIndex < 0 || nextIndex < 0 || nextIndex >= orderedIds.length) {
      return;
    }

    final movedId = orderedIds.removeAt(currentIndex);
    orderedIds.insert(nextIndex, movedId);
    _orderingSelections[question.id] = orderedIds;
    _message = null;
  }

  void _moveTimelineEvent({
    required RichClosedTimelineQuestion question,
    required String eventId,
    required int delta,
  }) {
    if (!_hasTimelineEvent(question.events, eventId)) {
      return;
    }

    final orderedEventIds = orderedEventIdsFor(question).toList();
    final currentIndex = orderedEventIds.indexOf(eventId);
    final nextIndex = currentIndex + delta;

    if (currentIndex < 0 ||
        nextIndex < 0 ||
        nextIndex >= orderedEventIds.length) {
      return;
    }

    final movedId = orderedEventIds.removeAt(currentIndex);
    orderedEventIds.insert(nextIndex, movedId);
    _timelineSelections[question.id] = orderedEventIds;
    _message = null;
  }

  bool _isCompleteOrdering(
    RichClosedOrderingQuestion question,
    List<String> orderedIds,
  ) {
    final expectedIds = question.items.map((item) => item.id).toSet();
    final actualIds = orderedIds.toSet();

    return orderedIds.length == question.items.length &&
        actualIds.length == orderedIds.length &&
        actualIds.length == expectedIds.length &&
        actualIds.every(expectedIds.contains);
  }

  bool _isCompleteTimeline(
    RichClosedTimelineQuestion question,
    List<String> orderedEventIds,
  ) {
    final expectedIds = question.events.map((event) => event.id).toSet();
    final actualIds = orderedEventIds.toSet();

    return orderedEventIds.length == question.events.length &&
        actualIds.length == orderedEventIds.length &&
        actualIds.length == expectedIds.length &&
        actualIds.every(expectedIds.contains);
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

  bool _hasChoice(List<RichClosedChoice> choices, String choiceId) {
    return choices.any((choice) => choice.id == choiceId);
  }

  bool _hasLabelItem(List<RichClosedLabelItem> items, String itemId) {
    return items.any((item) => item.id == itemId);
  }

  bool _hasTimelineEvent(List<RichClosedTimelineEvent> events, String eventId) {
    return events.any((event) => event.id == eventId);
  }

  bool _hasTrueFalseRow(List<RichClosedTrueFalseRow> rows, String rowId) {
    return rows.any((row) => row.id == rowId);
  }

  bool _hasCauseConsequenceItem(
    List<RichClosedCauseConsequenceItem> items,
    String itemId,
  ) {
    return items.any((item) => item.id == itemId);
  }
}
