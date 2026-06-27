# Neralune V5 — Maquette-first roadmap

## 1. Pourquoi une V5

La V4 a permis de construire un couloir MVP demo coherent : ouvrir Neralune, arriver sur Aujourd'hui, consulter Cours, ouvrir un detail cours, choisir une duree, lancer une session courte, lire un bilan et revenir au cours ou a la fiche. Le verrou `LOCK-01`, les lots `DEMO-02` a `DEMO-05` et `POST-DEMO-01` ont confirme que ce couloir est montrable avec reserves mineures.

L'audit visuel mobile dark du 27 juin 2026 montre pourtant que la promesse produit n'est pas encore tenue. Le flow est techniquement present, mais la perception utilisateur reste trop fragile : un CTA de revision rapide peut echouer avec `COURSE_QUICK_REVISION_QUESTIONS_PREPARING`, Activites/QCM peuvent rester bloques en spinner, Aujourd'hui peut afficher "rien de pret" alors qu'une fiche existe, les noms de PDF bruts polluent le parcours, et plusieurs surfaces ressemblent encore a des pages parking ou a des ecrans internes.

La nouvelle reference devient donc la maquette cible. V5 ne doit pas etre une nouvelle grosse feature. V5 doit transformer l'existant en experience mobile dark, claire, fiable et visuellement alignee.

Priorite V5 : fiabilite du flow, CTA honnetes, et alignement visuel prouve par captures.

## 2. Vision produit

Neralune est une app de revision coachee. Elle transforme les cours importes en parcours quotidien : l'utilisateur sait quoi travailler, comprend pourquoi, revise vite, recoit un feedback lisible et voit une progression motivante.

La direction produit V5 est :

- sombre, premium et claire ;
- proche d'un Duolingo genere depuis les cours ;
- centree sur Aujourd'hui, Cours, Session, Feedback et Progres ;
- pedagogique avant d'etre technique ;
- honnete sur les etats reels : source prete, fiche prete, questions en preparation, session prete ;
- capable de proposer une belle fiche de revision quand la session n'est pas encore disponible.

La boucle cible est :

```text
Onboarding -> Aujourd'hui -> Cours -> Detail cours -> Choix duree -> Session question -> Feedback reponse -> Bilan resultat -> Progres
```

La fiche de revision n'est pas une page secondaire faible : c'est l'objet pedagogique premium qui rend Neralune utile meme quand les questions ne sont pas encore pretes.

## 3. Reference visuelle

La maquette cible contient 10 ecrans de reference :

1. Onboarding
2. Aujourd'hui
3. Cours
4. Detail cours
5. Selecteur matiere
6. Choix duree
7. Session question
8. Feedback reponse
9. Bilan resultat
10. Progres

Cette maquette devient la reference principale pour chaque lot V5. Les captures actuelles de l'audit mobile dark sont conservees dans :

```text
output/product-audit/neralune-full-app-2026-06-27/screenshots/
```

Le rapport source est :

```text
output/product-audit/neralune-full-app-2026-06-27/report.md
```

## 4. Etat actuel resume

### Deja bon

- Le dark mode a une base interessante : cartes sombres, accents bleu/violet, bottom nav et ton premium possible.
- La fiche de revision est le meilleur morceau actuel : titre clair, sections lisibles, potentiel pedagogique fort.
- Le selecteur matiere en bottom sheet est proche de la maquette.
- Le couloir V4 a deja pose une navigation principale sobre : Aujourd'hui, Cours, Progres.
- La session quick immersive et le bilan final existent dans le couloir demo V4, meme si l'audit n'a pas pu les atteindre via le flow bloque.

### Moyen

- Cours est proche de la structure cible, mais manque de densite pedagogique et de motivation.
- Detail cours affiche un parcours, mais encore trop froid : progression a 0%, noms techniques, peu de checkpoints vivants.
- Progres est structure mais peu motivant avec tout a 0%.
- Profil est propre, mais le mode "Systeme" contredit le dark mode comme reference produit.
- La question ouverte a un bon fond pedagogique, mais la correction est lente et trop textuelle.

