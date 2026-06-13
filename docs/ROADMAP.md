# Roadmap Revision App — Genkit + GenUI

## 1. Vision produit

Revision App doit devenir un compagnon de révision scolaire centré sur les cours réels de l'étudiant.

Le parcours cible est simple et démontrable :

1. L'étudiant crée une matière.
2. Il importe un cours au format PDF.
3. Le backend extrait le texte, puis Genkit découpe le cours en notions structurées.
4. L'application expose ces notions sous forme de résumés, fiches de révision, points clés et extraits sources.
5. L'étudiant s'entraîne avec des QCM et des questions ouvertes.
6. L'IA corrige, explique, identifie les manques et met à jour la maîtrise.
7. Le plan du jour propose automatiquement les actions les plus utiles selon les notions fragiles, l'objectif, la priorité et l'historique.
8. GenUI rend certaines activités dynamiques côté Flutter, mais uniquement via un catalogue contrôlé de composants validés.

La démonstration technique doit rendre visibles deux piliers :

- Genkit côté backend : orchestration IA, outputs structurés, schémas stricts, flows testables, grounding sur les documents.
- GenUI côté frontend : sessions pédagogiques dynamiques, composants bornés, fallback natif robuste.

Le produit ne doit pas donner l'impression d'un chatbot générique. Il doit montrer une boucle complète : cours importé, notions extraites, support généré, activité corrigée, plan adapté.

## 2. État actuel du projet

### Frontend Flutter

Le frontend actif se trouve dans `revision_app`.

L'application utilise déjà :

- Flutter Material 3.
- Riverpod pour l'injection et les états.
- GoRouter pour la navigation.
- Firebase Auth pour l'authentification.
- Un shell principal avec navigation par onglets.
- Des pages principales : matières, détail matière, aujourd'hui, activités, profil, onboarding, sign-in.
- Des repositories HTTP pour parler au backend.
- Un import de documents depuis la page matière.
- Une activité QCM native.
- Un catalogue GenUI amorcé dans `features/activities/genui`.
- Des widgets réutilisables déjà amorcés dans `presentation/widgets`.
- Une première identité visuelle custom dans `presentation/theme` et `presentation/widgets`, mais encore incomplète.

Les zones importantes côté front sont :

- `lib/app/router/app_routes.dart` pour les routes publiques et privées.
- `lib/app/di` pour les providers Riverpod.
- `lib/features/subjects` pour les matières.
- `lib/features/documents` pour l'import et le statut des cours.
- `lib/features/activities` pour les QCM et le catalogue GenUI.
- `lib/features/today` pour le plan du jour.
- `lib/presentation/pages` pour les pages.
- `lib/presentation/widgets` pour le design system applicatif.

### Backend NestJS

Le backend actif se trouve dans `../api`.

L'API utilise déjà :

- NestJS en architecture modulaire.
- Une séparation proche Clean Architecture : `domain`, `application`, `interfaces`, `infrastructure`.
- Prisma pour la persistance.
- Firebase Auth côté backend avec vérification de token.
- `StudentProfile` et isolation par étudiant.
- Modules `students`, `subjects`, `documents`, `jobs`, `ai`, `activities`, `revision`, `auth`.
- BullMQ pour le processing asynchrone des documents.
- Un stockage fichier via port `DocumentFileStorage` et implémentation locale actuelle.
- Extraction PDF via port `DocumentTextExtractor`.
- Genkit pour l'extraction de notions et la génération de QCM.
- Support de providers IA configurables, notamment Google GenAI et Mistral via compatibilité OpenAI côté génération QCM.
- Endpoints actuels autour des matières, documents, activités et plan du jour.

Les zones importantes côté back sont :

- `src/modules/documents` pour l'upload, le statut, les documents et le processing.
- `src/modules/jobs` pour le worker BullMQ.
- `src/modules/ai` pour les extracteurs Genkit.
- `src/modules/activities` pour QCM, sessions, résultats et mastery.
- `src/modules/revision` pour le plan du jour adaptatif.
- `prisma/schema.prisma` pour les modèles `Subject`, `Document`, `KnowledgeUnit`, `ActivitySession`, `Question`, `ActivityResult`, `MasteryState`.

### Pipeline actuel

Le pipeline déjà présent est :

1. L'utilisateur crée une matière.
2. Il importe un PDF via `POST /documents/course-pdf`.
3. Le backend crée un `Document` en statut initial.
4. Un job BullMQ est créé.
5. Le worker lit le fichier.
6. Le texte PDF est extrait.
7. Genkit extrait des `KnowledgeUnit`.
8. Les notions sont persistées.
9. Le document passe à `READY` ou `FAILED`.
10. L'utilisateur peut lancer un QCM.
11. Le backend génère une activité depuis une notion.
12. La soumission met à jour la maîtrise.
13. `GET /today` propose une action selon la maîtrise.

### Limites actuelles

- Les `KnowledgeUnit` sont encore pauvres : `title` et `summary` dominent, alors que le schéma IA prévoit déjà partiellement `sourceExcerpt` et `difficulty`.
- Les résumés et fiches de révision ne sont pas encore exposés comme objets métier.
- Le QCM existe, mais doit être enrichi avec corrections détaillées, feedback par question, score par notion et difficulté.
- Les questions ouvertes n'existent pas encore.
- GenUI est amorcé, mais pas encore au centre d'une vraie session interactive.
- Le plan du jour ne propose actuellement qu'un type d'action limité, principalement `diagnostic_quiz`.
- Les citations et extraits sources existent partiellement dans les schémas IA, mais ne sont pas encore suffisamment exploités dans le produit.
- Le design frontend a commencé à sortir du Material brut, mais plusieurs surfaces restent encore trop Material-like, notamment certaines cartes, états vides et composants d'activité.
- L'import document fonctionne, mais la surface de détail document ne valorise pas encore assez l'analyse IA.
- Le stockage est piloté par un port backend, avec une implémentation locale utile pour le MVP, mais la stratégie long terme doit rester interchangeable.

## 3. Principes d'architecture

Les règles suivantes doivent guider toutes les phases.

- Garder la Clean Architecture NestJS.
- Ajouter les fonctionnalités via modules, use cases, ports et adapters.
- Ne pas mettre de logique métier dans les controllers NestJS.
- Ne pas faire dépendre l'application NestJS directement d'un provider IA concret.
- Garder les outputs IA typés, versionnés et validés.
- Ne jamais laisser le frontend interpréter du texte IA libre comme UI.
- GenUI doit être borné par un catalogue strict de composants.
- Genkit doit produire des DTO structurés, versionnés et testables.
- Les réponses IA doivent être sourcées quand elles viennent d'un document.
- Les corrections IA doivent distinguer feedback pédagogique, score, points présents, points manquants et réponse modèle.
- Les données utilisateur doivent rester isolées par `studentId`.
- Chaque endpoint doit vérifier l'ownership côté backend.
- Les adapters de démonstration Flutter doivent rester hors runtime produit.
- Le frontend doit dépendre de controllers et providers Riverpod, pas directement des clients HTTP dans les pages.
- Les erreurs IA doivent devenir explicites et compréhensibles côté produit.
- Les tests unitaires et d'intégration doivent accompagner chaque phase.
- Le design system Flutter doit être utilisé systématiquement dans les pages.
- Les composants GenUI doivent avoir un fallback natif.
- Le ranking du plan du jour doit rester déterministe ou testable.

