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

Map<String, Object?> richClosedV1BFullExerciseJson() {
  final json = richClosedV1BExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.addAll([
    {
      'id': 'true-false-grid-1',
      'questionKind': 'true_false_grid',
      'prompt':
          'Indique si chaque affirmation sur le régime parlementaire est vraie ou fausse.',
      'instruction': 'Réponds à toutes les lignes.',
      'difficulty': 'MEDIUM',
      'cognitiveSkill': 'classification',
      'sourceChunkIds': ['chunk-8'],
      'rows': [
        {
          'id': 'row-1',
          'statement':
              'Le gouvernement peut être responsable devant le Parlement.',
          'context': 'Critère du régime parlementaire.',
        },
        {
          'id': 'row-2',
          'statement':
              'La séparation des pouvoirs interdit toute collaboration.',
          'context': 'La collaboration est possible en régime parlementaire.',
        },
        {
          'id': 'row-3',
          'statement': 'La dissolution peut être un moyen réciproque.',
          'context': 'Elle peut équilibrer la responsabilité politique.',
        },
      ],
    },
    {
      'id': 'cause-consequence-1',
      'questionKind': 'cause_consequence',
      'prompt':
          'Associe chaque mécanisme institutionnel à sa conséquence politique.',
      'instruction': 'Choisis une conséquence différente pour chaque cause.',
      'difficulty': 'HIGH',
      'cognitiveSkill': 'causality',
      'sourceChunkIds': ['chunk-9'],
      'causes': [
        {
          'id': 'cause-1',
          'label': 'Motion de censure adoptée',
          'description': 'La chambre retire sa confiance.',
        },
        {
          'id': 'cause-2',
          'label': 'Dissolution de l’Assemblée',
          'description': 'Le mandat de la chambre prend fin.',
        },
        {
          'id': 'cause-3',
          'label': 'Question de confiance rejetée',
          'description': 'Le gouvernement engage sa responsabilité.',
        },
      ],
      'consequences': [
        {
          'id': 'consequence-1',
          'label': 'Démission du gouvernement',
          'description': 'La responsabilité politique produit ses effets.',
        },
        {
          'id': 'consequence-2',
          'label': 'Nouvelles élections législatives',
          'description': 'Le corps électoral renouvelle la chambre.',
        },
        {
          'id': 'consequence-3',
          'label': 'Crise politique ou départ du gouvernement',
          'description': 'Le rejet manifeste une perte de confiance.',
        },
      ],
    },
  ]);

  return json;
}

Map<String, Object?> richClosedV1BFullResultJson() {
  final json = richClosedV1BResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 9;
  json['totalQuestions'] = 10;
  json['score'] = 0.9;
  json['items'] = items;
  items.addAll([
    {
      'questionId': 'true-false-grid-1',
      'questionKind': 'true_false_grid',
      'prompt':
          'Indique si chaque affirmation sur le régime parlementaire est vraie ou fausse.',
      'submittedAnswer': {
        'questionId': 'true-false-grid-1',
        'questionKind': 'true_false_grid',
        'values': [
          {'rowId': 'row-1', 'value': true},
          {'rowId': 'row-2', 'value': true},
          {'rowId': 'row-3', 'value': true},
        ],
      },
      'isCorrect': false,
      'partialScore': 0,
      'explanation': 'Le parlementarisme admet la collaboration des pouvoirs.',
      'sourceChunkIds': ['chunk-8'],
      'correction': {
        'correctValues': [
          {'rowId': 'row-1', 'value': true},
          {'rowId': 'row-2', 'value': false},
          {'rowId': 'row-3', 'value': true},
        ],
      },
    },
    {
      'questionId': 'cause-consequence-1',
      'questionKind': 'cause_consequence',
      'prompt':
          'Associe chaque mécanisme institutionnel à sa conséquence politique.',
      'submittedAnswer': {
        'questionId': 'cause-consequence-1',
        'questionKind': 'cause_consequence',
        'pairs': [
          {'causeId': 'cause-1', 'consequenceId': 'consequence-1'},
          {'causeId': 'cause-2', 'consequenceId': 'consequence-2'},
          {'causeId': 'cause-3', 'consequenceId': 'consequence-3'},
        ],
      },
      'isCorrect': true,
      'partialScore': 1,
      'explanation':
          'Chaque mécanisme active une conséquence institutionnelle distincte.',
      'sourceChunkIds': ['chunk-9'],
      'correction': {
        'correctPairs': [
          {'causeId': 'cause-1', 'consequenceId': 'consequence-1'},
          {'causeId': 'cause-2', 'consequenceId': 'consequence-2'},
          {'causeId': 'cause-3', 'consequenceId': 'consequence-3'},
        ],
      },
    },
  ]);

  return json;
}