### Bloquant

- Le CTA de revision rapide peut promettre une session puis echouer avec `409 COURSE_QUICK_REVISION_QUESTIONS_PREPARING` sans feedback visible.
- Activites/QCM peuvent rester bloques en spinner apres 10 secondes.
- Aujourd'hui peut annoncer que rien n'est pret alors qu'un cours et une fiche existent.
- Des noms de PDF bruts comme `1782570835662-support01.pdf` apparaissent dans des ecrans critiques.

### Legacy ou parking

- Sources globales peut ressembler a une page parking.
- Activites sans contexte expose des modes desactives ou vides.
- Reviser legacy peut afficher un beau layout mais un CTA non fiable.
- Menus de cours et actions avancees restent utiles pour compatibilite, mais ne doivent pas redevenir le parcours principal.
- L'onboarding route actuel ressemble a un formulaire utilitaire, pas a l'introduction emotionnelle de la maquette.

## 5. Principes V5

- Maquette-first : chaque lot part d'un ecran cible et non d'une envie technique.
- Visual QA obligatoire : aucun lot n'est termine sans capture.
- Pas de lot valide sans comparaison avec la maquette cible.
- Pas de CTA mensonger : un bouton principal doit lancer l'action promise ou expliquer l'etat reel.
- Pas de spinner infini : timeout, message, retry ou fallback obligatoire.
- Pas de noms techniques visibles dans l'UI critique.
- Etat "pret" toujours qualifie : source prete, fiche prete, questions en preparation, questions pretes, session prete.
- Luna reste legere, coherente et non envahissante.
- Dark mode est la reference produit pendant V5.
- Les fiches doivent etre belles, pedagogiques et actionnables, pas seulement des dumps de texte.
- Le backend et les moteurs peuvent rester internes, mais l'UI doit parler en benefices utilisateur.

## 6. Decoupage en phases

### Phase 0 — Fiabilite visible

Objectif utilisateur : je ne tombe jamais sur un bouton qui ment, un spinner infini ou une page morte.

Ecrans concernes : Aujourd'hui, Reviser legacy, Activites, QCM, Detail cours, Fiche, Sources.

Probleme resolu : l'audit a montre que le flow peut casser la confiance avant meme que la maquette ait une chance de convaincre.

Lots proposes : V5-01, V5-02, V5-03.

Non-objectifs : pas de Study Session V4 complete, pas de nouveau moteur, pas de refonte onboarding, pas de GenUI.

Critères visuels d'acceptation :

- les CTA primaires affichent un etat coherent ;
- aucun spinner ne reste seul sans message apres un delai raisonnable ;
- les filenames bruts disparaissent du parcours principal ;
- les fallbacks sont visibles, tactiles et utiles.

Tests attendus :

- widget tests sur CTA disabled/ready/preparing ;
- tests router sur fallbacks ;
- tests d'etats loading/error/timeout ;
- tests de mapping labels humains.

Captures attendues :

- before/after Aujourd'hui ;
- before/after Reviser ou CTA quick ;
- before/after Activites/QCM timeout ;
- before/after Detail cours ou source avec filename brut ;
- reference maquette liee.

### Phase 1 — Cockpit quotidien et parcours cours

Objectif utilisateur : j'ouvre Neralune et je comprends exactement quoi faire aujourd'hui.

Ecrans concernes : Aujourd'hui, Cours, Detail cours, Fiche.

Probleme resolu : Today ne joue pas encore son role de coach et Detail cours ressemble encore trop a une liste d'extractions.

Lots proposes : V5-04, V5-05, V5-06.

Non-objectifs : pas de vraie gamification lourde, pas de streak avance, pas de progression backend complexe.

Critères visuels d'acceptation :

- Today propose une mission du jour meme quand les questions ne sont pas pretes ;
- Detail cours montre des checkpoints et une prochaine action claire ;
- la fiche donne envie de lire et de se tester ;
- la progression a 0% est expliquee, pas deprimante.

