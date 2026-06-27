# Visual QA Protocol V5

## 1. Objectif

Ce protocole definit comment verifier visuellement chaque lot V5 de Neralune.

La regle est volontairement stricte :

```text
Aucun lot n'est termine sans preuve visuelle.
```

Chaque lot doit montrer :

- l'etat avant ;
- l'etat apres ;
- la reference cible ;
- le verdict visuel ;
- les ecarts restants ;
- les tests executes ;
- la decision finale : `valide`, `a reprendre` ou `bloque`.

## 2. Routes critiques

Routes ou ecrans a capturer pendant V5 :

- onboarding/login ;
- Aujourd'hui ;
- Cours ;
- detail cours ;
- selecteur matiere ;
- choix duree ;
- session question ;
- feedback reponse ;
- bilan ;
- progres ;
- fiche ;
- sources fiche ;
- profil secondaire ;
- surfaces legacy a risque : Activites, Reviser, Sources globales, QCM.

Les noms exacts des routes peuvent evoluer. Le protocole verifie l'ecran utilisateur visible, pas seulement le path technique.

## 3. Viewports

Viewport obligatoire :

- mobile `390 x 844` ;
- dark mode force ;
- device scale factor stable si possible ;
- screenshots PNG conserves avec noms explicites.

Viewport optionnel plus tard :

- desktop ou tablet seulement quand le lot touche explicitement un layout large.

La V5 se concentre sur mobile. Un lot mobile ne doit pas etre valide uniquement par une capture desktop.

## 4. Captures obligatoires par lot

Pour chaque lot UI :

- `before` : capture de l'ecran actuel ou de l'audit existant ;
- `after` : capture apres implementation ;
- `target reference` : image ou extrait de la maquette cible ;
- `notes d'ecart` : liste courte des differences acceptees ou a reprendre.

Convention de nommage recommandee :

```text
output/visual-qa/v5/<LOT_ID>/<NN>-<screen>-before.png
output/visual-qa/v5/<LOT_ID>/<NN>-<screen>-after.png
output/visual-qa/v5/<LOT_ID>/<NN>-<screen>-target.png
output/visual-qa/v5/<LOT_ID>/notes.md
```

Si la target ne peut pas etre copiee dans le repo, l'evidence pack doit pointer vers la reference disponible et decrire l'ecran cible.

## 5. Critères visuels

Un ecran V5 est acceptable si :

- la hierarchie est claire ;
- le CTA principal est evident ;
- le CTA principal est honnete ;
- aucun jargon technique n'est visible ;
- aucun filename brut ne pollue le parcours principal ;
- aucun texte ne deborde ;
- aucune page parking n'apparait sans action utile ;
- aucun spinner infini n'est possible ;
- la bottom nav est coherente avec le flow ;
- Luna est non envahissante ;
- les etats loading, empty, error, preparing et ready sont traites ;
- l'ecran reste lisible en mobile 390 x 844 dark mode.

## 6. Methode Playwright recommandee

Un runner de capture dark mode existe :

```text
output/product-audit/neralune-full-app-2026-06-27/mobile_dark_audit_runner.mjs
```

Commande recommandee depuis le repo Flutter :

```bash
NERALUNE_EMAIL='...' NERALUNE_PASSWORD='...' \
  npx -y -p playwright node output/product-audit/neralune-full-app-2026-06-27/mobile_dark_audit_runner.mjs
```

Objectifs du runner :

- forcer dark mode ;
- capturer les routes critiques ;
- signaler les reponses reseau 4xx/5xx ;
- produire des screenshots comparables ;
- documenter les blocages de navigation.

Pour un lot V5, le runner peut etre reutilise tel quel ou duplique dans un dossier `output/visual-qa/v5/<LOT_ID>/` si le lot demande des captures ciblees.

## 7. Format evidence pack visuel

Chaque evidence pack V5 doit contenir au minimum :

```markdown
# <LOT_ID> — <Titre> — Evidence Pack

## 1. Objectif

## 2. Scope reel

## 3. Fichiers modifies

## 4. Captures avant

## 5. Captures apres

## 6. Reference maquette

## 7. Verdict visuel

## 8. Ecarts restants

## 9. Tests executes

## 10. Resultats des tests

## 11. Non-objectifs respectes

## 12. Risques

## 13. Decision finale

## 14. Autocritique
```

Le verdict visuel doit utiliser une des valeurs suivantes :

- `VALIDATED`
- `NEEDS_BIS`
- `BLOCKED`

## 8. Checklist avant validation

Avant de marquer un lot `DONE` :

- les captures before existent ;
- les captures after existent ;
- la reference maquette est liee ou decrite ;
- le viewport mobile 390 x 844 est utilise ;
- le dark mode est actif ;
- les etats loading/empty/error sont testes si l'ecran en depend ;
- les CTA principaux sont cliquables ou explicitement disabled ;
- les erreurs reseau visibles sont traitees ;
- les tests obligatoires du lot sont executes ;
- `git diff --check` passe ;
- `git status --short` est rapporte ;
- les ecarts restants sont listes ;
- la decision finale est explicite.

## 9. Cas de rejet automatique

Un lot V5 est rejete automatiquement si :

- une capture obligatoire manque ;
- l'ecran n'est pas accessible ;
- le CTA principal est casse ;
- un CTA principal echoue silencieusement ;
- un spinner peut rester infini ;
- un texte technique est visible dans l'UI critique ;
- un filename brut est visible dans l'UI critique ;
- une difference majeure avec la maquette n'est pas documentee ;
- le dark mode mobile n'a pas ete verifie ;
- l'evidence pack ne donne pas de verdict.

Dans ces cas, le statut doit etre `NEEDS_BIS` ou `BLOCKED`, pas `DONE`.