## 4. Roadmap par phases

### Phase 0 — Audit et alignement produit

**Objectif**

Stabiliser la vision produit, documenter les flows existants, définir le vocabulaire métier et figer le happy path de démo.

**Valeur démo**

L'équipe sait exactement quelle histoire montrer : import de cours, analyse IA, fiche, QCM, question ouverte, correction, plan adapté.

**Backend tasks**

- Cartographier les modules `students`, `subjects`, `documents`, `jobs`, `ai`, `activities`, `revision`.
- Documenter les use cases existants : création matière, upload PDF, processing document, extraction Genkit, génération QCM, soumission, plan du jour.
- Identifier les ports déjà présents : `DocumentTextExtractor`, `DocumentKnowledgeExtractor`, `DiagnosticQuizGenerator`, repositories Prisma.
- Définir le vocabulaire métier : `Matière`, `Document`, `KnowledgeUnit`, `Summary`, `RevisionSheet`, `Activity`, `OpenQuestion`, `Correction`, `MasteryState`, `TodayPlan`.
- Identifier les endpoints existants et les endpoints à créer.
- Établir le mapping entre modèles Prisma existants et modèles métier cibles.

**Frontend tasks**

- Cartographier les pages existantes : sign-in, onboarding, subjects, subject detail, today, activities, profile.
- Cartographier les providers Riverpod et repositories HTTP.
- Identifier les surfaces qui doivent devenir premium : liste matières, détail document, activité QCM, correction, page aujourd'hui.
- Définir les premiers écrans de démo.
- Définir le parcours mobile prioritaire.

**Genkit tasks**

- Lister les flows déjà présents : extraction de notions, génération QCM.
- Documenter les inputs/outputs actuels.
- Identifier les champs IA déjà prévus mais non persistés.
- Définir les versions de schémas cibles pour les prochains flows.

**GenUI tasks**

- Auditer le catalogue `features/activities/genui`.
- Identifier les composants actuels et les composants manquants.
- Définir les règles de fallback.

**Modèle de données / Prisma**

- Aucun changement de schéma.
- Produire seulement une note d'écart entre le schéma actuel et le modèle cible.

**API contracts**

- Aucun changement immédiat.
- Documenter les contrats existants avant extension.

**Tests à écrire**

- Aucun test produit obligatoire dans cette phase.
- Ajouter au minimum une checklist manuelle du happy path.

**Critères d'acceptation**

- Le vocabulaire métier est validé.
- Les modules existants sont cartographiés.
- Le happy path de démo est écrit.
- Les écrans prioritaires sont identifiés.
- Les gaps Genkit et GenUI sont listés.

**Risques / points d'attention**

- Ne pas commencer par refactorer sans bénéfice utilisateur.
- Ne pas mélanger choix produit et détails provider IA.
- Ne pas multiplier les concepts métier trop tôt.

### Phase 1 — Design system frontend premium

**Objectif**

Sortir de l'aspect Material Design brut et créer une identité visuelle cohérente, mobile-first, sans bloquer les phases IA.

**Valeur démo**

L'application donne immédiatement l'impression d'un vrai produit premium, pas d'un prototype Flutter par défaut.

**Backend tasks**

- Aucun changement backend requis.

**Frontend tasks**

- Finaliser un design system Flutter maison dans `presentation/theme` et `presentation/widgets`.
- Standardiser les tokens : couleurs, typographie, espacements, rayons, ombres, états.
- Créer ou consolider :
  - `RevisionScaffold`
  - `RevisionCard`
  - `SubjectCard`
  - `DocumentStatusCard`
  - `StudyActionCard`
  - `MasteryRing`
  - `AiSurface`
  - `RevisionButton`
  - `RevisionStatusPill`
  - `RevisionMessage`
- Refaire la navigation mobile-first avec une identité propre, tout en gardant GoRouter et les onglets persistants.
- Créer des états `loading`, `error`, `empty` premium.
- Adapter desktop/tablet avec rail et largeur de contenu cohérente.
- Remplacer les `Card`, `ListTile`, `OutlinedButton` trop génériques dans les pages principales.
- Garder l'accessibilité : labels, contraste, tailles tactiles.

**Genkit tasks**

- Non applicable.

**GenUI tasks**

- Préparer les surfaces GenUI avec `AiSurface`.
- Définir les contraintes visuelles des futurs composants dynamiques.
- S'assurer que les composants GenUI réutilisent les widgets premium.

**Modèle de données / Prisma**

- Aucun changement.

**API contracts**

- Aucun changement.

**Tests à écrire**

- Widget tests sur les pages principales.
- Tests responsive : mobile avec navigation basse, large layout avec rail.
- Tests états loading/error/empty.
- Golden tests optionnels sur les composants clés si l'équipe veut stabiliser l'identité visuelle.

**Critères d'acceptation**

- Les pages principales n'utilisent plus de surfaces Material brutes pour les cartes critiques.
- Les composants réutilisables couvrent les besoins de base.
- La navigation conserve les URLs existantes.
- Les écrans restent utilisables sur mobile et desktop.
- Les futures surfaces GenUI ont un conteneur visuel prêt.

**Risques / points d'attention**

- Ne pas refaire toute l'application visuellement avant d'avoir le flux IA.
- Ne pas créer un design system trop abstrait.
- Ne pas casser les tests de navigation existants.

### Phase 2 — Documents et knowledge units enrichis

**Objectif**

Rendre l'import de cours vraiment utile en exposant des notions mieux structurées, sourcées et lisibles.

**Valeur démo**

Après upload d'un PDF, l'étudiant voit que l'IA a compris le cours : notions, difficulté, ordre, extrait source et statut d'analyse.

**Backend tasks**

- Enrichir `ExtractedKnowledgeUnit` avec `sourceExcerpt`, `difficulty`, `order`, `confidence`, `pageNumber` si possible.
- Persister ces champs dans `KnowledgeUnit`.
- Ajouter un endpoint de liste des notions par document.
- Ajouter ou enrichir un endpoint de détail document.
- Améliorer les statuts de processing et les `errorCode` produits.
- Garder les échecs lisibles : PDF vide, texte non extractible, sortie IA invalide, notions vides.
- Vérifier l'ownership `studentId` sur chaque accès document/notion.

**Frontend tasks**

- Afficher l'état d'analyse dans la page détail matière.
- Ajouter une page ou section détail document.
- Afficher les notions détectées.
- Afficher les extraits sources quand disponibles.
- Afficher difficulté et confiance sans surcharger l'interface.
- Ajouter un bouton de retry ou relance si le document est en échec, si l'API le supporte.

**Genkit tasks**

- Améliorer le prompt d'extraction.
- Exiger une sortie structurée stricte.
- Demander des extraits courts et fidèles au cours.
- Ajouter une stratégie de découpage si le document dépasse `DOCUMENT_TEXT_MAX_CHARS`.
- Prévoir un fallback si le document est trop long ou trop pauvre.
- Valider avec Zod avant persistance.