Map<String, Object?> richClosedV1CExerciseJson() {
  final json = richClosedV1BFullExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.add({
    'id': 'institution-matrix-1',
    'questionKind': 'institution_matrix',
    'prompt':
        'Complète la matrice comparant Président, Gouvernement et Assemblée nationale.',
    'instruction': 'Choisis une option fermée pour chaque cellule demandée.',
    'difficulty': 'MEDIUM',
    'cognitiveSkill': 'comparison',
    'sourceChunkIds': ['chunk-10'],
    'rows': [
      {
        'id': 'row-president',
        'label': 'Président de la République',
        'description': 'Chef de l’État.',
      },
      {
        'id': 'row-government',
        'label': 'Gouvernement',
        'description': 'Organe chargé de conduire la politique nationale.',
      },
      {
        'id': 'row-assembly',
        'label': 'Assemblée nationale',
        'description': 'Chambre élue au suffrage universel direct.',
      },
    ],
    'columns': [
      {
        'id': 'column-legitimacy',
        'label': 'Mode de légitimité',
        'description': 'Origine politique principale.',
      },
      {
        'id': 'column-action',
        'label': 'Moyen d’action',
        'description': 'Instrument institutionnel caractéristique.',
      },
      {
        'id': 'column-responsibility',
        'label': 'Responsabilité politique',
        'description': 'Lien de responsabilité devant une institution.',
      },
    ],
    'cells': [
      {
        'id': 'cell-president-legitimacy',
        'rowId': 'row-president',
        'columnId': 'column-legitimacy',
        'prompt': 'Quelle légitimité caractérise principalement le Président ?',
        'options': [
          {'id': 'option-legitimacy-election', 'label': 'Élection nationale'},
          {
            'id': 'option-legitimacy-confidence',
            'label': 'Confiance parlementaire',
          },
          {'id': 'option-legitimacy-nomination', 'label': 'Nomination simple'},
        ],
      },
      {
        'id': 'cell-government-responsibility',
        'rowId': 'row-government',
        'columnId': 'column-responsibility',
        'prompt':
            'Devant qui le Gouvernement est-il politiquement responsable ?',
        'options': [
          {
            'id': 'option-responsibility-assembly',
            'label': 'Assemblée nationale',
          },
          {'id': 'option-responsibility-senate', 'label': 'Sénat'},
          {'id': 'option-responsibility-none', 'label': 'Aucune institution'},
        ],
      },
      {
        'id': 'cell-assembly-action',
        'rowId': 'row-assembly',
        'columnId': 'column-action',
        'prompt': 'Quel moyen d’action vise le Gouvernement ?',
        'options': [
          {'id': 'option-action-censure', 'label': 'Motion de censure'},
          {'id': 'option-action-dissolution', 'label': 'Dissolution'},
          {'id': 'option-action-promulgation', 'label': 'Promulgation'},
        ],
      },
    ],
  });

  return json;
}