Tests attendus :

- widget tests Today 0%, fiche prete, questions preparing, session ready ;
- tests detail cours checkpoints et CTA contextuel ;
- tests fiche sections, sources pliables et CTA.

Captures attendues :

- Aujourd'hui avant/apres ;
- Detail cours avant/apres ;
- Fiche avant/apres ;
- comparaison maquette ecrans 2, 4 et fiche cible interne.

### Phase 2 — Boucle de revision maquette

Objectif utilisateur : je choisis une duree, je reponds, je comprends ma reponse, je vois mon bilan.

Ecrans concernes : Choix duree, Session question, Feedback reponse, Bilan resultat.

Probleme resolu : l'effet Duolingo-like depend d'une boucle courte, tactile et rassurante.

Lots proposes : V5-07, V5-08, V5-09, V5-10.

Non-objectifs : pas de backend IA complexe, pas de sujet long, pas d'epreuve blanche, pas de planner complet si le moteur quick suffit pour la maquette.

Critères visuels d'acceptation :

- choix duree proche de la maquette et honnete sur la disponibilite ;
- question lisible, reponses tactiles, CTA clair ;
- feedback immediat comprehensible sans bloc long ;
- bilan donne une victoire et une prochaine action.

Tests attendus :

- widget tests duration picker ;
- tests session mobile sans bottom nav ;
- tests feedback juste/faux/erreur ;
- tests bilan avec et sans corrections.

Captures attendues :

- choix duree ;
- session question ;
- feedback reponse ;
- bilan resultat ;
- comparaison maquette ecrans 6 a 9.

### Phase 3 — Motivation, progres et premiere impression

Objectif utilisateur : je sens que Neralune m'accompagne dans la duree et pas seulement sur une session.

Ecrans concernes : Progres, Onboarding, Profil.

Probleme resolu : Progres manque de motivation et l'onboarding ne porte pas encore la promesse emotionnelle.

Lots proposes : V5-11, V5-12.

Non-objectifs : pas de mascot system complet, pas de badges avances, pas de vraie economie de jeu.

Critères visuels d'acceptation :

- Progres reste motivant avec peu de donnees ;
- l'onboarding presente Neralune avant le setup matiere ;
- le dark mode est explicite ;
- Luna soutient le ton sans devenir le sujet.

Tests attendus :

- widget tests onboarding/login/setup ;
- tests Progres empty/low-data ;
- tests theme dark par defaut ou choix explicite.

Captures attendues :

- onboarding/login ;
- Progres ;
- Profil/theme si modifie ;
- comparaison maquette ecrans 1 et 10.

## 7. Lots proposes

### V5-01 — CTA honnetes + etats de preparation

Phrase produit : aucun bouton principal ne promet une revision qui ne peut pas demarrer.

Scope :

- traiter `COURSE_QUICK_REVISION_QUESTIONS_PREPARING` ;
- distinguer questions en preparation, session prete, fiche prete, source prete ;
- rendre le CTA principal disabled, alternatif ou contextuel selon l'etat ;
- proposer `Lire la fiche` comme fallback fiable ;
- proposer `Question ouverte` seulement si le flow est fiable ;
- afficher un message visible si un lancement echoue.

Fichiers probablement concernes :

- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_quick_revision_launcher.dart`
- `lib/presentation/pages/today/today_page.dart`
- `lib/presentation/pages/revisions/`
- repositories/controlleurs de revision quick selon structure existante
- tests courses, today, revision sessions et router

Non-objectifs :

- pas de nouvelle facade Study Session ;
- pas de generation IA ;
- pas de refonte visuelle complete ;
- pas de backend sauf si le contrat existant ne permet pas de connaitre l'etat.

Critères d'acceptation :

- un `409 COURSE_QUICK_REVISION_QUESTIONS_PREPARING` produit un etat UI comprehensible ;
- le CTA principal ne reste pas actif si la session est indisponible ;
- la fiche reste accessible si elle est prete ;
- aucun etat ne finit en silence.

Preuves visuelles obligatoires :

- CTA avant lancement ;
- etat questions en preparation ;
- etat session prete ;
- fallback `Lire la fiche` ;
- capture de comparaison avec maquette Aujourd'hui/Detail cours/Choix duree.

Tests obligatoires :

- widget tests sur preparing/ready/error ;
- test route fallback fiche ;
- test absence de CTA mensonger ;
- `git diff --check`.

Risques :

- etat reel non disponible dans le contrat ;
- confusion entre source prete, fiche prete et questions pretes ;
- tentation d'ouvrir V4-05B trop tot.

### V5-02 — Anti-spinner + surfaces legacy

Phrase produit : aucun utilisateur ne tombe sur un spinner infini ou une page parking dans le flow demo.

Scope :

- traiter Activites, QCM, Reviser, Sources globales ;
- ajouter timeouts UI et messages d'etat ;
- ajouter retry, retour utile ou redirection vers fiche/cours ;
- masquer ou declasser les pages parking hors parcours principal ;
- rendre les entrees de menu honnetes si indisponibles.

Fichiers probablement concernes :

- routes Activites/Reviser/Sources ;
- pages QCM et open question ;
- `lib/app/router/`
- tests router et widget sur loading/error.

Non-objectifs :

- pas de suppression definitive de routes legacy ;
- pas de refonte des moteurs ;
- pas de nouveau mode.

Critères d'acceptation :

- aucun spinner critique ne reste seul apres 8 a 10 secondes ;
- chaque page parking propose une action utile ;
- les routes legacy restent compatibles mais ne polluent pas le flow principal ;
- les actions menu donnent feedback ou raison d'indisponibilite.

Preuves visuelles obligatoires :

- before/after Activites spinner ;
- before/after Sources globales ;
- before/after Reviser legacy si expose ;
- capture menu cours avec etats coherents.

Tests obligatoires :

- tests timeout/loading ;
- tests redirection ou retry ;
- tests router legacy hors shell ;
- `git diff --check`.

Risques :

- cacher une route utile sans alternative ;
- creer un faux sentiment de disponibilite ;
- complexifier la navigation.

### V5-03 — Humanisation sources / PDF / notions

Phrase produit : aucun nom de fichier brut ne pollue le parcours principal.

Scope :

- remplacer `1782570835662-support01.pdf` par `Support 1` ou `Introduction au droit` dans l'UI principale ;
- conserver la source originale en secondaire ;
- humaniser notions, documents, extraits et labels de provenance ;
- afficher page/source/confiance seulement si utile et lisible ;
- appliquer la regle dans Detail cours, Fiche, Sources fiche, Detail document, Subject detail.

Fichiers probablement concernes :

- models/repositories de sources et documents ;
- pages Course detail, Course sheet, Sources, Subject detail, Document detail ;
- helpers de label source ;
- tests affichage labels.

Non-objectifs :

- pas de pipeline IA de titrage avance si un mapping local suffit ;
- pas de migration de donnees obligatoire ;
- pas de suppression de filename en debug/admin.

Critères d'acceptation :

- aucun filename brut visible dans les captures critiques ;
- un libelle humain existe meme sans metadata enrichie ;
- la source originale reste retrouvable en secondaire ;
- les notions ne ressemblent plus a des extractions techniques.

Preuves visuelles obligatoires :

- before/after `12-dark-course-detail.png` ;
- before/after `14-dark-course-sheet-sources.png` ;
- before/after `34-dark-document-detail-chevron.png` ;
- capture d'une zone "Source originale" secondaire.

Tests obligatoires :

- tests helper de label ;
- widget tests sur absence du filename brut ;
- tests fallback si metadata manquante.

Risques :

- masquer trop d'information de provenance ;
- generer des titres trompeurs ;
- laisser des filenames dans une surface oubliee.

### V5-04 — Aujourd'hui coach

Phrase produit : Aujourd'hui devient le cockpit quotidien, meme quand les questions ne sont pas pretes.

Scope :

- mission du jour ;
- fallback `Lire la fiche` ;
- objectif semaine ;
- continuer un cours ;
- etats 0% honnetes ;
- progression lisible ;
- wording Luna leger et utile.

Fichiers probablement concernes :

- `lib/presentation/pages/today/today_page.dart`
- models/repository Today ;
- tests Today page.

Non-objectifs :

- pas de streak avance ;
- pas d'event log complet ;
- pas de gamification lourde ;
- pas de planner backend.

Critères d'acceptation :

- Today ne dit pas "rien de pret" si une fiche ou un cours exploitable existe ;
- l'utilisateur voit une prochaine action ;
- l'etat questions en preparation est clair ;
- la progression a 0% est presentee comme un depart, pas comme un echec.

Preuves visuelles obligatoires :

- capture Today empty actuel ;
- capture Today fiche prete/questions preparing ;
- capture Today session prete ;
- comparaison maquette ecran 2.

Tests obligatoires :

- widget tests empty/ready/preparing ;
- test CTA fallback ;
- test wording sans jargon.

Risques :

- inventer une recommandation non fondee ;
- rendre Today trop charge ;
- confondre objectif semaine et progression reelle.

### V5-05 — Detail cours parcours gamifie

Phrase produit : le detail cours ressemble a un parcours de progression, pas a une liste d'extractions.

Scope :

- checkpoints ;
- etats par notion ;
- micro-objectifs ;
- notion recommandee ;
- CTA contextuel ;
- progression circulaire ;
- libelles humains de source ;
- actions secondaires deplacees ou qualifiees.

Fichiers probablement concernes :

- `lib/features/courses/presentation/course_detail_page.dart`
- widgets learning path ;
- modeles `CourseLearningPath` ;
- tests detail cours.

Non-objectifs :

- pas de vraie economie de badges ;
- pas de backend progression avance si les states existants suffisent ;
- pas de nouvelle route de session.

Critères d'acceptation :

- la page montre un prochain checkpoint clair ;
- les notions ont des etats lisibles ;
- le CTA principal change selon fiche/questions/session ;
- les noms techniques sont absents.

Preuves visuelles obligatoires :

- before/after `12-dark-course-detail.png` ;
- capture checkpoint actif ;
- capture etat source/fiche/questions ;
- comparaison maquette ecran 4.

Tests obligatoires :

- widget tests path vide/path rempli ;
- tests CTA contextuel ;
- tests absence filename brut ;
- router tests actions.

Risques :

- surcharger l'ecran ;
- simuler une progression non mesuree ;
- rouvrir trop de surfaces legacy.

### V5-06 — Fiche premium actionnable

Phrase produit : la fiche devient un vrai objet pedagogique premium.

Scope :

- resume ;
- points cles ;
- definitions ;
- exemples ;
- pieges ;
- sources pliables ;
- CTA `Comprendre`, `Se tester`, `Question ouverte` selon fiabilite ;
- navigation interne ou sections compactes ;
- passages source cites et lisibles.

Fichiers probablement concernes :

- course sheet / revision sheet pages ;
- widgets fiche ;
- sources fiche ;
- tests fiche and sources.

Non-objectifs :

- pas de GenUI avance ;
- pas de generation de fiche multi-source complexe si les donnees ne l'assurent pas ;
- pas d'editeur de fiche.

Critères d'acceptation :

- la fiche ressemble a une page premium, pas a un dump ;
- les sources longues sont pliables ;
- les CTA sont visibles et honnetes ;
- la fiche reste utile quand les questions ne sont pas pretes.

Preuves visuelles obligatoires :

- before/after `13-dark-course-sheet.png` ;
- before/after `14-dark-course-sheet-sources.png` ;
- capture sections pedagogiques ;
- capture CTA fiche.

Tests obligatoires :

- widget tests sections ;
- tests sources collapsed/expanded ;
- tests CTA selon disponibilite ;
- tests overflow mobile.

Risques :

- faire une belle fiche mais trop longue ;
- cacher les sources ;
- confondre fiche et session.

### V5-07 — Choix duree aligne maquette

Phrase produit : le choix duree ressemble a la maquette et respecte l'etat reel des questions.

Scope :

- ecran ou sheet choix duree/perimetre ;
- etats disponibles/indisponibles ;
- durees 5/15/30 si elles restent le bon langage ;
- message questions en preparation ;
- CTA demarrer seulement si possible.

Fichiers probablement concernes :

- `quick_revision_question_count_sheet.dart` ou son futur renommage ;
- course quick launcher ;
- tests duration picker.

Non-objectifs :

- pas de planner temporel complet ;
- pas de nouvelle facade backend obligatoire ;
- pas de refonte session.

Critères d'acceptation :

- les options sont tactiles et proches de la maquette ;
- l'etat indisponible est explicite ;
- aucun `questionCount` visible ;
- le CTA ne lance pas une session impossible.

Preuves visuelles obligatoires :

- before/after choix duree ;
- capture option disabled/preparing ;
- comparaison maquette ecran 6.

Tests obligatoires :

- widget tests options ;
- tests disabled/preparing ;
- tests mapping interne non visible.

Risques :

- conserver un fichier nomme `question_count` trop longtemps ;
- promettre du temps reel alors que le moteur compte des questions.

### V5-08 — Session question alignee maquette

Phrase produit : la session question est claire, rapide, tactile et visuellement proche de la maquette.

Scope :

- top progress ;
- question unique ;
- reponses tactiles ;
- CTA `Valider` ;
- etats selection, loading, erreur ;
- sortie confirmee ;
- sans bottom nav.

Fichiers probablement concernes :

- `quick_revision_quiz_flow.dart`
- session pages ;
- tests revision session.

Non-objectifs :

- pas de multi-type complet ;
- pas de question ouverte dans la session si non fiable ;
- pas de feedback IA lourd.

Critères d'acceptation :

- une seule question domine l'ecran ;
- le CTA est atteignable sur mobile ;
- le texte ne deborde pas ;
- erreur reseau ou correction lente ne bloque pas sans message.

Preuves visuelles obligatoires :

- capture session question ;
- capture reponse selectionnee ;
- capture loading/erreur ;
- comparaison maquette ecran 7.

Tests obligatoires :

- widget tests selection/validation ;
- tests mobile sans nav ;
- tests overflow textes longs ;
- tests erreur submit.

Risques :

- perdre l'accessibilite avec des zones trop graphiques ;
- cacher une erreur backend ;
- rallonger la session.

### V5-09 — Feedback reponse

Phrase produit : apres une reponse, l'utilisateur comprend immediatement pourquoi c'est juste ou faux.

Scope :

- etat juste/faux ;
- explication courte ;
- source ou fiche liee ;
- action continuer ;
- ton coach ;
- feedback question ouverte structure si repris.

Fichiers probablement concernes :

- session flow ;
- result/correction widgets ;
- tests feedback.

Non-objectifs :

- pas de correction IA longue synchrone si elle bloque ;
- pas de refonte backend si les corrections existantes suffisent pour une premiere version ;
- pas de jugement culpabilisant.

Critères d'acceptation :

- l'utilisateur sait quoi retenir en moins de quelques secondes ;
- le feedback est court ;
- la source est accessible ;
- continuer est evident.

Preuves visuelles obligatoires :

- capture feedback juste ;
- capture feedback faux ;
- capture source/fiche liee ;
- comparaison maquette ecran 8.

Tests obligatoires :

- widget tests correct/incorrect/no explanation ;
- tests action continuer ;
- tests fallback si explication absente.

Risques :

- feedback trop long ;
- latence IA ;
- source non fiable ou absente.

### V5-10 — Bilan resultat

Phrase produit : le bilan donne une progression, une victoire et une prochaine action.

Scope :

- score secondaire ;
- progression lisible ;
- victoire ou encouragement ;
- notions a revoir ;
- prochaine action ;
- retour fiche/cours.

Fichiers probablement concernes :

- `revision_session_result_page.dart`
- result models/widgets ;
- tests result page.

Non-objectifs :

- pas de progression avancee non fiable ;
- pas de badges lourds ;
- pas de celebratory animation permanente.

Critères d'acceptation :

- le bilan est atteignable dans le flow ;
- il explique quoi faire ensuite ;
- il ne montre pas de fausses notions ;
- Luna reste discrete.

Preuves visuelles obligatoires :

- capture bilan avec erreurs ;
- capture bilan sans erreurs ;
- capture prochaine action ;
- comparaison maquette ecran 9.

Tests obligatoires :

- widget tests result variants ;
- router tests retour cours/fiche ;
- tests absence fake data.

Risques :

- score trop dominant ;
- progression inventee ;
- route fiche sans `courseId`.

### V5-11 — Progres maquette

Phrase produit : Progres devient motivant meme avec peu de donnees.

Scope :

- maitrise ;
- semaine ;
- cours ;
- notions solides/a renforcer/a decouvrir ;
- empty states motivants ;
- dark mode par defaut ou explicite.

Fichiers probablement concernes :

- pages Progress ;
- models progress ;
- tests progress.

Non-objectifs :

- pas d'analytics avancees ;
- pas de mastery event complet si non pret ;
- pas de leaderboard.

Critères d'acceptation :

- 0% est presente comme un debut ;
- la page donne une action ;
- les donnees fragiles sont qualifiees ;
- la maquette ecran 10 est reconnaissable.

Preuves visuelles obligatoires :

- before/after `15-dark-progress.png` ;
- capture low-data ;
- capture avec donnees ;
- comparaison maquette ecran 10.

Tests obligatoires :

- widget tests empty/low-data/data ;
- tests wording sans promesse excessive ;
- tests dark mode.

Risques :

- donner trop de metriques sans base ;
- frustrer l'utilisateur avec tout a zero ;
- melanger objectifs et realite.

### V5-12 — Onboarding emotionnel

Phrase produit : la premiere impression ressemble a Neralune, pas a un formulaire utilitaire.

Scope :

- welcome/login sombre ;
- promesse courte ;
- Neralune/Luna/chat ;
- separation login et setup matiere ;
- dark mode recommande ou par defaut ;
- setup guide apres login : matiere, objectif hebdo, import source.

Fichiers probablement concernes :

- sign-in page ;
- onboarding/setup routes ;
- auth tests ;
- profile/theme tests.

Non-objectifs :

- pas de refonte auth backend ;
- pas de mascot system complet ;
- pas de long tutoriel.

Critères d'acceptation :

- l'ecran initial porte la promesse produit ;
- login email/social reste accessible et elegant ;
- setup matiere n'est plus confondu avec onboarding marque ;
- mobile 390 x 844 ne deborde pas.

Preuves visuelles obligatoires :

- before/after `01-sign-in-initial.png` ;
- before/after `47-dark-onboarding-route.png` ;
- capture email form ;
- comparaison maquette ecran 1.

Tests obligatoires :

- widget tests sign-in initial/email ;
- tests route setup ;
- tests autofill/semantics si possible ;
- tests dark mode.

Risques :

- rendre l'auth plus belle mais moins accessible ;
- masquer l'email/password ;
- confondre onboarding emotionnel et setup obligatoire.

## 8. Ordre recommande

L'ordre strict V5 commence par les priorites suivantes :

1. CTA honnetes et etats de preparation — `V5-01`
2. spinners / pages legacy / impasses — `V5-02`
3. humanisation des sources et noms de PDF — `V5-03`
4. Today coach — `V5-04`
5. detail cours gamifie — `V5-05`
5 bis. fiche premium actionnable — `V5-06`
6. choix duree aligne maquette — `V5-07`
7. session question alignee maquette — `V5-08`
8. feedback reponse — `V5-09`
9. bilan resultat — `V5-10`
10. progres — `V5-11`
11. onboarding — `V5-12`

Note de priorisation : le brief impose que le point 6 soit le choix duree. La fiche premium est donc indiquee en `5 bis` pour conserver l'ordre demande tout en respectant la demande produit "vraiment avoir de belles fiches de revisions". Si un seul lot peut etre lance apres V5-05, choisir V5-06 avant V5-07 seulement si la fiche est devenue le fallback principal de V5-01.

## 9. Ce qui est explicitement reporte

- Study Session V4 complete.
- `V4-05B` et vraie facade `/study-sessions`.
- Sujet long.
- Epreuve blanche.
- GenUI avance.
- Mascot system complet.
- Backend IA complexe.
- Progression avancee non fiable.
- Gamification lourde : economie de points, boutique, badges avances, leaderboard.
- Refactor architectural massif.
- Suppression definitive des routes legacy sans audit dedie.

## 10. Definition de "maquette-aligned"

Un ecran est `maquette-aligned` quand :

- il existe une capture before, une capture after et une reference cible ;
- la structure principale correspond a l'ecran cible : hierarchy, navigation, CTA, densite, zones principales ;
- le dark mode est conforme a la direction produit ;
- le CTA principal est visible, atteignable et honnete ;
- aucun jargon technique ou filename brut n'apparait dans l'UI critique ;
- les etats loading, empty, error et preparing sont visuellement traites ;
- le texte ne deborde pas en viewport mobile 390 x 844 ;
- la bottom nav est coherente avec le flow ;
- Luna est presente seulement si elle aide l'ecran ;
- les ecarts restants sont listes et acceptes explicitement.

Un ecran n'est pas maquette-aligned si une capture manque, si le flow ne permet pas d'y acceder, ou si une difference majeure avec la maquette n'est pas documentee.

## 11. Definition de "ready for demo"

Une demo V5 est prete quand :

- le flow mobile dark peut etre montre de bout en bout ;
- aucun CTA principal ne casse silencieusement ;
- aucun spinner infini n'apparait dans le parcours montre ;
- les sources et notions ont des noms humains ;
- Aujourd'hui donne une prochaine action ;
- la fiche est belle et utile si la session n'est pas prete ;
- le choix duree, la session, le feedback et le bilan ont des captures after validees ;
- les pages legacy ne sont pas necessaires pour raconter la demo ;
- les tests obligatoires des lots du flow passent ou les exceptions sont documentees ;
- l'evidence pack de chaque lot contient captures, verdict visuel, ecarts restants et decision.

## 12. Risques

Risques produit :

- confondre "V4 montrable" avec "V5 convaincante" ;
- prioriser une feature brillante avant les P0 ;
- rendre la fiche belle mais pas actionnable ;
- promettre une revision alors que les questions ne sont pas pretes.

Risques UX :

- spinners persistants ;
- CTAs hors viewport ;
- pages parking visibles ;
- texte trop long dans feedback/correction ;
- Luna trop presente ou incoherente.

Risques backend/donnees :

- absence de signal fiable sur source prete/fiche prete/questions pretes ;
- filenames sans metadata humaine ;
- progression a 0% mal interpretee ;
- latence IA ou questions en preparation.

Risques tests visuels :

- captures non comparables faute de viewport fixe ;
- dark mode non force ;
- donnees de test differentes entre before et after ;
- Flutter Web canvas peu inspectable par DOM.

Risques execution :

- rouvrir Study Session V4 complete trop tot ;
- toucher backend/Prisma pour compenser un probleme d'UI ;
- creer de nouveaux lots sans preuves visuelles.

## 13. Prochaine action immediate

La prochaine action immediate est :

```text
V5-01 — CTA honnetes + etats de preparation
```

Ce lot doit rester petit. Il doit rendre visibles les etats reels et supprimer les promesses impossibles avant toute grosse feature.
