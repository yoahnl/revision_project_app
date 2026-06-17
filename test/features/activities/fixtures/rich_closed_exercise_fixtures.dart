Map<String, Object?> richClosedExerciseJson() {
  return {
    'sessionId': 'rich-session-1',
    'type': 'rich_closed_exercise',
    'id': 'exercise-1',
    'version': 'rich-closed-question-v1',
    'title': 'Exercice institutions politiques',
    'subjectId': 'subject-1',
    'documentId': 'document-1',
    'knowledgeUnitId': 'unit-1',
    'questions': [
      {
        'id': 'single-1',
        'questionKind': 'single_choice',
        'prompt': 'Quel critère caractérise un régime parlementaire ?',
        'difficulty': 'MEDIUM',
        'cognitiveSkill': 'classification',
        'sourceChunkIds': ['chunk-1'],
        'choices': [
          {'id': 'choice-a', 'label': 'Responsabilité politique'},
          {'id': 'choice-b', 'label': 'Séparation étanche'},
          {'id': 'choice-c', 'label': 'Confédération'},
        ],
      },
      {
        'id': 'multiple-1',
        'questionKind': 'multiple_choice',
        'prompt': 'Quels indices orientent vers un régime parlementaire ?',
        'difficulty': 'MEDIUM',
        'cognitiveSkill': 'comparison',
        'sourceChunkIds': ['chunk-1', 'chunk-2'],
        'choices': [
          {'id': 'choice-a', 'label': 'Responsabilité du gouvernement'},
          {'id': 'choice-b', 'label': 'Collaboration des pouvoirs'},
          {'id': 'choice-c', 'label': 'Indépendance absolue'},
          {'id': 'choice-d', 'label': 'Absence de Parlement'},
        ],
        'minSelections': 2,
        'maxSelections': 2,
      },
      {
        'id': 'matching-1',
        'questionKind': 'matching',
        'prompt': 'Associe chaque mécanisme à sa fonction.',
        'difficulty': 'HIGH',
        'cognitiveSkill': 'comparison',
        'sourceChunkIds': ['chunk-2'],
        'leftItems': [
          {'id': 'left-1', 'label': 'Motion de censure'},
          {'id': 'left-2', 'label': 'Dissolution'},
          {'id': 'left-3', 'label': 'Contrôle constitutionnel'},
        ],
        'rightItems': [
          {'id': 'right-1', 'label': 'Responsabilité politique'},
          {'id': 'right-2', 'label': 'Fin anticipée d’une chambre'},
          {'id': 'right-3', 'label': 'Vérification d’une norme'},
        ],
      },
      {
        'id': 'ordering-1',
        'questionKind': 'ordering',
        'prompt': 'Ordonne les étapes du raisonnement.',
        'difficulty': 'LOW',
        'cognitiveSkill': 'procedure',
        'sourceChunkIds': ['chunk-3'],
        'items': [
          {'id': 'item-1', 'label': 'Repérer les organes'},
          {'id': 'item-2', 'label': 'Analyser les moyens d’action'},
          {'id': 'item-3', 'label': 'Qualifier le régime'},
        ],
      },
      {
        'id': 'case-1',
        'questionKind': 'case_qualification',
        'prompt': 'Choisis la qualification la plus pertinente.',
        'difficulty': 'HIGH',
        'cognitiveSkill': 'case_application',
        'sourceChunkIds': ['chunk-4'],
        'caseText':
            'Un gouvernement doit conserver la confiance d’une chambre élue.',
        'choices': [
          {'id': 'choice-a', 'label': 'Régime parlementaire'},
          {'id': 'choice-b', 'label': 'Régime présidentiel'},
          {'id': 'choice-c', 'label': 'Confédération'},
        ],
      },
      {
        'id': 'error-1',
        'questionKind': 'error_detection',
        'prompt': 'Repère l’erreur dominante.',
        'difficulty': 'MEDIUM',
        'cognitiveSkill': 'error_detection',
        'sourceChunkIds': ['chunk-5'],
        'statement':
            'Un régime présidentiel se définit par la responsabilité politique du gouvernement devant le Parlement.',
        'errorOptions': [
          {'id': 'error-a', 'label': 'Confusion avec le parlementarisme'},
          {'id': 'error-b', 'label': 'Confusion avec l’État fédéral'},
          {
            'id': 'error-c',
            'label': 'Confusion avec le contrôle juridictionnel',
          },
        ],
      },
    ],
  };
}

