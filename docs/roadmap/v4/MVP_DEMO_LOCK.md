# MVP Demo Lock — Neralune V4

## 1. Pourquoi ce lock existe

La vision V4 de Neralune est bonne : l'app devient un coach de révision guidé, pas un catalogue de moteurs techniques. Mais le projet commence à se complexifier avec trop de contrats, trop de surfaces et trop de lots qui risquent chacun d'ouvrir trois nouveaux chantiers.

Ce lock existe pour arrêter la dispersion.

On ne construit pas toute la V1 maintenant. On construit le flow de démo le plus convaincant possible.

Le but n'est plus de multiplier les lots. Le but est de livrer un couloir de démo parfait, stable, compréhensible et montrable. Codex ne doit pas transformer Neralune en ERP pédagogique.

## 2. Phrase produit de la démo

Neralune transforme tes cours en un parcours de révision guidé : tu sais quoi travailler, tu réponds à quelques questions, tu reçois un feedback immédiat et tu vois ta progression.

## 3. Flow démo canonique

Le flow de démo canonique est le suivant :

1. L'utilisateur arrive sur Aujourd'hui.
2. Il voit une session recommandée.
3. Il ouvre un cours.
4. Il voit le parcours de notions du cours.
5. Il choisit une durée : 5 / 15 / 30 min.
6. Il lance une session courte.
7. Il répond à une question.
8. Il reçoit un feedback immédiat.
9. Il termine la session.
10. Il voit un bilan clair.

Ce flow est prioritaire sur toutes les autres idées. Aucun lot ne doit le casser. Aucun lot ne doit ajouter une nouvelle surface principale avant que ce flow soit stable.

## 4. Écrans inclus dans la démo

Les seuls écrans inclus dans la démo sont :

1. Aujourd'hui
2. Cours
3. Détail cours
4. Sélecteur matière
5. Choix durée
6. Session question
7. Feedback réponse
8. Bilan résultat

L'écran Progrès est autorisé seulement en version simple si l'existant est déjà proche. Il n'est pas prioritaire avant que la session et le bilan soient propres.

L'onboarding reste tel quel s'il est acceptable. Il ne doit pas être refait maintenant.

Le profil reste secondaire. Il ne doit pas devenir un chantier prioritaire avant la démo.

## 5. Écrans explicitement exclus avant la démo

Les surfaces suivantes sont exclues avant la démo :

- Sujet long
- Épreuve blanche
- Préparation examen complète
- Fiche complète multi-source
- Mode examen
- Bibliothèque globale des sources
- Page GenUI dédiée
- Historique complet
- Progrès avancé
- Mascot system complet
- Paramètres avancés
- Gestion avancée des matières

Règle : si une fonctionnalité n'aide pas directement le flow démo canonique, elle est reportée.

## 6. Les 5 prochains lots autorisés

Ces cinq lots forment le couloir autorisé avant la démo. Ils remplacent les ambitions larges de la roadmap tant que le MVP démo n'est pas terminé.

### DEMO-01 — Brancher le learning path dans le détail cours

Correspond à :

`V4-04B — Learning path frontend timeline`

Statut au moment du lock : déjà livré. Ce lot devient le premier jalon verrouillé du MVP démo.

Objectif utilisateur visible :

Le détail cours affiche de vraies notions et leurs états, sans timeline fake.

Non-objectifs :

- Pas de session V4.
- Pas de duration picker.
- Pas de refonte Cours.
- Pas de backend.

### DEMO-02 — Choix durée simple 5 / 15 / 30

Correspond à :

`V4-05A — Duration picker 5/15/30`

Objectif utilisateur visible :

L'utilisateur choisit combien de temps il veut réviser.

Règles :

- Pas de planner intelligent complet.
- Pas de nouvelle façade backend si évitable.
- Mapping simple vers le moteur existant autorisé.
- Pas de fake promesse.

### DEMO-03 — Session immersive quick-only

Correspond à une version réduite de :

`V4-05C — Study Session V4 frontend shell`

Objectif utilisateur visible :