**GenUI tasks**

- Non central dans cette phase.
- Préparer un futur `SourceExcerptCard`.

**Modèle de données / Prisma**

- Ajouter à `KnowledgeUnit` :
  - `sourceExcerpt String?`
  - `difficulty String?` ou enum dédiée
  - `order Int?`
  - `confidence Float?`
  - `pageNumber Int?`
- Ajouter éventuellement un champ `extractionVersion`.

**API contracts**

- `GET /documents/:documentId/knowledge-units`
- `GET /documents/:documentId`
- Optionnel : `POST /documents/:documentId/reprocess`

**Tests à écrire**

- Extraction avec `sourceExcerpt`.
- Persistance des champs enrichis.
- Endpoint ownership document.
- Document vide.
- Extraction échouée.
- Sortie Genkit invalide.
- UI document READY avec notions.
- UI document FAILED avec message clair.

**Critères d'acceptation**

- Depuis un document `READY`, l'utilisateur voit les notions extraites.
- Chaque notion affiche au moins titre, résumé et difficulté quand disponible.
- Les extraits sources sont visibles quand présents.
- Les documents en échec expliquent la raison.
- Aucun utilisateur ne peut lire les notions d'un autre étudiant.

**Risques / points d'attention**

- `pageNumber` peut être difficile sans extraction PDF plus avancée.
- Les extraits peuvent être halluciné si le prompt n'impose pas une copie courte du texte source.
- Les documents longs nécessitent une stratégie de chunking.

### Phase 3 — Résumés et fiches de révision

**Objectif**

Créer le premier usage IA visible après import : générer des supports de révision sourcés.

**Valeur démo**

L'étudiant importe un cours, clique sur générer, puis obtient une fiche claire avec résumé, points clés, pièges et sources.

**Backend tasks**

- Ajouter un module ou sous-module `summaries`.
- Ajouter les use cases :
  - `GenerateSummary`
  - `GetSummary`
  - `RegenerateSummary`
  - `GenerateRevisionSheet`
- Ajouter des repositories dédiés.
- Relier les résumés à un document, une matière et un étudiant.
- Autoriser la génération depuis un document `READY` uniquement.
- Stocker la version de prompt et de schéma.
- Préparer la régénération sans écraser silencieusement l'historique si nécessaire.

**Frontend tasks**

- Ajouter une section fiches dans le détail document.
- Ajouter un CTA `Générer une fiche`.
- Afficher les états génération en cours, succès, erreur.
- Afficher résumé express, fiche détaillée, points clés, pièges classiques.
- Afficher les références aux notions et extraits sources.
- Réutiliser `RevisionCard`, `AiSurface` et les widgets premium.

**Genkit tasks**

- Créer `generateSummaryFlow`.
- Créer `generateRevisionSheetFlow`.
- Structurer l'output :
  - résumé express
  - fiche détaillée
  - points clés
  - pièges classiques
  - références aux notions
  - références sources
- Valider les outputs strictement.
- Interdire les informations non présentes dans le cours.

**GenUI tasks**

- Ajouter les composants :
  - `SummaryCard`
  - `KeyPointsList`
  - `SourceExcerptCard`
  - `RevisionSheetSection`
- Les composants doivent être utilisables dans une session GenUI future.

**Modèle de données / Prisma**

- Ajouter `Summary`.
- Ajouter `RevisionSheet`.
- Ajouter `SourceReference` ou une relation structurée vers `KnowledgeUnit`.

**API contracts**

- `POST /documents/:documentId/summaries`
- `GET /documents/:documentId/summaries`
- `POST /documents/:documentId/revision-sheets`
- `GET /documents/:documentId/revision-sheets`

**Tests à écrire**

- Génération refusée si document non `READY`.
- Génération refusée si document appartient à un autre étudiant.
- Output Genkit valide persisté.
- Output invalide rejeté.
- UI affiche fiche existante.
- UI affiche erreur IA claire.

**Critères d'acceptation**

- Depuis un document `READY`, l'utilisateur peut générer et lire une fiche sourcée.
- La fiche est persistée et visible après redémarrage.
- Les sources sont affichées quand disponibles.
- La régénération est explicite.

**Risques / points d'attention**

- Les fiches peuvent coûter cher si générées trop souvent.
- Il faut limiter la taille des inputs.
- Il faut éviter les fiches trop longues sur mobile.

### Phase 4 — QCM intelligent enrichi

**Objectif**

Transformer le QCM existant en vraie activité pédagogique avec explications, correction détaillée et impact clair sur la maîtrise.

**Valeur démo**

L'étudiant répond à plusieurs questions basées sur son cours, reçoit une correction détaillée et voit sa maîtrise évoluer.

**Backend tasks**

- Étendre le modèle `DiagnosticQuiz`.
- Conserver les explications côté backend et ne les renvoyer qu'après soumission.
- Ajouter feedback par question.
- Ajouter score par notion.
- Ajouter difficulté.
- Ajouter nombre de questions configurable.
- Ajouter un contrat explicite `POST /activities/diagnostic-quiz`.
- Garder `POST /activities/next` comme compatibilité ou wrapper temporaire.
- Empêcher double soumission et réponses inconnues.
- Mettre à jour `MasteryState` de façon explicable.

**Frontend tasks**

- Refaire `DiagnosticQuizPage`.
- Afficher une question à la fois ou un parcours clair selon le nombre de questions.
- Afficher correction détaillée après validation.
- Montrer pourquoi chaque réponse est correcte ou incorrecte.
- Afficher score global et score par notion.
- Ajouter feedback visuel premium.

**Genkit tasks**

- Améliorer la génération de distracteurs.
- Garantir que le QCM est basé uniquement sur les `KnowledgeUnit`.
- Exiger une justification par bonne réponse.
- Exiger une explication pédagogique courte par distracteur si utile.
- Ajouter des tests de schéma stricts.

**GenUI tasks**

- Ajouter :
  - `McqQuestionCard`
  - `McqCorrectionPanel`
  - `ActivityResultCard`
  - `ChoiceFeedbackList`
- Les réponses utilisateur ne doivent pas être transmises comme UI arbitraire.

**Modèle de données / Prisma**

- Étendre `Question` ou ajouter une structure JSON versionnée pour :
  - `difficulty`
  - `knowledgeUnitId`
  - `feedbackByChoice`
- Étendre `ActivityResult` avec :
  - `score`
  - `perQuestionFeedback`
  - `perKnowledgeUnitScore`

**API contracts**

- `POST /activities/diagnostic-quiz`
- `POST /activities/:sessionId/result`
- Optionnel : `GET /activities/:sessionId`

**Tests à écrire**

- QCM généré valide.
- Correction détaillée disponible seulement après submit.
- Mastery update correct.
- Protection double soumission.
- Protection réponse inconnue.
- QCM cross-student interdit.
- UI affiche correction détaillée.

**Critères d'acceptation**

- Un QCM est généré depuis une notion réelle du cours.
- Les explications ne sont pas visibles avant validation.
- La correction explique les erreurs.
- La maîtrise est mise à jour et visible dans le plan du jour.

