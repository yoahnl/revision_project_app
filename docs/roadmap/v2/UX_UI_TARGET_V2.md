# UX/UI Target V2

Ce document décrit la cible UX/UI future de Revision Project. Il ne remplace pas les rapports UI existants ; il sert de boussole pour les prochains lots.

## 0. Référence visuelle canonique

La planche UI V2 doit vivre à terme ici :

```text
docs/roadmap/v2/assets/revision_project_ui_v2_board.png
```

Statut actuel : asset manquant. La direction visuelle reste décrite par ce document et par les rapports UI existants, mais aucune image ne doit être inventée.

La planche, une fois ajoutée, définit palette, surfaces, gradients, densité, navigation, matière active, hiérarchie des CTA, bottom sheets, sessions immersives, résultats et progression. Elle n'autorise jamais l'ajout de chiffres, streaks, gems, cours ou scores fictifs.

## 1. Principes de navigation

- Une matière active à la fois.
- Un cours est le point d'entrée principal pour sources, fiche, révision et progression.
- Une session est immersive : pas de bottom nav pendant le quiz, la correction ou un exam futur.
- Une destination principale doit porter une action claire.
- Les sources doivent d'abord être accessibles depuis le cours. L'onglet Sources global doit être justifié par une vraie bibliothèque ou retiré de la navigation principale.
- Le retour arrière ne doit pas empiler de nouvelles pages.

## 2. Règles de wording

- Ne pas afficher `MVP+`, `backend`, `payload`, `fixture`, `courseId`, `documentId`, `KnowledgeUnit`.
- Préférer `Bientôt disponible`, `Mode verrouillé`, `Ajoute une source`, `Source en analyse`, `Notions prêtes`.
- Ne pas utiliser d'écriture inclusive avec points médians dans l'interface utilisateur.
- Ne pas inventer des scores, streaks, gemmes ou jours de série.
- Ne pas promettre `Reprendre` si la dernière activité réelle n'est pas connue.

## 3. Règles de modes disabled

- Un mode non disponible doit être masqué ou verrouillé.
- Un mode verrouillé doit expliquer la condition utilisateur : `Disponible après une source prête`, `Disponible après une première session`, ou `Prévu plus tard`.
- Ne pas afficher un bouton actif qui déclenche seulement un snackbar d'échec.

## 4. Règles de loading, empty et error

- Loading : bloquer les actions concurrentes qui cassent la navigation, surtout au démarrage d'une session.
- Empty : expliquer l'action suivante, pas l'architecture.
- Error : dire quoi faire maintenant, sans codes techniques sauf écran debug.
- Retry : présent seulement si l'action peut réellement être retentée.

## 5. Règles design system

- Unifier les surfaces premium et les écrans legacy.
- Centraliser couleurs, gradients, rayons, ombres et styles texte.
- Éviter les styles locaux copiés dans les pages.
- Les headers doivent rester en haut ; éviter les centrages verticaux qui créent de grands vides.
- Le scroll doit concerner le contenu utile, pas toute la page par défaut.

## 6. Écrans cibles

### 6.1 Sign in / onboarding

- Rôle utilisateur : entrer dans le produit et comprendre la promesse.
- Données réelles nécessaires : état auth.
- Action principale : se connecter.
- Actions secondaires : aide, confidentialité si disponible.
- États empty/loading/error : chargement auth, erreur connexion.
- Ce qui est interdit : promesses IA non livrées, jargon technique.
- Problèmes actuels : écran encore legacy par rapport au premium.
- Lot de correction associé : STAB-02.

### 6.2 Accueil matière active

- Rôle utilisateur : voir la matière active et continuer.
- Données réelles nécessaires : matières, cours, sources prêtes, éventuellement dernière activité réelle.
- Action principale : ouvrir le cours pertinent ou créer un cours.
- Actions secondaires : changer/créer une matière, créer un cours.
- États empty/loading/error : aucune matière, aucune course, erreur sujets/cours.
- Ce qui est interdit : faux streaks, faux gemmes, `Reprendre` mensonger.
- Problèmes actuels : logique de reprise encore naïve, cartes parfois ellipsées.
- Lot de correction associé : STAB-01.

### 6.3 Sélecteur matière

- Rôle utilisateur : changer de contexte.
- Données réelles nécessaires : liste des matières.
- Action principale : choisir une matière.
- Actions secondaires : créer une matière.
- États empty/loading/error : aucune matière, erreur chargement.
- Ce qui est interdit : bloquer la création dans un cul-de-sac.
- Problèmes actuels : sélection possible, création moins accessible selon contexte.
- Lot de correction associé : STAB-01.

### 6.4 Gestion matières

