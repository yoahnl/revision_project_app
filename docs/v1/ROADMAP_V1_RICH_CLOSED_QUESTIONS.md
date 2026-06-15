# Roadmap V1 — Questions riches fermées

## 1. Vision produit

La V1 transforme Revision App d'une application qui sait déjà importer un cours, extraire des notions, générer des supports, proposer un QCM, corriger une question ouverte et orchestrer une session IA, vers un moteur de révision interactif fermé, riche, typé, sourcé et adapté au contenu.

Le point produit central est simple : une question fermée n'est pas nécessairement une question pauvre. En droit constitutionnel, la richesse pédagogique vient souvent de la qualification, de la comparaison, de la procédure, de la classification, de la chronologie, de la causalité institutionnelle et de la détection d'erreur. Un étudiant peut être fortement challengé sans champ texte libre.

La réponse libre reste réservée à l'activité `open_question`. La V1 ne doit pas introduire de réponse libre déguisée dans le QCM. Elle doit au contraire créer des contrats fermés explicites, que le backend peut générer, valider, persister, corriger et exposer sans fuite de correction avant soumission, et que Flutter peut rendre avec des widgets bornés.

Objectif produit V1 :

- remplacer le réflexe “un prompt + quatre choix” par un catalogue d'interactions fermées ;
- rendre le diagnostic plus proche des compétences universitaires réelles ;
- garantir que la richesse est un contrat, pas une suggestion au modèle ;
- conserver les acquis V0 : sources, anti-fuite, fallback, tests, TodayPlan et sessions IA.

## 2. Pourquoi la V0 produit encore des QCM basiques

Le code V0 contient déjà des bases solides, mais il ne force pas encore les questions riches.

Diagnostic observé dans le code :

- Flutter envoie déjà `selectionModes: ['single', 'multiple']`, `visualsEnabled: true` et `visualTypes: ['CHART', 'DIAGRAM']` depuis `HttpActivitiesApi.startNextActivity`.
- Côté backend, `ActivitiesController` accepte `questionCount`, `visualsEnabled`, `visualTypes` et `selectionModes`.
- `visualTypes` accepte `CHART` et `DIAGRAM`, mais refuse encore `IMAGE` en entrée publique.
- `DiagnosticQuizGenerator` ne connaît que `single` et `multiple` comme modes de sélection, plus les visuels `IMAGE`, `CHART`, `DIAGRAM`.
- Le prompt Genkit dit “Tu peux ajouter visuals” : les visuels restent autorisés, pas obligatoires.
- Le prompt demande des niveaux cognitifs variés, mais le schéma accepte encore une sortie composée uniquement de questions classiques.
- Les logs calculent `selectionModeCounts`, `visualCounts`, `visualQuestionCount` et `basicPromptHeuristicCount`, mais ces signaux ne rejettent pas un quiz trop basique.
- Le modèle Prisma `Question` reste centré sur `prompt`, `choices`, `selectionMode`, `correctChoiceId`, `correctChoiceIds`, `explanation`, `sources` et `visuals`.
- Le front Flutter sait rendre une question avec choix, single/multiple, sources et visuels chart/diagram, mais pas encore matching, ordering, timeline, slider de date, matrice ou texte à trous.
- GenUI sait rendre `McqQuestionCard`, `McqCorrectionPanel`, `ActivityResultCard`, `QuestionChartCard` et `QuestionDiagramCard`, mais pas des exercices riches fermés au sens V1.
- Today route volontairement l'action `diagnostic_quiz` sans `knowledgeUnitId` pour éviter l'ouverture automatique de `open_question` lorsque `subjectId + knowledgeUnitId` sont présents.
- `ActivitiesPage` démarre `open_question` par défaut quand une notion est fournie, ce qui complique une entrée directe vers un exercice fermé ciblé.

Conclusion : la V0 a des options avancées, mais pas encore un contrat de types pédagogiques. La V1 doit transformer les options permissives en exigences vérifiables.

## 3. Principes non négociables V1

- Jamais de réponse libre dans une question riche fermée.
- Chaque type de question doit être un contrat explicite.
- Le backend est propriétaire du contrat public.
- Genkit produit uniquement des DTO stricts, validés par schéma.
- Flutter ne rend que des types catalogués et connus.
- La correction n'est jamais visible avant soumission.
- Les sources sont présentes quand la question dépend du contenu du document.
- Les sources pré-submit ne contiennent pas de texte complet de chunk.
- Le fallback est propre si un type n'est pas supporté.
- Aucun widget arbitraire ne peut être rendu.
- Aucun HTML, SVG, Mermaid ou JavaScript libre n'est rendu depuis un payload.
- Aucun JSON brut n'est affiché à l'utilisateur.
- La qualité pédagogique doit être mesurable.
- Le QCM v2/v3 existant doit rester compatible pendant la migration.
- `open_question` reste l'activité de réponse libre, séparée des exercices fermés.