**Risques / points d'attention**

- La génération de distracteurs doit rester fidèle au cours.
- Le frontend ne doit pas tricher en ayant accès à `correctChoiceId` avant submit.
- Les scores doivent rester stables et compréhensibles.

### Phase 5 — Questions ouvertes avec correction IA

**Objectif**

Créer la fonctionnalité à fort effet de démonstration : l'étudiant rédige une réponse et reçoit une correction IA argumentée, sourcée et actionnable.

**Valeur démo**

L'app ne se limite plus aux QCM. Elle corrige une réponse ouverte comme un tuteur pédagogique.

**Backend tasks**

- Ajouter une activité `OpenQuestion`.
- Ajouter la génération de question ouverte depuis une notion.
- Ajouter la correction IA avec barème.
- Stocker :
  - question
  - réponse utilisateur
  - score
  - points présents
  - points manquants
  - erreurs
  - réponse modèle
  - conseils
  - sources
- Mettre à jour `MasteryState` selon score et confiance.
- Ajouter des endpoints dédiés.

**Frontend tasks**

- Ajouter un écran question ouverte.
- Ajouter un champ réponse long.
- Afficher l'état de correction en cours.
- Afficher une correction progressive et pédagogique.
- Afficher les points présents et manquants.
- Afficher une réponse modèle.
- Ajouter un CTA vers révision ciblée après correction.

**Genkit tasks**

- Créer `generateOpenQuestionFlow`.
- Créer `evaluateOpenAnswerFlow`.
- Définir des schémas stricts.
- Corriger uniquement à partir des notions et extraits fournis.
- Demander des citations courtes quand possible.
- Distinguer note, feedback, lacunes et conseils.

**GenUI tasks**

- Ajouter :
  - `OpenQuestionCard`
  - `CorrectionPanel`
  - `RubricCard`
  - `MissingPointsCard`
  - `ModelAnswerCard`

**Modèle de données / Prisma**

- Ajouter `OpenQuestion`.
- Ajouter `OpenAnswerEvaluation`.
- Étendre `ActivityType` avec `OPEN_QUESTION`.
- Ajouter des références sources.

**API contracts**

- `POST /activities/open-question`
- `POST /activities/:sessionId/open-answer`
- Optionnel : `GET /activities/:sessionId/evaluation`

**Tests à écrire**

- Génération question ouverte.
- Correction structurée.
- Correction refusée pour session d'un autre étudiant.
- Réponse vide refusée.
- Double correction gérée.
- Mastery update après correction.
- UI affiche barème et points manquants.

**Critères d'acceptation**

- L'étudiant répond à une question ouverte.
- Il reçoit une correction argumentée, sourcée et actionnable.
- Le score influence la maîtrise.
- La correction distingue feedback pédagogique et score.

**Risques / points d'attention**

- Risque de correction trop sévère ou trop vague.
- Risque d'hallucination si les sources ne sont pas fournies au flow.
- Les réponses longues peuvent nécessiter des limites de taille.

### Phase 6 — Session de révision IA avec GenUI

**Objectif**

Faire de GenUI le cœur de la démo en créant une session de révision interactive, dynamique et bornée.

**Valeur démo**

Le coach IA affiche une fiche, pose un QCM, corrige une réponse et propose l'action suivante dans une même session interactive.

**Backend tasks**

- Ajouter un module ou sous-module `revision-sessions`.
- Ajouter un orchestrateur de session.
- La session choisit entre :
  - résumé
  - QCM
  - question ouverte
  - explication
  - exercice
  - action suivante
- Stocker l'historique de session.
- Produire des réponses structurées transformables en composants GenUI.
- Ne jamais envoyer un composant non répertorié.
- Ajouter des garde-fous d'ownership.

**Frontend tasks**

- Créer l'écran `Révision IA`.
- Intégrer une surface GenUI bornée.
- Afficher l'historique de session.
- Ajouter un fallback UI si le payload est invalide.
- Permettre à l'utilisateur de répondre aux actions interactives.
- Réutiliser les composants premium.

**Genkit tasks**

- Créer `generateCoachNextActionFlow`.
- Éventuellement créer un flow d'orchestration qui retourne une intention structurée, pas de l'UI libre.
- Le flow doit choisir une action parmi une enum stricte.
- Le backend traduit l'intention en payload UI validé.

**GenUI tasks**

- Catalogue strict :
  - `SummaryCard`
  - `SourceExcerptCard`
  - `McqQuestionCard`
  - `OpenQuestionCard`
  - `CorrectionPanel`
  - `StudyActionCard`
  - `WeaknessCard`
  - `NextBestActionCard`
- Définir les schémas JSON de chaque composant.
- Valider chaque payload avant rendu.
- Fallback vers UI native en cas de payload invalide.

**Modèle de données / Prisma**

- Ajouter `RevisionSession`.
- Ajouter `RevisionSessionMessage`.
- Ajouter éventuellement `GeneratedUiBlock` avec `schemaVersion`, `componentType`, `payload`.

**API contracts**

- `POST /revision-sessions`
- `POST /revision-sessions/:sessionId/message`
- `GET /revision-sessions/:sessionId`

**Tests à écrire**

- Session créée pour le bon étudiant.
- Orchestrateur choisit une action valide.
- Payload GenUI invalide rejeté.
- Fallback frontend affiché.
- Historique conservé.
- Pas de fuite cross-student.

**Critères d'acceptation**

- Une session IA peut afficher dynamiquement une fiche.
- Elle peut poser un QCM.
- Elle peut corriger une réponse.
- Elle peut proposer l'action suivante.
- L'IA ne peut pas créer de widgets arbitraires.

**Risques / points d'attention**

- GenUI ne doit pas devenir un interpréteur libre de JSON IA.
- L'orchestration doit rester testable.
- Il faut éviter une UX de chatbot générique.

### Phase 7 — Plan du jour adaptatif avancé

**Objectif**

Transformer la page Aujourd'hui en vrai coach de planning.

**Valeur démo**

L'étudiant voit quoi faire maintenant, pourquoi c'est recommandé, et peut lancer directement la meilleure action.

**Backend tasks**

- Étendre `TodayPlan` avec plusieurs types d'actions :
  - `summary_review`
  - `diagnostic_quiz`
  - `open_question`
  - `weak_unit_review`
  - `spaced_repetition`
- Prendre en compte :
  - priorité matière
  - objectif de révision
  - temps disponible
  - mastery
  - `lastPracticedAt`
  - ancienneté du document
  - activité récente
- Ajouter des raisons pédagogiques explicites.
- Garder un ranking déterministe.
- Ajouter une API compatible avec les cartes d'action front.

**Frontend tasks**

- Refaire la page Aujourd'hui.
- Afficher les cartes d'actions.
- Afficher la progression quotidienne.
- Ajouter démarrage direct d'une activité.
- Montrer la raison de chaque recommandation.
- Gérer état vide si aucun document prêt.

**Genkit tasks**

- Optionnel : générer un message pédagogique personnalisé.
- Le ranking principal doit rester déterministe ou testable.
- Le message IA ne doit pas modifier l'ordre des actions.