Map<String, Object?> richClosedV1CResultJson() {
  final json = richClosedV1BFullResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 10;
  json['totalQuestions'] = 11;
  json['score'] = 0.909;
  json['items'] = items;
  items.add({
    'questionId': 'institution-matrix-1',
    'questionKind': 'institution_matrix',
    'prompt':
        'Complète la matrice comparant Président, Gouvernement et Assemblée nationale.',
    'submittedAnswer': {
      'questionId': 'institution-matrix-1',
      'questionKind': 'institution_matrix',
      'values': [
        {
          'cellId': 'cell-president-legitimacy',
          'optionId': 'option-legitimacy-election',
        },
        {
          'cellId': 'cell-government-responsibility',
          'optionId': 'option-responsibility-assembly',
        },
        {'cellId': 'cell-assembly-action', 'optionId': 'option-action-censure'},
      ],
    },
    'isCorrect': true,
    'partialScore': 1,
    'explanation':
        'Chaque cellule associe une institution à une propriété fermée du régime.',
    'sourceChunkIds': ['chunk-10'],
    'correction': {
      'correctValues': [
        {
          'cellId': 'cell-president-legitimacy',
          'optionId': 'option-legitimacy-election',
        },
        {
          'cellId': 'cell-government-responsibility',
          'optionId': 'option-responsibility-assembly',
        },
        {'cellId': 'cell-assembly-action', 'optionId': 'option-action-censure'},
      ],
    },
  });

  return json;
}

Map<String, Object?> richClosedV1CFullExerciseJson() {
  final json = richClosedV1CExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.add({
    'id': 'diagram-labeling-1',
    'questionKind': 'diagram_labeling',
    'prompt':
        'Complète le schéma des rapports institutionnels sous la Ve République.',
    'instruction':
        'Choisis une option fermée pour chaque zone du schéma textuel.',
    'difficulty': 'MEDIUM',
    'cognitiveSkill': 'classification',
    'sourceChunkIds': ['chunk-11'],
    'diagram': {
      'title': 'Rapports institutionnels',
      'description':
          'Schéma textuel borné entre exécutif et Parlement, sans SVG ni HTML.',
      'layout': 'vertical_flow',
      'nodes': [
        {
          'id': 'node-president',
          'label': 'Président de la République',
          'description': 'Chef de l’État.',
          'groupId': 'group-executive',
        },
        {
          'id': 'node-government',
          'label': 'Gouvernement',
          'description': 'Conduit la politique nationale.',
          'groupId': 'group-executive',
        },
        {
          'id': 'node-assembly',
          'label': 'Assemblée nationale',
          'description': 'Chambre politiquement déterminante.',
          'groupId': 'group-parliament',
        },
        {
          'id': 'node-senate',
          'label': 'Sénat',
          'description': 'Chambre représentant les collectivités.',
          'groupId': 'group-parliament',
        },
      ],
      'groups': [
        {'id': 'group-executive', 'label': 'Exécutif'},
        {'id': 'group-parliament', 'label': 'Parlement'},
      ],
      'edges': [
        {
          'id': 'edge-president-government',
          'fromNodeId': 'node-president',
          'toNodeId': 'node-government',
          'label': 'nomme',
          'description': 'Nomination du Premier ministre.',
        },
        {
          'id': 'edge-government-assembly',
          'fromNodeId': 'node-government',
          'toNodeId': 'node-assembly',
          'label': 'responsable devant',
          'description': 'Responsabilité politique.',
        },
        {
          'id': 'edge-assembly-government',
          'fromNodeId': 'node-assembly',
          'toNodeId': 'node-government',
          'label': 'contrôle',
          'description': 'Contrôle parlementaire.',
        },
      ],
    },
    'slots': [
      {
        'id': 'slot-government-role',
        'anchorType': 'node',
        'anchorId': 'node-government',
        'prompt': 'Quel organe conduit la politique nationale ?',
        'options': [
          {'id': 'option-government', 'label': 'Gouvernement'},
          {'id': 'option-president', 'label': 'Président'},
          {'id': 'option-senate', 'label': 'Sénat'},
        ],
      },
      {
        'id': 'slot-censure',
        'anchorType': 'edge',
        'anchorId': 'edge-assembly-government',
        'prompt': 'Quel mécanisme illustre le contrôle parlementaire ?',
        'options': [
          {'id': 'option-motion-censure', 'label': 'Motion de censure'},
          {'id': 'option-referendum', 'label': 'Référendum'},
          {'id': 'option-promulgation', 'label': 'Promulgation'},
        ],
      },
      {
        'id': 'slot-nomination',
        'anchorType': 'edge',
        'anchorId': 'edge-president-government',
        'prompt': 'Quelle relation relie le Président au Gouvernement ?',
        'options': [
          {'id': 'option-nomination', 'label': 'Nomination'},
          {'id': 'option-censure', 'label': 'Censure'},
          {'id': 'option-election', 'label': 'Élection parlementaire'},
        ],
      },
    ],
  });

  return json;
}

