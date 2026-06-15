# Runbook — Seed démo Revision App

## 1. Objectif

Ce runbook explique comment préparer une base locale ou de démonstration avec un scénario reproductible pour Revision App.

Le seed permet de tester :

* une matière réaliste ;
* un document logique `READY` ;
* des chunks sourcés ;
* des notions extraites ;
* un objectif de révision actif ;
* des mastery states variés ;
* un résumé et une fiche prêts ;
* un TodayPlan multi-actions exploitable.

## 2. Ce que le seed crée

Le seed crée un scénario synthétique autour de :

```text
Droit constitutionnel — Ve République
```

Il crée :

* un `StudentProfile` lié au Firebase UID fourni ;
* une matière de démo ;
* un document logique `READY` ;
* six chunks courts et synthétiques ;
* six notions sourcées ;
* un objectif de révision à `now + 30 jours` ;
* quatre mastery states réalistes ;
* un résumé `READY` ;
* une fiche `READY`.

## 3. Ce que le seed ne fait pas

Le seed ne fait pas :

* création de compte Firebase ;
* bypass Firebase Auth ;
* upload réel de PDF ;
* lecture de fichier PDF ;
* appel Genkit ;
* appel provider IA ;
* lancement worker PDF ;
* lancement BullMQ ;
* création de QCM ;
* création de question ouverte ;
* création de session de révision.

## 4. Prérequis

* Avoir une base PostgreSQL locale ou de démonstration prévue pour cet usage.
* Avoir appliqué les migrations avant d’exécuter le seed.
* Avoir un compte Firebase de démonstration existant.
* Récupérer l’UID Firebase de ce compte.

Ne jamais utiliser ce seed sur production.

## 5. Firebase UID de démo

Le seed ne crée pas de compte Firebase.

L’utilisateur devra se connecter dans l’app avec un compte Firebase dont l’UID correspond à la variable fournie au seed.

Ne jamais commiter un UID Firebase réel dans Git.

## 6. Variables d’environnement

Variables obligatoires :

```bash
DEMO_SEED_CONFIRM=revision-demo
DEMO_FIREBASE_UID=<firebase uid du compte demo>
```

Alias accepté :

```bash
DEMO_STUDENT_FIREBASE_UID=<firebase uid du compte demo>
```

Variables optionnelles :

```bash
DEMO_STUDENT_EMAIL=demo-revision@example.test
DEMO_STUDENT_DISPLAY_NAME="Demo Revision"
DEMO_SEED_DRY_RUN=1
```

## 7. Dry-run

Depuis `api` :

```bash
DEMO_SEED_CONFIRM=revision-demo DEMO_FIREBASE_UID=demo-local-uid npm run demo:seed -- --dry-run
```

Le dry-run :

* valide les garde-fous ;
* construit les fixtures ;
* affiche les IDs prévus ;
* masque l’URL DB et l’UID ;
* n’écrit rien en base.

## 8. Seed réel

Depuis `api`, uniquement sur une DB locale ou une DB de démonstration explicitement prévue :

```bash
DEMO_SEED_CONFIRM=revision-demo \
DEMO_FIREBASE_UID=<firebase uid du compte demo> \
DEMO_STUDENT_EMAIL=demo-revision@example.test \
DEMO_STUDENT_DISPLAY_NAME="Demo Revision" \
npm run demo:seed
```

Si `DATABASE_URL` est absent en environnement local, le backend utilise son fallback local documenté :

```text
postgresql://revision:revision@localhost:5432/revision?schema=public
```

## 9. Vérifier dans l’app

1. Se connecter avec le compte Firebase correspondant à l’UID seedé.
2. Ouvrir `Tes matières`.
3. Vérifier la matière `Droit constitutionnel — Ve République`.
4. Ouvrir le document de démo.
5. Vérifier les notions, le résumé et la fiche.
6. Ouvrir `Aujourd’hui`.
7. Vérifier que plusieurs actions sont proposées.

## 10. Vérifier via API

Avec un token Firebase valide du compte de démo :

```bash
curl -H "Authorization: Bearer <firebase id token>" http://localhost:8080/today
```

Le plan doit contenir des actions `diagnostic_quiz`, `open_question` et `revision_session` si les données sont intactes.

## 11. Relancer le seed

Le seed est idempotent.

Il peut être relancé avec les mêmes variables. Les données de démo connues sont mises à jour sans créer de doublons.

## 12. Nettoyage

Le script ne propose pas de commande globale de nettoyage.

Il ne supprime pas les données utilisateur hors namespace démo. Les seules suppressions automatiques concernent des liens ou sections identifiés par des IDs `demo-*` pendant la remise en place des fixtures.

Pour nettoyer manuellement, cibler uniquement les IDs `demo-*` listés dans la sortie dry-run.

## 13. Limites connues

* Le document est logique : aucun PDF physique n’est stocké.
* Les chunks sont synthétiques.
* Les QCM et questions ouvertes ne sont pas seedés.
* Le seed réel n’a pas vocation à tourner en production.

## 14. Troubleshooting

### `DEMO_SEED_CONFIRM=revision-demo is required`

Ajouter la variable de confirmation explicite.

### `DEMO_FIREBASE_UID or DEMO_STUDENT_FIREBASE_UID is required`

Fournir l’UID Firebase du compte de démo.

### `Demo seed is not allowed with NODE_ENV=production`

Ne pas exécuter ce seed en production.

### `Demo namespace already belongs to another student profile`

Le namespace `demo-*` existe déjà pour un autre `StudentProfile`. Utiliser le même UID de démo ou nettoyer explicitement les données de démo concernées sur une base non production.