Map<String, Object?> richClosedResultJson() {
  return {
    'sessionId': 'rich-session-1',
    'type': 'rich_closed_exercise',
    'status': 'completed',
    'correctAnswers': 5,
    'totalQuestions': 6,
    'score': 0.833,
    'items': [
      {
        'questionId': 'single-1',
        'questionKind': 'single_choice',
        'prompt': 'Quel critère caractérise un régime parlementaire ?',
        'submittedAnswer': {
          'questionId': 'single-1',
          'questionKind': 'single_choice',
          'choiceId': 'choice-a',
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'La responsabilité politique est centrale.',
        'sourceChunkIds': ['chunk-1'],
        'correction': {'correctChoiceId': 'choice-a'},
      },
      {
        'questionId': 'multiple-1',
        'questionKind': 'multiple_choice',
        'prompt': 'Quels indices orientent vers un régime parlementaire ?',
        'submittedAnswer': {
          'questionId': 'multiple-1',
          'questionKind': 'multiple_choice',
          'choiceIds': ['choice-a', 'choice-b'],
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'Responsabilité et collaboration sont attendues.',
        'sourceChunkIds': ['chunk-1', 'chunk-2'],
        'correction': {
          'correctChoiceIds': ['choice-a', 'choice-b'],
        },
      },
      {
        'questionId': 'matching-1',
        'questionKind': 'matching',
        'prompt': 'Associe chaque mécanisme à sa fonction.',
        'submittedAnswer': {
          'questionId': 'matching-1',
          'questionKind': 'matching',
          'pairs': [
            {'leftId': 'left-1', 'rightId': 'right-1'},
            {'leftId': 'left-2', 'rightId': 'right-2'},
            {'leftId': 'left-3', 'rightId': 'right-3'},
          ],
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'Chaque mécanisme renvoie à sa fonction.',
        'sourceChunkIds': ['chunk-2'],
        'correction': {
          'correctPairs': [
            {'leftId': 'left-1', 'rightId': 'right-1'},
            {'leftId': 'left-2', 'rightId': 'right-2'},
            {'leftId': 'left-3', 'rightId': 'right-3'},
          ],
        },
      },
      {
        'questionId': 'ordering-1',
        'questionKind': 'ordering',
        'prompt': 'Ordonne les étapes du raisonnement.',
        'submittedAnswer': {
          'questionId': 'ordering-1',
          'questionKind': 'ordering',
          'orderedIds': ['item-1', 'item-2', 'item-3'],
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'La qualification vient après l’analyse.',
        'sourceChunkIds': ['chunk-3'],
        'correction': {
          'correctOrder': ['item-1', 'item-2', 'item-3'],
        },
      },
      {
        'questionId': 'case-1',
        'questionKind': 'case_qualification',
        'prompt': 'Choisis la qualification la plus pertinente.',
        'submittedAnswer': {
          'questionId': 'case-1',
          'questionKind': 'case_qualification',
          'choiceId': 'choice-a',
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'La confiance parlementaire qualifie le régime.',
        'sourceChunkIds': ['chunk-4'],
        'correction': {'correctChoiceId': 'choice-a'},
      },
      {
        'questionId': 'error-1',
        'questionKind': 'error_detection',
        'prompt': 'Repère l’erreur dominante.',
        'submittedAnswer': {
          'questionId': 'error-1',
          'questionKind': 'error_detection',
          'errorId': 'error-b',
        },
        'isCorrect': false,
        'partialScore': 0,
        'explanation': 'L’erreur dominante est la confusion de régime.',
        'sourceChunkIds': ['chunk-5'],
        'correction': {'correctErrorId': 'error-a'},
      },
    ],
  };
}

Map<String, Object?> richClosedV1BExerciseJson() {
  final json = richClosedExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.addAll([
    {
      'id': 'timeline-1',
      'questionKind': 'timeline',
      'prompt': 'Remets dans l’ordre ces étapes du contrôle parlementaire.',
      'instruction': 'Classe les événements du début vers la fin.',
      'difficulty': 'MEDIUM',
      'cognitiveSkill': 'procedure',
      'sourceChunkIds': ['chunk-6'],
      'events': [
        {
          'id': 'event-1',
          'label': 'Dépôt de la motion',
          'description': 'Des parlementaires engagent la procédure.',
        },
        {
          'id': 'event-2',
          'label': 'Débat politique',
          'description': 'La chambre débat de la responsabilité.',
        },
        {
          'id': 'event-3',
          'label': 'Vote de la chambre',
          'description': 'La chambre adopte ou rejette la motion.',
        },
      ],
    },
    {
      'id': 'date-slider-1',
      'questionKind': 'date_slider',
      'prompt':
          'Place approximativement l’adoption de la Constitution de la Ve République.',
      'instruction': 'Choisis une année entière.',
      'difficulty': 'LOW',
      'cognitiveSkill': 'comprehension',
      'sourceChunkIds': ['chunk-7'],
      'minYear': 1945,
      'maxYear': 1970,
      'step': 1,
      'toleranceYears': 0,
    },
  ]);

  return json;
}

Map<String, Object?> richClosedV1BResultJson() {
  final json = richClosedResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 7;
  json['totalQuestions'] = 8;
  json['score'] = 0.875;
  json['items'] = items;
  items.addAll([
    {
      'questionId': 'timeline-1',
      'questionKind': 'timeline',
      'prompt': 'Remets dans l’ordre ces étapes du contrôle parlementaire.',
      'submittedAnswer': {
        'questionId': 'timeline-1',
        'questionKind': 'timeline',
        'orderedEventIds': ['event-1', 'event-2', 'event-3'],
      },
      'isCorrect': true,
      'partialScore': 1,
      'explanation': 'La procédure suit initiative, débat puis vote.',
      'sourceChunkIds': ['chunk-6'],
      'correction': {
        'correctOrder': ['event-1', 'event-2', 'event-3'],
      },
    },
    {
      'questionId': 'date-slider-1',
      'questionKind': 'date_slider',
      'prompt':
          'Place approximativement l’adoption de la Constitution de la Ve République.',
      'submittedAnswer': {
        'questionId': 'date-slider-1',
        'questionKind': 'date_slider',
        'year': 1960,
      },
      'isCorrect': false,
      'partialScore': 0,
      'explanation': 'La Constitution de la Ve République est adoptée en 1958.',
      'sourceChunkIds': ['chunk-7'],
      'correction': {
        'correctYear': 1958,
        'minAcceptedYear': 1958,
        'maxAcceptedYear': 1958,
      },
    },
  ]);

  return json;
}

Map<String, Object?> richClosedExerciseWithCorrectChoiceLeak() {
  final json = richClosedExerciseJson();
  ((json['questions']! as List<Object?>).first!
          as Map<String, Object?>)['correctChoiceId'] =
      'choice-a';
  return json;
}

Map<String, Object?> richClosedExerciseWithFeedbackLeak() {
  final json = richClosedExerciseJson();
  final question =
      (json['questions']! as List<Object?>).first! as Map<String, Object?>;
  final choice =
      (question['choices']! as List<Object?>).first! as Map<String, Object?>;
  choice['feedback'] = 'Ne doit pas être présent en pré-submit.';
  return json;
}

Map<String, Object?> richClosedExerciseWithUnknownKind() {
  final json = richClosedExerciseJson();
  ((json['questions']! as List<Object?>).first!
          as Map<String, Object?>)['questionKind'] =
      'true_false_grid';
  return json;
}

Map<String, Object?> richClosedResultWithIncoherentCorrection() {
  final json = richClosedResultJson();
  final item = (json['items']! as List<Object?>).first! as Map<String, Object?>;
  item['correction'] = {
    'correctOrder': ['item-1', 'item-2'],
  };
  return json;
}