Map<String, Object?> richClosedV1CFullResultJson() {
  final json = richClosedV1CResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 11;
  json['totalQuestions'] = 12;
  json['score'] = 0.917;
  json['items'] = items;
  items.add({
    'questionId': 'diagram-labeling-1',
    'questionKind': 'diagram_labeling',
    'prompt':
        'Complète le schéma des rapports institutionnels sous la Ve République.',
    'submittedAnswer': {
      'questionId': 'diagram-labeling-1',
      'questionKind': 'diagram_labeling',
      'values': [
        {'slotId': 'slot-government-role', 'optionId': 'option-government'},
        {'slotId': 'slot-censure', 'optionId': 'option-motion-censure'},
        {'slotId': 'slot-nomination', 'optionId': 'option-nomination'},
      ],
    },
    'isCorrect': true,
    'partialScore': 1,
    'explanation':
        'Le schéma relie des organes et mécanismes institutionnels fermés.',
    'sourceChunkIds': ['chunk-11'],
    'correction': {
      'correctValues': [
        {'slotId': 'slot-government-role', 'optionId': 'option-government'},
        {'slotId': 'slot-censure', 'optionId': 'option-motion-censure'},
        {'slotId': 'slot-nomination', 'optionId': 'option-nomination'},
      ],
    },
  });

  return json;
}

Map<String, Object?> richClosedV1CCalculationExerciseJson() {
  final json = richClosedV1CFullExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.add({
    'id': 'calculation-mcq-majority-1',
    'questionKind': 'calculation_mcq',
    'prompt': 'Calcule le seuil de majorité absolue.',
    'instruction': 'Choisis le résultat entier parmi les options proposées.',
    'difficulty': 'MEDIUM',
    'cognitiveSkill': 'procedure',
    'sourceChunkIds': ['chunk-12'],
    'scenario':
        'Une assemblée compte 577 suffrages exprimés pour une décision.',
    'calculation': {'mode': 'absolute_majority_threshold', 'validVotes': 577},
    'choices': [
      {'id': 'choice-288', 'label': '288 voix', 'value': 288},
      {'id': 'choice-289', 'label': '289 voix', 'value': 289},
      {'id': 'choice-290', 'label': '290 voix', 'value': 290},
    ],
  });

  return json;
}

Map<String, Object?> richClosedV1CCalculationResultJson() {
  final json = richClosedV1CFullResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 12;
  json['totalQuestions'] = 13;
  json['score'] = 0.923;
  json['items'] = items;
  items.add({
    'questionId': 'calculation-mcq-majority-1',
    'questionKind': 'calculation_mcq',
    'prompt': 'Calcule le seuil de majorité absolue.',
    'submittedAnswer': {
      'questionId': 'calculation-mcq-majority-1',
      'questionKind': 'calculation_mcq',
      'choiceId': 'choice-289',
    },
    'isCorrect': true,
    'partialScore': 1,
    'explanation':
        'La majorité absolue correspond à la moitié des suffrages exprimés, arrondie à l’entier inférieur, puis augmentée d’une voix.',
    'sourceChunkIds': ['chunk-12'],
    'correction': {
      'correctChoiceId': 'choice-289',
      'expectedValue': 289,
      'workedSteps': [
        {
          'id': 'valid-votes',
          'label': 'Suffrages exprimés',
          'detail': 'Suffrages exprimés : 577.',
          'value': 577,
        },
        {
          'id': 'majority-rule',
          'label': 'Majorité absolue',
          'detail': 'Prendre la partie entière de 577 / 2, puis ajouter 1.',
        },
        {
          'id': 'threshold',
          'label': 'Seuil attendu',
          'detail': 'Seuil attendu : 289.',
          'value': 289,
        },
      ],
    },
  });

  return json;
}

