# Design QA — MVP Duolingo-like Flutter

final result: passed

## Source visual target

- `/Users/karim/Downloads/ChatGPT Image Jun 17, 2026, 12_19_27 AM (2).png`
- `/Users/karim/Downloads/ChatGPT Image Jun 17, 2026, 12_19_27 AM (1).png`
- `/Users/karim/Downloads/ChatGPT Image Jun 17, 2026, 12_06_07 AM.png`

## Scope checked

- Accueil matiere active.
- Subject switcher.
- Detail cours.
- Sources.
- Fiche de lecture.
- Hub revisions.
- Session de revision.
- Resultat de session.
- Progres.

## Design checks

- Palette moved to the reference direction: ink/navy background, glass surfaces, blue/cyan primary action, violet/pink secondary accents, green mastery.
- Bottom navigation now matches the target information architecture: Accueil, Progres, Revisions, Sources, Profil.
- Cards, mode rows, progress lines, mastery rings, source rows and CTA buttons are centralized in the MVP design-system components.
- The implementation avoids remote image loading and keeps icons from Flutter's Material icon set.
- Pages remain mobile-first with constrained width on larger screens.

## Known differences from reference

- This is an in-app Flutter implementation, not a pixel-perfect static clone.
- The first shipped slice uses front-only demo Course data while the backend Course/CourseSource model is still pending.
- Browser screenshot capture of the signed-in MVP state is not automated in this run because the real app keeps the existing auth guard.
- The status bar/device frame from the reference is not recreated inside the app; the app renders as a normal Flutter screen.

## Validation evidence

- `dart analyze lib test`: passed.
- `flutter test --reporter compact`: passed.
- `flutter build web --debug`: passed.
- `git diff --check`: passed.

## Follow-up design notes

- Replace the demo Course adapter with the real Course API.
- Add licensed/generated custom course icons only if the product needs stronger visual identity.
- Run device screenshots on an authenticated simulator once the backend Course flow is available.