**GenUI tasks**

- Ajouter ou réutiliser :
  - `StudyActionCard`
  - `WeaknessCard`
  - `NextBestActionCard`
- GenUI autorisé uniquement pour enrichir la présentation d'une recommandation validée.

**Modèle de données / Prisma**

- Ajouter `MasteryEvent` ou enrichir `ActivityResult`.
- Ajouter éventuellement `DailyPlanSnapshot` si l'on veut historiser les plans.
- Ajouter `lastReviewedAt` ou le dériver des activités.

**API contracts**

- `GET /today`
- Optionnel : `POST /today/items/:itemId/start`

**Tests à écrire**

- Plan stable à données égales.
- Priorisation des notions faibles.
- Plusieurs types d'activités.
- Pas de fuite cross-student.
- Page vide sans document prêt.
- Démarrage direct d'activité.

**Critères d'acceptation**

- Le plan contient plusieurs types d'action.
- Chaque action explique pourquoi elle est recommandée.
- Un QCM ou une question ouverte modifie les recommandations.
- L'utilisateur peut lancer l'activité depuis Aujourd'hui.

**Risques / points d'attention**

- Le plan ne doit pas être entièrement généré par IA.
- Trop d'actions peuvent rendre la page confuse.
- Les raisons doivent être pédagogiques, pas techniques.

### Phase 8 — Démo, qualité, sécurité et déploiement

**Objectif**

Rendre le projet présentable, testable et déployable.

**Valeur démo**

Une personne externe peut lancer la démo, suivre un scénario clair et voir Genkit + GenUI en action.

**Backend tasks**

- Stabiliser le démarrage API et worker.
- Documenter les variables d'environnement.
- Ajouter health checks utiles.
- Ajouter observabilité Genkit : nom du flow, durée, provider, erreurs, taille input.
- Ajouter timeouts IA.
- Ajouter limites de coûts.
- Ajouter stratégie de retry.
- Ajouter seed/demo data.
- Ajouter tests e2e critiques.
- Documenter le déploiement Dokploy.

**Frontend tasks**

- Ajouter un README démo côté app.
- Ajouter un mode démo si nécessaire, sans court-circuiter l'auth réelle en production.
- Préparer captures ou scénario de présentation.
- Vérifier web build si nécessaire.
- Vérifier iOS/macOS sur les routes principales.

**Genkit tasks**

- Centraliser la configuration provider.
- Documenter Google GenAI et Mistral via `@genkit-ai/compat-oai`.
- Ajouter tests de parsing des sorties.
- Ajouter fallback clair si provider indisponible.

**GenUI tasks**

- Documenter le catalogue.
- Ajouter tests de validation des payloads.
- Vérifier fallback invalide.
- Documenter où GenUI est autorisé.

**Modèle de données / Prisma**

- Ajouter migrations stables.
- Ajouter seed minimal.
- Ne pas lancer de migration automatique au boot.

**API contracts**

- Vérifier les contrats publics.
- Ajouter versionnement si les payloads GenUI deviennent stables.

**Tests à écrire**

- E2E happy path : login, matière, upload, processing, notions, fiche, QCM, correction, today.
- Tests worker.
- Tests ownership.
- Tests erreurs IA.
- Tests build frontend.

**Critères d'acceptation**

- Le scénario de démo est reproductible.
- Les erreurs IA sont explicites.
- Les données restent isolées.
- Les flows critiques passent en local.
- Le déploiement est documenté.

**Risques / points d'attention**

- Les coûts IA peuvent augmenter rapidement.
- Les erreurs worker peuvent être silencieuses sans observabilité.
- La démo doit éviter les PDF scannés tant que l'OCR n'est pas prévu.

## 5. Priorisation MVP

### Semaine 1

- Finaliser un design system minimal mais cohérent.
- Créer les composants premium essentiels : `RevisionScaffold`, `RevisionCard`, `SubjectCard`, `DocumentStatusCard`, `AiSurface`.
- Enrichir les `KnowledgeUnit`.
- Persister `sourceExcerpt`, `difficulty`, `order`, `confidence`.
- Ajouter le détail document.
- Exposer les notions par document.
- Améliorer les erreurs de processing.

### Semaine 2

- Ajouter résumés et fiches de révision.
- Ajouter les modèles `Summary` et `RevisionSheet`.
- Ajouter `generateSummaryFlow` et `generateRevisionSheetFlow`.
- Ajouter l'écran de fiche sourcée.
- Enrichir le QCM existant.
- Ajouter correction détaillée et feedback par question.
- Ajouter les premiers composants GenUI de résumé et QCM.

### Semaine 3

- Ajouter question ouverte corrigée.
- Ajouter `generateOpenQuestionFlow` et `evaluateOpenAnswerFlow`.
- Ajouter l'écran de réponse ouverte.
- Ajouter une session GenUI simple.
- Ajouter un catalogue strict avec fallback.
- Finaliser le script de démo.
- Ajouter seed/demo data et tests critiques.

## 6. Backlog détaillé

