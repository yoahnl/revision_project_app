# Design QA - V5-04 Aujourd'hui coach

source visual truth path: `docs/roadmap/v5/evidence/screenshots/V5-04/target/mockup-reference.png`

implementation screenshot path: `docs/roadmap/v5/evidence/screenshots/V5-04/after/today-coach-fallback-sheet-ready.png`

additional implementation states:

- `docs/roadmap/v5/evidence/screenshots/V5-04/after/today-coach-questions-preparing.png`
- `docs/roadmap/v5/evidence/screenshots/V5-04/after/today-coach-no-course.png`
- `docs/roadmap/v5/evidence/screenshots/V5-04/after/today-coach-error-or-loading.png`

viewport: `390 x 844`

state: mobile dark, Today empty plan fallback, fiche/course/no-course/error states.

full-view comparison evidence:

| Source | Implementation |
|---|---|
| `docs/roadmap/v5/evidence/screenshots/V5-04/target/mockup-reference.png` | `docs/roadmap/v5/evidence/screenshots/V5-04/after/today-coach-fallback-sheet-ready.png` |

focused region comparison evidence:

- Primary mission card inspected against the target Today card: title hierarchy, purple surface, white primary CTA, violet secondary CTA, and bottom support cards are readable at full viewport.
- No separate crop was needed because the implementation screenshots are single-screen mobile captures and the relevant text/CTA regions are legible in full view.

**Findings**
- No actionable P0/P1/P2 findings remain for V5-04.

**Open Questions**
- `Bonsoir, Lea` and exact profile personalization remain future data work; current implementation keeps the existing app greeting.
- The mascot is the existing Neralune asset treatment, not a newly generated exact replica of the board illustration.
- Live authenticated capture is blocked because `NERALUNE_EMAIL` and `NERALUNE_PASSWORD` are absent and `http://localhost:60164/` is unavailable.

**Implementation Checklist**
- Replace the poor Today empty state with an honest coach fallback. Done.
- Show `Lire la fiche` when a course has a ready source and no Today session. Done.
- Show `Voir le cours` when a course exists but no fiche/session is ready. Done.
- Show `Ouvrir les cours` when no course is available. Done.
- Add error/retry state for course loading failures. Done.
- Verify router destinations with tests. Done.

**Follow-up Polish**
- P3: connect profile display name when the account model is ready.
- P3: make the mascot illustration match the mockup board more closely in a later visual polish pass.

patches made since previous QA pass:

- Expanded the status pill layout so `Questions en preparation` no longer truncates on 390px mobile.
- Regenerated V5-04 after screenshots with the visible Luna asset.

final result: passed
