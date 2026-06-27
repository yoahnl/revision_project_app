# MVP Demo Runbook — Neralune V4

## 1. Objectif de la démo

Montrer Neralune comme un coach de révision guidé : l'utilisateur sait quoi travailler, ouvre un cours, choisit une durée courte, répond à une session immersive, lit un bilan clair et revient au cours sans voir les coutures techniques.

Phrase à garder en tête :

> Neralune transforme tes cours en un parcours de révision guidé.

## 2. Pré-requis

- L'application démarre sur l'onglet `Aujourd'hui`.
- La navigation principale contient uniquement `Aujourd'hui`, `Cours`, `Progrès`.
- Le profil reste une action secondaire.
- Au moins une matière existe.
- Au moins un cours prêt existe avec une source analysée.
- Le cours démo possède un learning path exploitable.
- Le moteur quick existant peut lancer une session courte.

## 3. Données nécessaires

Pour une démo fluide, préparer :

- une matière lisible, par exemple `Droits` ;
- un cours prêt, par exemple `Droit constitutionnel` ;
- plusieurs notions réelles dans le parcours ;
- au moins une question disponible pour la session courte ;
- un résultat avec corrections existantes pour afficher un bilan utile.

Ne pas inventer de données pendant la démo. Si une donnée manque, utiliser l'état honnête affiché par l'app.

## 4. Flow démo recommandé

1. Ouvrir `Aujourd'hui`.
2. Montrer l'action principale et la présence légère de Luna.
3. Aller dans `Cours`.
4. Ouvrir un cours existant depuis la liste.
5. Montrer le parcours de notions dans le détail cours.
6. Cliquer sur l'action de révision.
7. Choisir `5 min`, `15 min` ou `30 min`.
8. Lancer la session courte.
9. Répondre à une question à la fois.
10. Terminer la session.
11. Montrer le bilan : score, corrections utiles, prochaine étape.
12. Revenir au cours ou ouvrir la fiche.

## 5. Ce qu’il faut montrer

- La clarté de l'action du jour.
- La bibliothèque de cours compacte.
- Le parcours de notions réel du cours.
- Le choix simple de durée.
- La session immersive sans navigation principale.
- Le bilan propre avec corrections.
- Luna comme présence discrète, pas comme décoration partout.

## 6. Ce qu’il ne faut pas montrer

- Sujet long.
- Épreuve blanche.
- QCM complet si non stabilisé dans le flow démo.
- Question ouverte si non intégrée au flow démo.
- Progrès avancé.
- Gestion avancée de sources.
- Mascot system complet.
- Routes legacy.
- Détails backend ou noms de moteurs internes.

## 7. Wording produit à utiliser pendant la démo

Préférer :

- `session courte` ;
- `parcours de notions` ;
- `réviser maintenant` ;
- `choisir une durée` ;
- `corrections utiles` ;
- `prochaine étape` ;
- `retour au cours`.

Éviter :

- `questionCount` ;
- `backend` ;
- `legacy` ;
- `payload` ;
- `QCM complet` comme promesse principale ;
- noms de moteurs internes.

## 8. Limites connues

- La durée `5 / 15 / 30 min` reste mappée au moteur quick existant.
- Le feedback immédiat par question n'est pas encore le vrai contrat V4.
- Le bilan utilise les corrections déjà disponibles.
- La révision matière complète n'est pas encore une vraie façade backend.
- Luna reste volontairement légère.
- Les routes legacy existent encore pour compatibilité.

## 9. Checklist avant démo

- Lancer l'app et vérifier que `Aujourd'hui` s'ouvre en premier.
- Vérifier que `Aujourd'hui`, `Cours`, `Progrès` sont les seuls onglets principaux.
- Vérifier qu'un cours prêt est disponible.
- Vérifier que le parcours du cours affiche des notions réelles ou un état honnête.
- Vérifier que le choix `5 / 15 / 30 min` s'ouvre.
- Vérifier que la session n'affiche pas la bottom nav.
- Vérifier que le bilan affiche des corrections utiles.
- Vérifier que le retour au cours ou la fiche fonctionne.
- Ne pas naviguer vers les surfaces hors scope pendant la démo.

## 10. Définition de “démo prête”

La démo est prête quand le flow complet peut être montré sans expliquer de détail technique :

```text
Aujourd'hui → Cours → Détail cours → Durée → Session → Bilan → Retour cours / fiche
```

Elle est aussi prête quand aucun nouvel asset, backend, GenUI, Prisma ou nouveau mode de révision n'est requis pour raconter cette histoire.