| ID | Titre | Description | Domaine | Priorité | Dépendances | Critères d'acceptation |
| --- | --- | --- | --- | --- | --- | --- |
| RVA-001 | Cartographie produit | Documenter les flows existants front/back et le vocabulaire métier. | Produit | P0 | Aucune | Le happy path et les concepts métier sont écrits. |
| RVA-002 | Cartographie backend | Lister modules, use cases, ports, adapters et endpoints actuels. | Backend | P0 | RVA-001 | Les gaps backend sont identifiés. |
| RVA-003 | Cartographie frontend | Lister pages, providers, repositories et surfaces UI critiques. | Frontend | P0 | RVA-001 | Les écrans de démo sont définis. |
| RVA-004 | Design tokens | Formaliser couleurs, typographies, espacements, rayons et surfaces. | Frontend | P0 | RVA-003 | Les pages peuvent consommer les tokens. |
| RVA-005 | RevisionScaffold | Créer un scaffold premium commun aux pages. | Frontend | P0 | RVA-004 | Les pages principales peuvent l'utiliser. |
| RVA-006 | RevisionCard | Créer une carte générique premium. | Frontend | P0 | RVA-004 | Les cartes Material brutes critiques sont remplaçables. |
| RVA-007 | SubjectCard | Créer la carte matière avec progression et priorité. | Frontend | P0 | RVA-006 | La liste matières utilise `SubjectCard`. |
| RVA-008 | DocumentStatusCard | Créer la carte document avec statut et erreur lisible. | Frontend | P0 | RVA-006 | La page matière affiche les documents avec ce composant. |
| RVA-009 | AiSurface | Créer une surface visuelle pour contenus IA et GenUI. | Frontend, GenUI | P0 | RVA-004 | Les futures activités IA ont un conteneur standard. |
| RVA-010 | États premium | Standardiser loading, error, empty et retry. | Frontend | P1 | RVA-005 | Les pages principales n'affichent plus d'états bruts. |
| RVA-011 | KnowledgeUnit enrichie | Étendre le modèle métier avec source, difficulté, ordre, confiance. | Backend | P0 | RVA-002 | Le domaine représente les nouveaux champs. |
| RVA-012 | Migration KnowledgeUnit | Ajouter les champs enrichis dans Prisma. | Backend | P0 | RVA-011 | Les champs sont persistés et migrés. |
| RVA-013 | Prompt extraction v2 | Améliorer le flow Genkit d'extraction de notions. | AI | P0 | RVA-011 | L'output contient des extraits sources validés. |
| RVA-014 | Endpoint notions document | Ajouter `GET /documents/:documentId/knowledge-units`. | Backend | P0 | RVA-012 | Ownership vérifié, réponse triée. |
| RVA-015 | Détail document enrichi | Ajouter ou enrichir le détail document avec statut, erreurs et notions. | Backend | P0 | RVA-014 | Le front peut afficher une page document complète. |
| RVA-016 | UI notions détectées | Afficher les notions et extraits sources dans le front. | Frontend | P0 | RVA-014 | Un document READY montre ses notions. |
| RVA-017 | Module summaries | Ajouter use cases et repository pour résumés. | Backend | P0 | RVA-015 | Le module respecte l'architecture actuelle. |
| RVA-018 | Modèles Summary et RevisionSheet | Ajouter les objets Prisma nécessaires. | Backend | P0 | RVA-017 | Résumés et fiches sont persistés. |
| RVA-019 | Flow résumé Genkit | Créer `generateSummaryFlow` structuré et sourcé. | AI | P0 | RVA-018 | Output validé par schéma strict. |
| RVA-020 | UI fiche document | Ajouter CTA génération et affichage fiche. | Frontend | P0 | RVA-019 | L'utilisateur lit une fiche depuis un document READY. |
| RVA-021 | GenUI résumé | Ajouter `SummaryCard`, `KeyPointsList`, `SourceExcerptCard`. | GenUI | P1 | RVA-020 | Les payloads invalides tombent en fallback. |
| RVA-022 | DiagnosticQuiz v2 | Étendre le contrat QCM avec difficulté et feedback. | Backend | P0 | RVA-011 | Les sessions stockent les métadonnées nécessaires. |
| RVA-023 | Correction QCM détaillée | Renvoyer explications après soumission uniquement. | Backend | P0 | RVA-022 | Les réponses correctes ne fuient pas avant submit. |
| RVA-024 | UI correction QCM | Refaire l'écran QCM avec correction détaillée. | Frontend | P0 | RVA-023 | L'étudiant comprend ses erreurs. |
| RVA-025 | GenUI QCM | Ajouter `McqQuestionCard`, `McqCorrectionPanel`, `ActivityResultCard`. | GenUI | P1 | RVA-024 | Une activité QCM peut être rendue via catalogue. |
| RVA-026 | Modèles question ouverte | Ajouter `OpenQuestion`, `OpenAnswerEvaluation` et type activité. | Backend | P0 | RVA-018 | Le schéma supporte une activité ouverte. |
| RVA-027 | Flow génération question ouverte | Créer `generateOpenQuestionFlow`. | AI | P0 | RVA-026 | La question est basée sur une notion source. |
| RVA-028 | Flow correction réponse ouverte | Créer `evaluateOpenAnswerFlow` avec barème. | AI | P0 | RVA-027 | La correction distingue score, feedback et lacunes. |
| RVA-029 | UI question ouverte | Ajouter écran réponse longue et correction. | Frontend | P0 | RVA-028 | L'étudiant obtient une correction lisible. |
| RVA-030 | GenUI correction ouverte | Ajouter `OpenQuestionCard`, `CorrectionPanel`, `RubricCard`. | GenUI | P1 | RVA-029 | Les corrections peuvent être rendues dynamiquement. |
| RVA-031 | Module revision sessions | Ajouter orchestrateur et historique de session. | Backend | P1 | RVA-025, RVA-030 | Une session peut enchaîner plusieurs actions. |
| RVA-032 | Écran Révision IA | Créer une page dédiée à la session coach IA. | Frontend | P1 | RVA-031 | L'utilisateur peut démarrer une session. |
| RVA-033 | Validateur GenUI strict | Centraliser validation catalogue et fallback. | GenUI | P0 | RVA-021 | Aucun widget arbitraire n'est rendu. |
| RVA-034 | TodayPlan multi-actions | Étendre le plan du jour avec plusieurs actions. | Backend | P1 | RVA-026 | Le plan propose QCM, fiche, question ouverte. |
| RVA-035 | UI Aujourd'hui v2 | Refaire la page avec cartes d'actions et progression. | Frontend | P1 | RVA-034 | L'utilisateur lance une action depuis Aujourd'hui. |
| RVA-036 | Tests ranking Today | Garantir stabilité et priorité des notions faibles. | Backend | P1 | RVA-034 | Le plan est déterministe à données égales. |
| RVA-037 | Seed démo | Ajouter données de démonstration réalistes. | Backend | P1 | RVA-019 | La démo peut être lancée sans préparation longue. |
| RVA-038 | Observabilité Genkit | Logger flow, durée, provider, erreurs et taille input. | AI, Backend | P1 | RVA-013 | Les erreurs IA sont diagnostiquables. |
| RVA-039 | E2E critique | Ajouter tests happy path backend et front ciblés. | Tests | P0 | RVA-024 | Le parcours principal est couvert. |
| RVA-040 | README démo | Documenter setup local, variables, worker et scénario. | Documentation | P0 | RVA-037 | Un développeur peut rejouer la démo. |

## 7. Contrats API proposés

### GET `/documents/:documentId/knowledge-units`

**Payload**

Aucun.

**Réponse**

```json
{
  "documentId": "doc_123",
  "items": [
    {
      "id": "ku_123",
      "title": "Contrôle de constitutionnalité",
      "summary": "Synthèse courte de la notion.",
      "sourceExcerpt": "Extrait court issu du cours.",
      "difficulty": "MEDIUM",
      "order": 1,
      "confidence": 0.86,
      "pageNumber": 12
    }
  ]
}
```

**Erreurs**

- `401` token absent ou invalide.
- `404` document inexistant ou non accessible.
- `409` document pas encore `READY`.

**Notes de sécurité**

- Vérifier que le document appartient au `studentId`.
- Ne jamais exposer de chemin de stockage interne.

### POST `/documents/:documentId/summaries`

**Payload**

```json
{
  "format": "express",
  "forceRegenerate": false
}
```

**Réponse**

```json
{
  "summaryId": "sum_123",
  "status": "READY",
  "format": "express",
  "title": "Résumé du cours",
  "content": "Résumé structuré.",
  "keyPoints": ["Point 1", "Point 2"],
  "sourceReferences": [
    {
      "knowledgeUnitId": "ku_123",
      "excerpt": "Extrait source."
    }
  ]
}
```

**Erreurs**

- `400` format invalide.
- `401` token invalide.
- `404` document non accessible.
- `409` document non prêt.
- `422` sortie IA invalide.
- `429` limite de génération atteinte.

**Notes de sécurité**

- Génération autorisée uniquement pour le propriétaire du document.
- Limiter les régénérations.

### GET `/documents/:documentId/summaries`

**Payload**

Aucun.

**Réponse**