- Rôle utilisateur : créer, renommer, supprimer ou archiver une matière.
- Données réelles nécessaires : sujets et contraintes de suppression.
- Action principale : créer une matière.
- Actions secondaires : modifier, supprimer/archiver.
- États empty/loading/error : liste vide, conflit suppression.
- Ce qui est interdit : suppression destructive silencieuse.
- Problèmes actuels : page matières legacy.
- Lot de correction associé : STAB-02.

### 6.5 Création cours

- Rôle utilisateur : structurer une matière en cours.
- Données réelles nécessaires : matière active.
- Action principale : créer cours.
- Actions secondaires : durée, description, chapitre si utile.
- États empty/loading/error : erreur validation, matière absente.
- Ce qui est interdit : champs techniques.
- Problèmes actuels : acceptable mais à aligner premium.
- Lot de correction associé : STAB-02.

### 6.6 Détail cours

- Rôle utilisateur : piloter un cours.
- Données réelles nécessaires : course detail, sources, progress, fiche availability, quick availability.
- Action principale : lancer l'action la plus utile selon état.
- Actions secondaires : fiche, sources, modifier, supprimer.
- États empty/loading/error : cours introuvable, source absente, source processing, progression vide.
- Ce qui est interdit : boutons actifs qui échouent sans explication.
- Problèmes actuels : page chargée, plusieurs sections concurrentes.
- Lot de correction associé : STAB-01.

### 6.7 Sources du cours

- Rôle utilisateur : ajouter, voir, supprimer ou archiver les PDF du cours.
- Données réelles nécessaires : documents course-level et statuts.
- Action principale : ajouter une source.
- Actions secondaires : refresh, supprimer/archiver, voir erreur.
- États empty/loading/error : aucune source, processing, failed.
- Ce qui est interdit : supprimer une source utilisée sans garde.
- Problèmes actuels : lifecycle source à durcir.
- Lot de correction associé : CORE-09.

### 6.8 Ajout source

- Rôle utilisateur : importer un PDF.
- Données réelles nécessaires : picker PDF, endpoint upload, statut processing.
- Action principale : choisir PDF.
- Actions secondaires : annuler.
- États empty/loading/error : upload en cours, PDF invalide, quota/provider IA.
- Ce qui est interdit : laisser l'utilisateur croire que le cours est prêt avant processing.
- Problèmes actuels : erreurs IA/provider encore trop visibles indirectement.
- Lot de correction associé : CORE-09.

### 6.9 Fiche de cours

- Rôle utilisateur : lire une synthèse exploitable.
- Données réelles nécessaires : revision sheet, sources de fiche.
- Action principale : lire la fiche rapide ou générer si possible.
- Actions secondaires : consulter sources, revenir au cours.
- États empty/loading/error : aucune source prête, fiche absente, génération en échec.
- Ce qui est interdit : faux onglets avec contenu absent, énorme bloc source inline.
- Problèmes actuels : tabs `Complète`/`Examen` encore partiels, sources déplacées mais à stabiliser.
- Lot de correction associé : STAB-01, PLUS-02.

### 6.10 Hub Révisions

- Rôle utilisateur : choisir comment travailler.
- Données réelles nécessaires : cours prêts, session en cours, modes disponibles.
- Action principale : lancer quick ou reprendre session.
- Actions secondaires : ouvrir un cours prêt.
- États empty/loading/error : aucun cours prêt, génération en cours.
- Ce qui est interdit : page explicative sans action directe.
- Problèmes actuels : encore trop dépendant de l'ouverture d'un cours.
- Lot de correction associé : STAB-01.

### 6.11 Session quick

- Rôle utilisateur : répondre à des questions courtes.
- Données réelles nécessaires : session, questions snapshot, réponses partielles futures.
- Action principale : répondre puis continuer.
- Actions secondaires : signaler question, quitter avec confirmation.
- États empty/loading/error : préparation, question invalide, submit failure, completion retry.
- Ce qui est interdit : bottom nav, score local, correction pré-submit.
- Problèmes actuels : reprise/historique partiels.
- Lot de correction associé : CORE-11.

### 6.12 Résultat quick

- Rôle utilisateur : comprendre ce qui est réussi et ce qui manque.
- Données réelles nécessaires : backend result, corrections, knowledge units, score.
- Action principale : revenir au cours ou revoir correction.
- Actions secondaires : voir fiche, refaire une session.
- États empty/loading/error : résultat absent, session non terminée.
- Ce qui est interdit : score client, confetti sous 70%.
- Problèmes actuels : résultat fonctionnel mais à relier à l'historique.
- Lot de correction associé : CORE-11.

### 6.13 Progrès