## 4. Typologie pédagogique

Les questions riches fermées doivent couvrir plusieurs compétences.

- Mémorisation : identifier une notion, une institution, une date ou une définition, mais sans que ce soit le format dominant.
- Compréhension : reconnaître une conséquence, une condition ou une exception.
- Comparaison : distinguer régime parlementaire, présidentiel, semi-présidentiel, État unitaire, fédéral, confédéral ou régionalisé.
- Classification : ranger des exemples dans des catégories fermées.
- Qualification juridique : rattacher un cas court à une notion juridique.
- Application à un cas : choisir le diagnostic fermé le plus pertinent.
- Procédure : remettre des étapes institutionnelles dans l'ordre.
- Chronologie : placer des régimes, constitutions ou événements sur une ligne temporelle.
- Causalité institutionnelle : relier cause et conséquence.
- Détection d'erreur : repérer une affirmation ou un raisonnement faux.
- Calcul électoral : appliquer une règle fermée, par exemple une répartition de sièges.
- Lecture de schéma : compléter ou interpréter un schéma institutionnel borné.
- Lecture de matrice : croiser institutions, compétences, responsabilités ou modes de désignation.
- Reconnaissance historique : identifier une personne, une institution ou une période à partir d'indices fermés.

## 5. Catalogue V1 cible

### `single_choice`

Usage pédagogique : réponse unique avancée. Utile pour une qualification, une conséquence ou une exception.

Exemple court : “Un gouvernement peut être renversé par une motion de censure. Quel trait institutionnel cela révèle-t-il ?” Bonne réponse : régime parlementaire.

Payload conceptuel :

```ts
{
  questionKind: 'single_choice',
  prompt: string,
  choices: Array<{ id: string; label: string }>,
  answerShape: { type: 'single_choice_id' },
  correctionPayload: { correctChoiceId: string; explanation: string }
}
```

Correction attendue : comparaison stricte entre `choiceId` soumis et `correctChoiceId`.

Complexité backend : faible, proche du QCM v3.

Complexité frontend : faible, widget existant réutilisable.

Priorité : MVP V1-A.

### `multiple_choice`

Usage pédagogique : sélectionner toutes les conditions, conséquences ou propriétés correctes.

Exemple court : “Quels éléments caractérisent un régime parlementaire ?” Bonnes réponses : responsabilité politique du gouvernement, droit de dissolution possible selon les systèmes.

Payload conceptuel :

```ts
{
  questionKind: 'multiple_choice',
  prompt: string,
  choices: Array<{ id: string; label: string }>,
  answerShape: { type: 'choice_id_set', minSelections: number, maxSelections: number },
  correctionPayload: { correctChoiceIds: string[]; explanation: string }
}
```

Correction attendue : ensemble exact ou scoring partiel explicitement choisi.

Complexité backend : faible à moyenne, déjà amorcée par `selectionMode=multiple`.

Complexité frontend : faible, déjà supporté côté QCM v3.

Priorité : MVP V1-A.

### `true_false`

Usage pédagogique : vérifier une affirmation isolée.

Exemple court : “La souveraineté populaire exclut toute démocratie directe.” Bonne réponse : faux.

Payload conceptuel :

```ts
{
  questionKind: 'true_false',
  statement: string,
  answerShape: { type: 'boolean' },
  correctionPayload: { correctValue: boolean; explanation: string }
}
```

Correction attendue : booléen strict.

Complexité backend : faible.

Complexité frontend : faible.

Priorité : V1-B, sauf si utilisé comme base de `true_false_grid`.

### `true_false_grid`

Usage pédagogique : évaluer plusieurs affirmations liées sans créer cinq questions isolées.

Exemple court : grille sur souveraineté nationale, souveraineté populaire, référendum et représentation.

Payload conceptuel :

```ts
{
  questionKind: 'true_false_grid',
  prompt: string,
  rows: Array<{ id: string; statement: string }>,
  columns: ['true', 'false'],
  answerShape: { type: 'boolean_by_row' },
  correctionPayload: { correctValues: Record<string, boolean>; explanation: string }
}
```