```json
{
  "documentId": "doc_123",
  "items": [
    {
      "id": "sum_123",
      "format": "express",
      "title": "Résumé du cours",
      "createdAt": "2026-06-14T10:00:00.000Z"
    }
  ]
}
```

**Erreurs**

- `401` token invalide.
- `404` document non accessible.

**Notes de sécurité**

- Filtrer par `studentId`.

### POST `/activities/diagnostic-quiz`

**Payload**

```json
{
  "subjectId": "sub_123",
  "knowledgeUnitId": "ku_123",
  "questionCount": 5,
  "difficulty": "adaptive"
}
```

**Réponse**

```json
{
  "sessionId": "act_123",
  "type": "DIAGNOSTIC_QUIZ",
  "title": "Diagnostic rapide",
  "questions": [
    {
      "id": "q_1",
      "prompt": "Question sans réponse révélée.",
      "choices": [
        { "id": "a", "label": "Choix A" },
        { "id": "b", "label": "Choix B" }
      ],
      "difficulty": "MEDIUM"
    }
  ]
}
```

**Erreurs**

- `400` payload invalide.
- `401` token invalide.
- `404` matière ou notion inaccessible.
- `409` aucune notion prête.
- `422` génération IA invalide.

**Notes de sécurité**

- Ne pas renvoyer `correctChoiceId` avant soumission.
- Vérifier l'ownership matière et notion.

### POST `/activities/open-question`

**Payload**

```json
{
  "subjectId": "sub_123",
  "knowledgeUnitId": "ku_123",
  "difficulty": "adaptive"
}
```

**Réponse**

```json
{
  "sessionId": "act_456",
  "type": "OPEN_QUESTION",
  "question": {
    "id": "oq_123",
    "prompt": "Expliquez le rôle du contrôle de constitutionnalité.",
    "expectedDurationMinutes": 8,
    "rubricPreview": ["Définition", "Rôle", "Exemple"]
  }
}
```

**Erreurs**

- `400` payload invalide.
- `401` token invalide.
- `404` ressource inaccessible.
- `422` sortie IA invalide.

**Notes de sécurité**

- Ne pas exposer la réponse modèle avant correction.

### POST `/activities/:sessionId/open-answer`

**Payload**

```json
{
  "answer": "Réponse rédigée par l'étudiant."
}
```

**Réponse**

```json
{
  "sessionId": "act_456",
  "score": 0.72,
  "presentPoints": ["Définition correcte"],
  "missingPoints": ["Exemple jurisprudentiel absent"],
  "errors": ["Confusion entre contrôle a priori et a posteriori"],
  "modelAnswer": "Réponse modèle courte.",
  "advice": "Revoir la différence entre les deux types de contrôle.",
  "sourceReferences": [
    {
      "knowledgeUnitId": "ku_123",
      "excerpt": "Extrait du cours."
    }
  ]
}
```

**Erreurs**

- `400` réponse vide ou trop longue.
- `401` token invalide.
- `404` session inaccessible.
- `409` session déjà corrigée.
- `422` correction IA invalide.

**Notes de sécurité**

- Vérifier que la session appartient au `studentId`.
- Limiter la taille de réponse.

### POST `/revision-sessions`

**Payload**

```json
{
  "subjectId": "sub_123",
  "goal": "prepare_exam",
  "durationMinutes": 20
}
```

**Réponse**

```json
{
  "sessionId": "rs_123",
  "status": "ACTIVE",
  "firstAction": {
    "type": "SUMMARY_CARD",
    "payload": {}
  }
}
```

**Erreurs**

- `400` payload invalide.
- `401` token invalide.
- `404` matière inaccessible.
- `409` aucun document prêt.

**Notes de sécurité**

- Le backend choisit les composants autorisés.
- Le payload GenUI doit être validé avant envoi.

### POST `/revision-sessions/:sessionId/message`

**Payload**

```json
{
  "message": "Je veux travailler les notions faibles.",
  "clientContext": {
    "lastComponentId": "block_123"
  }
}
```

**Réponse**

```json
{
  "sessionId": "rs_123",
  "blocks": [
    {
      "id": "block_124",
      "component": "NextBestActionCard",
      "schemaVersion": 1,
      "payload": {}
    }
  ]
}
```

**Erreurs**

- `400` message invalide.
- `401` token invalide.
- `404` session inaccessible.
- `422` payload GenUI invalide.

**Notes de sécurité**

- L'IA ne choisit qu'une intention.
- Le backend transforme l'intention en composants catalogue.

### GET `/today`

**Payload**

Aucun.

**Réponse**

```json
{
  "generatedAt": "2026-06-14T10:00:00.000Z",
  "items": [
    {
      "id": "today_1",
      "subjectId": "sub_123",
      "subjectName": "Droit constitutionnel",
      "knowledgeUnitId": "ku_123",
      "knowledgeUnitTitle": "Contrôle de constitutionnalité",
      "action": "open_question",
      "estimatedMinutes": 12,
      "masteryScore": 0.42,
      "reason": "Notion fragile et récemment mal réussie."
    }
  ]
}
```

**Erreurs**

- `401` token invalide.

**Notes de sécurité**

- Le plan ne retourne que les matières du `studentId`.
- Le ranking doit rester déterministe.

## 8. Modèle de données proposé

Ces évolutions Prisma sont indicatives. La migration finale doit être écrite après inspection du `schema.prisma` réel au moment de l'implémentation.

### KnowledgeUnit enrichie

Champs proposés :

- `sourceExcerpt String?`
- `difficulty KnowledgeDifficulty?`
- `order Int?`
- `confidence Float?`
- `pageNumber Int?`
- `extractionVersion String?`
- `sourceReferences SourceReference[]`

### Summary

Objet métier :

- `id`
- `studentId`
- `subjectId`
- `documentId`
- `format`
- `title`
- `content`
- `keyPoints Json`
- `pitfalls Json?`
- `schemaVersion`
- `promptVersion`
- `createdAt`
- `updatedAt`

### RevisionSheet

Objet métier :

- `id`
- `studentId`
- `subjectId`
- `documentId`
- `title`
- `sections Json`
- `keyPoints Json`
- `classicMistakes Json`
- `sourceReferences SourceReference[]`
- `schemaVersion`
- `createdAt`
- `updatedAt`

### ActivitySession étendue

Évolutions :

- Étendre `ActivityType` avec `OPEN_QUESTION`.
- Ajouter `subjectId`.
- Ajouter `knowledgeUnitId`.
- Ajouter `difficulty`.
- Ajouter `schemaVersion`.
- Ajouter `metadata Json?`.

### OpenQuestion

Objet métier :

- `id`
- `sessionId`
- `studentId`
- `subjectId`
- `knowledgeUnitId`
- `prompt`
- `rubric Json`
- `expectedAnswer Json?`
- `sourceReferences SourceReference[]`
- `createdAt`

### OpenAnswerEvaluation

Objet métier :

- `id`
- `sessionId`
- `studentId`
- `answer`
- `score Float`
- `presentPoints Json`
- `missingPoints Json`
- `errors Json`
- `modelAnswer String`
- `advice String`
- `sourceReferences SourceReference[]`
- `createdAt`

### SourceReference

