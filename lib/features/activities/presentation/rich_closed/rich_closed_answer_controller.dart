import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

class RichClosedCoreAnswerController {
  final Map<String, String> _singleSelections = {};
  final Map<String, Set<String>> _multipleSelections = {};

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

  bool canSubmitQuestion(RichClosedQuestion question) {
    return switch (question) {
      RichClosedSingleChoiceQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedMultipleChoiceQuestion() => _canSubmitMultipleChoice(question),
      RichClosedCaseQualificationQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedErrorDetectionQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedMatchingQuestion() || RichClosedOrderingQuestion() => false,
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
      RichClosedMatchingQuestion() || RichClosedOrderingQuestion() => null,
    };
  }

  bool _canSubmitMultipleChoice(RichClosedMultipleChoiceQuestion question) {
    final selectedCount = _multipleSelections[question.id]?.length ?? 0;
    return selectedCount >= question.minSelections &&
        selectedCount <= question.maxSelections;
  }

  bool _hasChoice(List<RichClosedChoice> choices, String choiceId) {
    return choices.any((choice) => choice.id == choiceId);
  }
}