Correction attendue : une valeur booléenne par ligne.

Complexité backend : moyenne.

Complexité frontend : moyenne, besoin d'une grille accessible.

Priorité : V1-B.

### `matching`

Usage pédagogique : associer notion et définition, institution et compétence, régime et mécanisme.

Exemple court : associer “motion de censure”, “dissolution”, “contrôle de constitutionnalité” à leur définition.

Payload conceptuel :

```ts
{
  questionKind: 'matching',
  prompt: string,
  leftItems: Array<{ id: string; label: string }>,
  rightItems: Array<{ id: string; label: string }>,
  answerShape: { type: 'pairing' },
  correctionPayload: { pairs: Array<{ leftId: string; rightId: string }>; explanation: string }
}
```

Correction attendue : paires exactes, éventuellement scoring par paire.

Complexité backend : moyenne.

Complexité frontend : moyenne, interaction de sélection ou menus déroulants.

Priorité : MVP V1-A.

### `ordering`

Usage pédagogique : remettre une procédure, un raisonnement ou une chronologie courte dans l'ordre.

Exemple court : étapes d'un contrôle de constitutionnalité abstrait ou d'une procédure parlementaire.

Payload conceptuel :

```ts
{
  questionKind: 'ordering',
  prompt: string,
  items: Array<{ id: string; label: string }>,
  answerShape: { type: 'ordered_ids' },
  correctionPayload: { correctOrder: string[]; explanation: string }
}
```

Correction attendue : ordre exact ou score par position si décidé par ADR.

Complexité backend : moyenne.

Complexité frontend : moyenne, drag-and-drop ou boutons monter/descendre.

Priorité : MVP V1-A.

### `timeline`

Usage pédagogique : placer des périodes, régimes ou événements sur une séquence.

Exemple court : ordonner IIIe République, IVe République et Ve République.

Payload conceptuel :

```ts
{
  questionKind: 'timeline',
  prompt: string,
  events: Array<{ id: string; label: string; dateLabel?: string }>,
  answerShape: { type: 'ordered_ids' },
  correctionPayload: { correctOrder: string[]; explanation: string }
}
```

Correction attendue : ordre chronologique.

Complexité backend : moyenne.

Complexité frontend : moyenne.

Priorité : V1-B.

### `date_slider`

Usage pédagogique : choisir une date ou une période dans des bornes connues.

Exemple court : positionner 1958 sur une frise de 1870 à 1962.

Payload conceptuel :

```ts
{
  questionKind: 'date_slider',
  prompt: string,
  minYear: number,
  maxYear: number,
  answerShape: { type: 'integer_range' },
  correctionPayload: { correctYear: number; tolerance?: number; explanation: string }
}
```

Correction attendue : année exacte ou tolérance bornée.

Complexité backend : moyenne.

Complexité frontend : moyenne.

Priorité : V1-B.

### `image_choice`

Usage pédagogique : reconnaissance historique ou institutionnelle à partir d'un asset contrôlé.

Exemple court : identifier une figure historique parmi des portraits publics et sourcés.

Payload conceptuel :

```ts
{
  questionKind: 'image_choice',
  prompt: string,
  assets: Array<{ id: string; imageRef: string; altText: string }>,
  answerShape: { type: 'single_choice_id' },
  correctionPayload: { correctAssetId: string; explanation: string }
}
```

Correction attendue : asset choisi.

Complexité backend : élevée, droits et stockage assets.

Complexité frontend : moyenne.

Priorité : V1-D.

### `diagram_labeling`

Usage pédagogique : compléter un schéma institutionnel borné.

Exemple court : associer gouvernement, Parlement, Président, Conseil constitutionnel à des blocs du schéma.

Payload conceptuel :

```ts
{
  questionKind: 'diagram_labeling',
  prompt: string,
  diagram: { nodes: Array<{ id: string; label?: string; slot: boolean }> },
  labels: Array<{ id: string; label: string }>,
  answerShape: { type: 'label_by_slot' },
  correctionPayload: { labelsByNodeId: Record<string, string>; explanation: string }
}
```

Correction attendue : label correct par slot.

Complexité backend : élevée.

Complexité frontend : élevée.

Priorité : V1-C.

### `institution_matrix`

Usage pédagogique : croiser institutions et propriétés.

Exemple court : institution x compétence ou institution x mode de désignation.

Payload conceptuel :