Objet métier :

- `id`
- `studentId`
- `documentId`
- `knowledgeUnitId?`
- `summaryId?`
- `revisionSheetId?`
- `openQuestionId?`
- `openAnswerEvaluationId?`
- `excerpt`
- `pageNumber?`
- `createdAt`

### MasteryEvent ou ActivityResult enrichi

Option A : enrichir `ActivityResult`.

- `score Float`
- `perKnowledgeUnitScore Json`
- `feedback Json`
- `activityType`

Option B : ajouter `MasteryEvent`.

- `id`
- `studentId`
- `subjectId`
- `knowledgeUnitId`
- `activitySessionId`
- `delta`
- `scoreBefore`
- `scoreAfter`
- `reason`
- `createdAt`

Recommandation : ajouter `MasteryEvent` dès que le plan du jour doit expliquer les changements de maîtrise.

## 9. Stratégie Genkit

### `extractKnowledgeUnitsFlow`

- Input schema : `documentId`, `subjectName`, `documentTitle`, `text`, `maxUnits`, `schemaVersion`.
- Output schema : liste de notions avec `title`, `summary`, `sourceExcerpt`, `difficulty`, `order`, `confidence`, `pageNumber`.
- Garde-fous : texte limité, sortie JSON stricte, extraits courts, refus si pas assez de contenu.
- Tests : PDF texte valide, PDF vide, output invalide, document long.
- Fallback : marquer le document `FAILED` avec code explicite ou relancer sur chunk plus petit.
- Source grounding : `sourceExcerpt` doit être copié ou paraphrasé très proche du texte fourni.

### `generateSummaryFlow`

- Input schema : `documentId`, `subjectName`, `documentTitle`, `knowledgeUnits`, `sourceExcerpts`, `format`.
- Output schema : `title`, `content`, `keyPoints`, `pitfalls`, `sourceReferences`.
- Garde-fous : ne pas ajouter d'informations externes, référencer les notions utilisées.
- Tests : résumé express, sortie invalide, document sans notion.
- Fallback : message d'échec génération ou résumé depuis notions sans texte complet.
- Source grounding : chaque section importante doit pouvoir pointer vers une notion ou un extrait.

### `generateRevisionSheetFlow`

- Input schema : `documentId`, `subjectName`, `knowledgeUnits`, `sourceExcerpts`, `targetLevel`.
- Output schema : sections, définitions, points clés, pièges, mini-plan de révision.
- Garde-fous : pas de contenu non sourcé, longueur maximale.
- Tests : fiche complète, fiche trop longue, source manquante.
- Fallback : générer une fiche simplifiée depuis les summaries existants.
- Source grounding : références obligatoires par section.

### `generateDiagnosticQuizFlow`

- Input schema : `subjectName`, `knowledgeUnit`, `sourceExcerpt`, `questionCount`, `difficulty`.
- Output schema : questions, choix, bonne réponse, explication, feedback par choix.
- Garde-fous : distracteurs plausibles, pas de réponse évidente, pas de contenu hors notion.
- Tests : nombre de questions, unicité choix, bonne réponse existante, output invalide.
- Fallback : réduire le nombre de questions ou retourner une erreur IA claire.
- Source grounding : explication liée au résumé ou extrait.

### `generateOpenQuestionFlow`

- Input schema : `subjectName`, `knowledgeUnit`, `sourceExcerpt`, `difficulty`.
- Output schema : prompt, barème, points attendus, durée estimée.
- Garde-fous : question ouverte mais corrigeable, pas trop large.
- Tests : prompt valide, barème non vide, notion fragile.
- Fallback : question plus simple depuis le titre et le résumé.
- Source grounding : barème basé sur la notion fournie.

### `evaluateOpenAnswerFlow`

- Input schema : `question`, `rubric`, `answer`, `knowledgeUnit`, `sourceExcerpts`.
- Output schema : score, points présents, points manquants, erreurs, réponse modèle, conseils, sources.
- Garde-fous : score entre 0 et 1, feedback pédagogique distinct du score, correction non humiliante.
- Tests : bonne réponse, réponse partielle, réponse hors sujet, réponse vide.
- Fallback : correction simplifiée sans sources si le modèle échoue, ou erreur explicite.
- Source grounding : erreurs et modèle doivent référencer les extraits disponibles.

### `generateCoachNextActionFlow`

- Input schema : `studentContext`, `subjectContext`, `masteryState`, `availableActions`, `lastMessages`.
- Output schema : intention enum, justification pédagogique, paramètres d'action.
- Garde-fous : choix limité à des actions autorisées, pas de composant UI libre.
- Tests : notion faible, document sans fiche, session après échec QCM.
- Fallback : ranking déterministe sans IA.
- Source grounding : si l'action cite le cours, elle doit pointer vers des notions existantes.

## 10. Stratégie GenUI

### Catalogue frontend

Composants autorisés :

- `SummaryCard`
- `KeyPointsList`
- `SourceExcerptCard`
- `RevisionSheetSection`
- `McqQuestionCard`
- `McqCorrectionPanel`
- `ActivityResultCard`
- `OpenQuestionCard`
- `CorrectionPanel`
- `RubricCard`
- `MissingPointsCard`
- `ModelAnswerCard`
- `StudyActionCard`
- `WeaknessCard`
- `NextBestActionCard`

### Schémas JSON

Chaque composant doit avoir :

- `component`
- `schemaVersion`
- `id`
- `payload`
- `sourceReferences?`

Chaque payload doit être validé côté Flutter avant rendu. Les validations doivent vérifier :

- type du composant connu ;
- version supportée ;
- champs obligatoires ;
- limites de longueur ;
- absence de HTML ou markdown dangereux si non supporté ;
- IDs liés à des ressources déjà autorisées côté backend.

### Où GenUI est autorisé

- Session Révision IA.
- Rendu enrichi de fiche.
- Rendu d'activité QCM après validation.
- Rendu de correction de question ouverte.
- Cartes d'action du plan du jour si l'action vient déjà d'un ranking backend validé.

### Où GenUI est interdit

- Authentification.
- Navigation globale.
- Gestion des permissions.
- Upload de documents.
- Choix de routes sensibles.
- Affichage d'informations non autorisées.
- Interprétation directe d'un texte libre IA en widget.

### Fallback UI

Si le payload GenUI est invalide :

- ne pas rendre le composant ;
- afficher une carte native `RevisionMessage` ;
- logger l'erreur côté client ;
- garder l'activité utilisable si un contrat natif existe ;
- ne jamais bloquer toute la session pour un bloc invalide.

## 11. Définition de “done”

Une phase est terminée seulement si :

- les tests unitaires utiles sont présents ;
- les tests d'intégration critiques passent ;
- le frontend gère les états loading, error et empty ;
- les erreurs IA sont explicites ;
- les données restent isolées par `studentId` ;
- les endpoints vérifient l'ownership ;
- les outputs Genkit sont typés et validés ;
- les payloads GenUI sont bornés par le catalogue ;
- un fallback existe pour les payloads GenUI invalides ;
- le flow est démontrable manuellement ;
- la documentation de démo est mise à jour quand le comportement utilisateur change.