La session affiche une seule question à la fois, sans dashboard.

Règles :

- Utiliser le moteur quick existant.
- Pas de nouveau backend sauf blocage réel.
- Masquer la bottom nav pendant la session si possible.
- Pas de QCM complet.
- Pas de question ouverte.
- Pas de mode examen.

### DEMO-04 — Feedback + bilan propre

Correspond à une version réduite de :

`V4-06B / V4-06C`

Objectif utilisateur visible :

Après une réponse, l'utilisateur comprend pourquoi il a bon ou faux, puis voit un bilan motivant.

Règles :

- Pas de feedback IA complexe si non nécessaire.
- Utiliser les corrections existantes.
- Score secondaire.
- Progression et prochaine action en priorité.

### DEMO-05 — Polish démo + Luna légère

Correspond à :

`V4-10A-lite / V4-11A-lite`

Objectif utilisateur visible :

Le flow démo est cohérent, joli, stable, et Luna apparaît aux bons endroits.

Règles :

- Pas de mascot system complet.
- Pas de nouvel asset.
- Pas d'animation infinie.
- Polish wording.
- Petites corrections responsive.
- Tests essentiels.

## 7. Règles anti-scope creep

Aucun nouveau mode de révision avant la démo.

Aucune nouvelle page principale avant la démo.

Aucun nouveau modèle Prisma avant la démo sauf blocage critique.

Aucun nouveau provider IA avant la démo.

Aucun refactor architectural massif.

Aucun sujet long.

Aucune épreuve blanche.

Aucune gamification avancée.

Aucun système complet de streak.

Aucun dashboard de métriques.

Règle forte : si un lot nécessite plus de 8 fichiers de code modifiés, il doit expliquer pourquoi et proposer un découpage plus petit.

## 8. Règles Codex pour les prochains prompts

Chaque prochain prompt doit contenir :

- Objectif utilisateur visible
- Périmètre strict
- Non-objectifs
- Fichiers autorisés
- Tests attendus
- Evidence pack
- Rapport final complet

Chaque prompt doit éviter :

- Grandes refontes abstraites
- Nouveaux concepts métier non validés
- Backends "au cas où"
- Widgets génériques non utilisés

Codex ne doit pas inventer une architecture plus large que le besoin du lot.

## 9. Critères de blocage immédiat

Un lot doit être stoppé ou marqué `NEEDS_BIS` si :

- il modifie le backend alors que le lot est frontend-only ;
- il ajoute une migration Prisma sans demande explicite ;
- il ajoute un nouveau mode de révision ;
- il réintroduit des données fake ;
- il affiche du jargon technique dans l'UI ;
- il casse la navigation trois onglets ;
- il remet Profil/Sources/Réviser en onglet principal ;
- il ajoute une nouvelle dépendance sans justification ;
- il rend Luna envahissante ;
- il crée un bouton mort ;
- il remplace une vraie donnée par un placeholder.

## 10. Définition de “démo terminée”

La démo est terminée si :

- Aujourd'hui affiche une recommandation claire.
- Cours affiche une bibliothèque compacte.
- Détail cours affiche un vrai parcours.
- L'utilisateur peut choisir 5 / 15 / 30.
- L'utilisateur peut lancer une session courte.
- La session est immersive.
- Le feedback est compréhensible.
- Le bilan donne envie de continuer.
- Aucune donnée fake visible.
- Le flow marche sur mobile.
- Les tests critiques passent.

## 11. Ce qu’on fera après la démo

Après la démo, on pourra rouvrir les chantiers suivants :

- Sujet long
- Épreuve blanche
- QCM complet dans le flow V4
- Question ouverte dans le flow V4
- Progrès avancé
- Répétition espacée
- Historique complet
- Bibliothèque globale des sources
- Gestion avancée des matières
- Mascot system complet
- Hardening production

## 12. Résumé final

Jusqu'à la démo, Neralune ne cherche pas à tout faire. Neralune doit prouver une chose : ouvrir l'app, savoir quoi réviser, réviser vite, comprendre son erreur, voir son progrès.