```ts
{
  questionKind: 'institution_matrix',
  prompt: string,
  rows: Array<{ id: string; label: string }>,
  columns: Array<{ id: string; label: string }>,
  answerShape: { type: 'choice_by_cell' },
  correctionPayload: { correctCells: Record<string, string>; explanation: string }
}
```

Correction attendue : valeur correcte par cellule demandée.

Complexité backend : élevée.

Complexité frontend : élevée.

Priorité : V1-C.

### `case_qualification`

Usage pédagogique : lire un mini-cas et choisir la qualification fermée.

Exemple court : “Le gouvernement est responsable devant une chambre élue qui peut le renverser.” Bonne réponse : régime parlementaire.

Payload conceptuel :

```ts
{
  questionKind: 'case_qualification',
  caseText: string,
  prompt: string,
  choices: Array<{ id: string; label: string }>,
  answerShape: { type: 'single_choice_id' },
  correctionPayload: { correctChoiceId: string; explanation: string }
}
```

Correction attendue : qualification unique.

Complexité backend : faible à moyenne.

Complexité frontend : faible.

Priorité : MVP V1-A.

### `error_detection`

Usage pédagogique : repérer une erreur dans une affirmation ou un raisonnement.

Exemple court : “Le régime présidentiel se définit par la responsabilité politique du gouvernement devant le Parlement.” Erreur : confusion avec le régime parlementaire.

Payload conceptuel :

```ts
{
  questionKind: 'error_detection',
  statement: string,
  errorOptions: Array<{ id: string; label: string }>,
  answerShape: { type: 'single_choice_id' },
  correctionPayload: { correctErrorId: string; explanation: string }
}
```

Correction attendue : erreur identifiée.

Complexité backend : moyenne.

Complexité frontend : faible.

Priorité : MVP V1-A.

### `cause_consequence`

Usage pédagogique : relier un mécanisme à ses effets institutionnels.

Exemple court : cause “droit de dissolution” vers conséquence “pression politique possible sur la chambre”.

Payload conceptuel :

```ts
{
  questionKind: 'cause_consequence',
  prompt: string,
  causes: Array<{ id: string; label: string }>,
  consequences: Array<{ id: string; label: string }>,
  answerShape: { type: 'pairing' },
  correctionPayload: { pairs: Array<{ causeId: string; consequenceId: string }>; explanation: string }
}
```

Correction attendue : paires exactes ou score par paire.

Complexité backend : moyenne.

Complexité frontend : moyenne.

Priorité : V1-B.

### `calculation_mcq`

Usage pédagogique : appliquer une règle de calcul fermée.

Exemple court : répartition simplifiée de sièges selon une méthode proportionnelle.

Payload conceptuel :

```ts
{
  questionKind: 'calculation_mcq',
  prompt: string,
  data: Record<string, number | string>,
  choices: Array<{ id: string; label: string }>,
  answerShape: { type: 'single_choice_id' },
  correctionPayload: { correctChoiceId: string; explanation: string; workedSteps: string[] }
}
```

Correction attendue : choix final, explication post-submit.

Complexité backend : élevée si calcul vérifié, moyenne si choix fermé généré.

Complexité frontend : faible à moyenne.

Priorité : V1-C.

### `fill_blank_dropdown`

Usage pédagogique : compléter une phrase conceptuelle avec menus bornés.

Exemple court : “Dans un régime ___, le gouvernement est politiquement responsable devant ___.”

Payload conceptuel :

```ts
{
  questionKind: 'fill_blank_dropdown',
  textParts: Array<string | { blankId: string }>,
  optionsByBlank: Record<string, Array<{ id: string; label: string }>>,
  answerShape: { type: 'choice_by_blank' },
  correctionPayload: { correctOptionByBlank: Record<string, string>; explanation: string }
}
```

Correction attendue : choix exact par blanc.

Complexité backend : moyenne.

Complexité frontend : moyenne.

Priorité : V1-B ou V1.1 selon charge UI.

## 6. MVP V1 recommandé

### V1-A

- `single_choice` avancé.
- `multiple_choice`.
- `matching`.
- `ordering`.
- `case_qualification`.
- `error_detection`.

Justification : ce lot offre le meilleur ratio pédagogie/complexité. Il exploite déjà la base QCM existante, ajoute des interactions fermées très pertinentes pour le droit, et limite le risque UI.

### V1-B

- `timeline`.
- `date_slider`.
- `true_false_grid`.
- `cause_consequence`.
- éventuellement `fill_blank_dropdown`.

