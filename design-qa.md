**Findings**
- No P0/P1/P2 findings remain.

**Evidence**
- Source visual truth path: `/var/folders/b5/7gsfwzyd449_54n8l40h40gc0000gn/T/codex-clipboard-5c8551ae-f283-414a-b7be-04514b7a8af1.png`
- Implementation screenshot path: `/Users/karim/Project/app-révision/revision_app/.superpowers/design-qa/course-detail-impl-310x500.png`
- Full-view comparison evidence: `/Users/karim/Project/app-révision/revision_app/.superpowers/design-qa/course-detail-comparison.png`
- Viewport: 310 x 500 mobile viewport, dark mode.
- State: course detail for `Droit constitutionnel`, 62% mastered, five path nodes, active node `Le contrôle de constitutionnalité`, bottom actions visible.
- Focused region comparison evidence: not needed; the full-view comparison is readable at native size and contains all critical elements: header, CTA, progress ring, timeline, active notion, and bottom action bar.

**Required Fidelity Surfaces**
- Fonts and typography: hierarchy now matches the mockup structure with compact title, small path labels, and CTA labels. Residual P3: Flutter web renders text slightly heavier than the source image, which appears closer to iOS/SF rendering.
- Spacing and layout rhythm: five timeline nodes are visible above the sticky bottom actions; active node card wraps the timeline marker; bottom action bar sits at the same visual band as the mockup.
- Colors and visual tokens: dark background, violet/blue CTA gradient, green completed nodes, muted future nodes, and purple active state match the provided palette.
- Image quality and asset fidelity: no app-specific raster asset is required on this screen; no placeholder image or fake illustration remains.
- Copy and content: visible labels match the mockup: `Continuer · 8 min`, `Parcours`, `Comprendre`, `Réviser cette notion`, and the five course notions.

**Patches Made Since Previous QA Pass**
- Replaced the old course detail layout with a mockup-first mobile layout.
- Removed the Luna/header card and visible legacy mode/history/source surfaces from the primary screen.
- Made the active timeline row include the marker, matching the mockup.
- Tightened typography, CTA sizing, timeline spacing, and bottom action proportions.
- Hid shell bottom navigation on `/courses/...` drill-in routes so the course detail action bar owns the bottom area.
- Updated router and course detail tests for the new mobile contract.

**Follow-up Polish**
- P3: If we want pixel-level typography parity, use an iOS/SF-like app font or tune Flutter text rendering further.
- P3: The source image includes a phone frame/status bar and bottom label; the implementation screenshot is the app viewport itself, so those decorative frame elements are intentionally absent.

**Implementation Checklist**
- Keep route behavior and menu actions wired.
- Keep the generated comparison artifacts for this QA pass.
- Re-run the mobile capture if design tokens or shell safe-area behavior change.

final result: passed