- Rôle utilisateur : voir la maîtrise réelle.
- Données réelles nécessaires : subject progress, course progress, mastery.
- Action principale : ouvrir un cours à travailler.
- Actions secondaires : changer matière.
- États empty/loading/error : aucune matière, aucune notion, aucune session.
- Ce qui est interdit : confondre source prête et maîtrise.
- Problèmes actuels : visuel amélioré mais encore perfectible.
- Lot de correction associé : STAB-01.

### 6.14 Profil

- Rôle utilisateur : gérer compte, préférences, données.
- Données réelles nécessaires : étudiant, auth, paramètres.
- Action principale : voir/mettre à jour le compte.
- Actions secondaires : déconnexion, suppression compte future.
- États empty/loading/error : auth absente, erreur profil.
- Ce qui est interdit : afficher des badges/gemmes fictifs.
- Problèmes actuels : écran legacy.
- Lot de correction associé : STAB-02.

### 6.15 Future Deep session

- Rôle utilisateur : répondre longuement et recevoir une correction.
- Données réelles nécessaires : source/KU backend, open question, correction IA, mastery update.
- Action principale : rédiger une réponse.
- Actions secondaires : consulter aide après correction.
- États empty/loading/error : pas de source prête, correction en cours, correction échouée.
- Ce qui est interdit : réutiliser quick avec un simple nouveau titre.
- Problèmes actuels : mode non implémenté.
- Lot de correction associé : PLUS-01.

### 6.16 Future Exam session

- Rôle utilisateur : s'entraîner en conditions d'examen.
- Données réelles nécessaires : sources examen, questions, timer, résultat exam.
- Action principale : lancer et terminer un entraînement.
- Actions secondaires : revoir points faibles.
- États empty/loading/error : aucune source examen, temps écoulé, correction échouée.
- Ce qui est interdit : vendre un mode examen sans contrat distinct.
- Problèmes actuels : mode non implémenté.
- Lot de correction associé : PLUS-03.

## 7. Éléments reportés

- Gamification réelle.
- Coach Today.
- Deep revision.
- Exam mode.
- GenUI contrôlé.
- Bibliothèque globale Sources.

## 8. Matrice de capacités UX/API

Statuts autorisés :

- `AVAILABLE_NOW` : contrat backend et écran ou flow déjà disponibles.
- `NEEDS_API` : l'UX souhaitée nécessite un lot backend avant d'afficher l'action comme disponible.
- `FUTURE` : capacité hors MVP stable ou horizon ultérieur.

| Capacité | Statut | Lot associé | Règle UX |
| --- | --- | --- | --- |
| Créer une matière | AVAILABLE_NOW | STAB-01C | Doit être découvrable depuis le sélecteur matière. |
| Supprimer une matière | AVAILABLE_NOW | STAB-01C | Afficher les conflits réels, pas de suppression silencieuse. |
| Renommer une matière | NEEDS_API | CORE-09C | Ne pas afficher comme action active avant l'API. |
| Archiver une matière | NEEDS_API | CORE-09C | Ne pas simuler côté front. |
| Créer un cours | AVAILABLE_NOW | STAB-01B | Action principale si une matière existe. |
| Supprimer un cours vide | AVAILABLE_NOW | STAB-01B | Garder les erreurs 409 lisibles. |
| Renommer ou modifier un cours | NEEDS_API | CORE-09C | Ne pas créer de bouton actif sans endpoint. |
| Ajouter une source | AVAILABLE_NOW | CORE-09A | Disponible depuis le cours. |
| Supprimer une source inutilisée | AVAILABLE_NOW mais à durcir | CORE-09A | Le wording doit rester prudent jusqu'au lifecycle final. |
| Archiver une source utilisée | NEEDS_API | CORE-09A | Prioritaire avant les historiques avancés. |
| Révision rapide | AVAILABLE_NOW | CORE-10A, CORE-11A | Disponible si source prête et questions préparées. |
| Révision approfondie | FUTURE | PLUS-01A | Masquer ou verrouiller clairement. |
| Préparation examen | FUTURE | PLUS-03 | Masquer ou verrouiller clairement. |
| Fiche rapide | AVAILABLE_NOW | STAB-01C | Ne pas afficher de contenu fictif si absente. |
| Fiche complète | FUTURE | PLUS-02 | Onglet masqué ou verrouillé tant que non livré. |
| Fiche examen | FUTURE | PLUS-02 | Onglet masqué ou verrouillé tant que non livré. |

Un lot frontend ne doit pas créer un bouton utilisateur pour une capacité `NEEDS_API` sans lot backend correspondant.

Le renommage et l'archive de matière/cours sont reliés à `CORE-09C`.