Map<String, Object?> richClosedV1DImageChoiceExerciseJson() {
  final json = richClosedV1CCalculationExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.add({
    'id': 'image-choice-1',
    'questionKind': 'image_choice',
    'prompt':
        'Quel portrait correspond au personnage associé à l’appel du 18 juin ?',
    'instruction': 'Choisis uniquement parmi les images du catalogue contrôlé.',
    'difficulty': 'MEDIUM',
    'cognitiveSkill': 'memorization',
    'sourceChunkIds': ['chunk-13'],
    'choices': [
      {
        'id': 'choice-image-a',
        'label': 'Image A',
        'imageAssetId': 'image-choice-historical-figure-001-v1',
        'altText':
            'Portrait historique en noir et blanc d’un homme en uniforme.',
        'caption': 'Portrait historique A',
        'creditLabel': 'Asset de démonstration contrôlé',
        'license': 'internal_placeholder',
      },
      {
        'id': 'choice-image-b',
        'label': 'Image B',
        'imageAssetId': 'image-choice-historical-figure-002-v1',
        'altText': 'Portrait peint d’un homme en tenue impériale.',
        'caption': 'Portrait historique B',
        'creditLabel': 'Asset de démonstration contrôlé',
        'license': 'internal_placeholder',
      },
      {
        'id': 'choice-image-c',
        'label': 'Image C',
        'imageAssetId': 'image-choice-historical-figure-003-v1',
        'altText': 'Portrait historique d’une femme politique.',
        'caption': 'Portrait historique C',
        'creditLabel': 'Asset de démonstration contrôlé',
        'license': 'internal_placeholder',
      },
    ],
  });

  return json;
}

Map<String, Object?> richClosedV1DImageChoiceResultJson() {
  final json = richClosedV1CCalculationResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 13;
  json['totalQuestions'] = 14;
  json['score'] = 0.929;
  json['items'] = items;
  items.add({
    'questionId': 'image-choice-1',
    'questionKind': 'image_choice',
    'prompt':
        'Quel portrait correspond au personnage associé à l’appel du 18 juin ?',
    'submittedAnswer': {
      'questionId': 'image-choice-1',
      'questionKind': 'image_choice',
      'choiceId': 'choice-image-a',
    },
    'isCorrect': true,
    'partialScore': 1,
    'explanation': 'L’appel du 18 juin 1940 est associé à Charles de Gaulle.',
    'sourceChunkIds': ['chunk-13'],
    'correction': {'correctChoiceId': 'choice-image-a'},
  });

  return json;
}

Map<String, Object?> richClosedCalculationLargestRemainderQuestionJson() {
  return {
    'id': 'calculation-mcq-remainder-1',
    'questionKind': 'calculation_mcq',
    'prompt': 'Calcule les sièges obtenus par le parti A.',
    'instruction':
        'Utilise les données fournies, puis choisis le résultat entier.',
    'difficulty': 'HIGH',
    'cognitiveSkill': 'procedure',
    'sourceChunkIds': ['chunk-13'],
    'scenario':
        'Quatre partis se répartissent 10 sièges selon le plus fort reste.',
    'calculation': {
      'mode': 'largest_remainder_target_party_seats',
      'totalSeats': 10,
      'targetPartyId': 'party-a',
      'parties': [
        {'id': 'party-a', 'label': 'Parti A', 'votes': 4300},
        {'id': 'party-b', 'label': 'Parti B', 'votes': 3100},
        {'id': 'party-c', 'label': 'Parti C', 'votes': 1600},
        {'id': 'party-d', 'label': 'Parti D', 'votes': 1000},
      ],
    },
    'choices': [
      {'id': 'choice-3', 'label': '3 sièges', 'value': 3},
      {'id': 'choice-4', 'label': '4 sièges', 'value': 4},
      {'id': 'choice-5', 'label': '5 sièges', 'value': 5},
    ],
  };
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
      'fill_blank_dropdown';
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