Justification : ces types demandent davantage de widgets et de validations, mais restent très utiles pour les chapitres historiques, institutionnels et procéduraux.

### V1-C

- `institution_matrix`.
- `diagram_labeling`.
- `calculation_mcq`.

Justification : ces types sont pédagogiquement forts, mais plus coûteux côté UI, correction et validation.

### V1-D

- `image_choice`.
- portraits historiques.
- assets publics ou gérés localement.

Justification : ce type dépend des droits, de l'accessibilité, du stockage et de la modération des assets. Il doit être reporté tant que la chaîne d'assets n'est pas contractuelle.

## 7. Architecture backend cible

La V1 doit introduire un contrat de question riche plutôt que d'ajouter des champs implicites à l'infini.

Concept recommandé :

```ts
type RichClosedQuestion =
  | SingleChoiceQuestion
  | MultipleChoiceQuestion
  | MatchingQuestion
  | OrderingQuestion
  | CaseQualificationQuestion
  | ErrorDetectionQuestion;
```

Chaque question porte :

- `questionKind` : discriminant fermé.
- `prompt` ou champs spécifiques.
- `interactionPayload` : données pré-submit nécessaires au rendu.
- `answerShape` : forme attendue de la réponse.
- `correctionPayload` : données privées jusqu'au submit.
- `sourceChunkIds` : sources autorisées.
- `difficulty` et `cognitiveSkill` : signaux pédagogiques.
- `version` : version du contrat.

### Option 1 — Étendre `Question`

Avantages :

- migration plus légère ;
- réutilisation de `ActivitySession`, `QuestionSource`, `QuestionAnswer`, `ActivityResult` ;
- compatibilité plus simple avec QCM v3.

Inconvénients :

- risque de modèle fourre-tout ;
- beaucoup de champs nullable ;
- validation applicative plus importante ;
- mapping plus délicat pour les types non choix.

### Option 2 — Créer des tables spécialisées ou payload JSON typé

Avantages :

- séparation claire du QCM v3 et des exercices riches ;
- union typée plus propre ;
- versioning plus facile ;
- possibilité de conserver une activité `DIAGNOSTIC_QUIZ` intacte.

Inconvénients :

- migration plus conséquente ;
- nouveaux repositories et tests ;
- mapping Today/session à enrichir.

### Recommandation

Créer une nouvelle activité `RICH_CLOSED_EXERCISE` ou un nouveau contrat versionné `rich_closed_question-v1`, avec payload JSON typé validé applicativement, plutôt que de surcharger immédiatement `Question`. Le choix exact doit être tranché en ADR V1-002.

Approche prudente :

- V1-002 tranche l'ADR.
- V1-003 audite la migration.
- V1-004 crée les types applicatifs sans génération IA.
- V1-005 ajoute les quality gates.
- V1-006 branche Genkit V1-A.

## 8. Architecture frontend cible

Flutter doit parser un JSON discriminé par `questionKind`, puis router vers un widget natif ou GenUI strictement catalogué.

### Option 1 — Widgets natifs Flutter par type

Avantages :

- UX stable ;
- accessibilité maîtrisée ;
- tests widget simples ;
- pas de dépendance au rendu dynamique.

Inconvénients :

- plus de code Flutter ;
- itérations UI plus lentes.

### Option 2 — GenUI strictement catalogué

Avantages :

- cohérent avec le catalogue existant ;
- peut accélérer des rendus alternatifs ;
- bornes et validators déjà en place.

Inconvénients :

- risque de confusion “catalogue borné” vs widget arbitraire ;
- plus difficile pour interactions complexes comme ordering ou matrix ;
- ne doit pas devenir source de vérité.

### Option 3 — Hybride recommandé

Recommandation :

- widgets natifs pour le runtime produit ;
- GenUI seulement comme rendu borné secondaire ou preview cataloguée ;
- domain models Flutter stricts ;
- parser discriminé ;
- fallback sûr pour type non supporté ;
- correction post-submit uniquement depuis le backend ;
- aucun calcul de correction côté front.

## 9. Architecture Genkit cible

Le prompt Genkit V1 doit imposer les types, pas les suggérer.

Principes :

- remplacer “tu peux” par “tu dois” pour le mix de types ;
- fournir un `questionTypeMix` explicite ;
- fournir un `complexityProfile` ;
- fournir `minimumAdvancedQuestions` ;
- interdire les types non demandés ;
- forcer un minimum de sources ;
- rejeter les sorties trop basiques ;
- limiter la régénération à un nombre borné ;
- logger uniquement des métadonnées de qualité.

Exemple conceptuel :

```ts
{
  questionCount: 10,
  questionTypeMix: {
    case_qualification: 2,
    error_detection: 2,
    matching: 2,
    ordering: 1,
    multiple_choice: 2,
    single_choice: 1
  },
  minimumAdvancedQuestions: 7,
  forbiddenKinds: ['open_text', 'free_answer']
}
```

Les schémas Zod doivent être stricts, discriminés et refuser les champs inconnus lorsque possible.

## 10. Quality gates

Règles minimales proposées :

- minimum 3 types différents dans un exercice de 10 questions ;
- maximum 30 % de questions basiques ;
- minimum 2 questions de qualification ou application ;
- minimum 1 question de détection d'erreur ;
- minimum 80 % de questions sourcées si des chunks existent ;
- rejet si type interdit ;
- rejet si correction pré-submit présente ;
- rejet si source inconnue ;
- rejet si question non justifiable par chunks ;
- rejet si `multiple_choice` a une seule bonne réponse ;
- rejet si `ordering` a moins de 3 items ;
- rejet si `matching` a moins de 3 paires ;
- rejet si `date_slider` n'a pas de bornes ;
- rejet si `image_choice` référence un asset libre ;
- métriques loggées : `questionKindCounts`, `advancedQuestionCount`, `basicPromptHeuristicCount`, `sourcedQuestionCount`, `qualityGateStatus`.

## 11. Impact Today

Today doit pouvoir recommander une activité précise, pas seulement “QCM”.

Évolutions à prévoir :

- ajouter un `preferredActivityKind`, par exemple `diagnostic_quiz`, `rich_closed_exercise`, `open_question`, `revision_session` ;
- permettre une action ciblée par `knowledgeUnitId` sans déclencher automatiquement `open_question` ;
- distinguer “QCM rapide” et “exercice riche” ;
- préserver l'ordre déterministe backend ;
- ne pas calculer le ranking côté Flutter.

Point V0 sensible : aujourd'hui, `ActivitiesPage(subjectId + knowledgeUnitId)` démarre directement une question ouverte. La V1 doit éviter que cela bloque les exercices fermés ciblés.

## 12. Impact revision sessions

Les sessions IA doivent orchestrer :

- QCM simple ;
- question ouverte ;
- exercice riche fermé ;
- correction ;
- prochaine activité.

Mais l'IA ne choisit jamais un widget libre. Elle peut choisir une action parmi une enum backend fermée, puis le backend démarre une activité contractuelle. Une action de session pourrait devenir `RICH_CLOSED_EXERCISE`, avec `activitySessionId` et payload public pré-submit.

## 13. Impact seed/demo

La V1 doit enrichir le seed :

- notions avec plusieurs chunks chacune ;
- fixtures de questions fermées riches ;
- exemples prévisibles sur droit constitutionnel ;
- smoke checks pré-submit/post-submit ;
- golden demo V1 montrant QCM riche, question ouverte et session IA.

Le seed ne doit pas appeler Genkit pour produire les fixtures de référence.

## 14. Risques

- Explosion du modèle si chaque type devient une table trop spécifique.
- Surcomplexité UI si trop de widgets arrivent dans le même lot.
- Réponses incorrectes IA si les quality gates ne sont pas assez stricts.
- Scoring incohérent entre types.
- Migration trop lourde si l'ADR choisit une table spécialisée trop tôt.
- Confusion entre QCM riche et question ouverte.
- Dette GenUI si le catalogue est utilisé comme runtime principal sans contrat métier.
- Accessibilité des interactions drag-and-drop, matrices et sliders.
- Copyright et gestion des portraits pour `image_choice`.
- Performance de rendu pour matrices et diagrammes.

## 15. Décisions à trancher avant implémentation

- JSON typé vs tables spécialisées.
- Nouvelle activité `RICH_CLOSED_EXERCISE` vs version QCM v4.
- `questionKind` dans `Question` existant vs nouveau modèle.
- Format `answerShape`.
- Format `interactionPayload`.
- Format `correctionPayload`.
- Place de GenUI : preview/catalogue ou runtime secondaire.
- Stratégie de scoring par type.
- Assets image et droits.
- Migration progressive des tests.
- Contrat Today pour cibler les exercices fermés.
- Contrat revision session pour action riche fermée.
- Seuils de quality gates et stratégie de régénération bornée.
