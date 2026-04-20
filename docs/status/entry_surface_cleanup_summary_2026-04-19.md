# Entry Surface Cleanup Summary (2026-04-19)

> Purpose: short reviewable summary of what the current cleanup wave changed across ToneSoul's first-hop entry surfaces.
> Last Updated: 2026-04-20
> Status: review snapshot for the current landing-layer cleanup wave and its bounded follow-on cleanup.

---

## What This Reviewable Wave Focused On

This wave did **not** try to rewrite ToneSoul's core center.
It focused on making the repo easier to enter, route, continue, and inspect.

The original reviewable landing-layer set in this pass was:

- `docs/AI_QUICKSTART.md`
- `AI_ONBOARDING.md`
- `docs/foundation/README.md`
- `docs/README.md`
- `docs/plans/tonesoul_collaboration_boundary_and_success_criteria_2026-04-19.md`
- `docs/status/entry_surface_cleanup_summary_2026-04-19.md`

## Deliberate Scope Boundary

`README.md` and `README.zh-TW.md` are **not** part of this reviewable docs-alignment set.
Those root entry surfaces still contain mirror-repo-specific install-source edits and should stay on a separate line until any later manual port is reviewed on its own merits.

## What Was Fixed In The Reviewable Pass

### 1. First-Hop Route Was Aligned

The AI first-hop route now reads consistently across the main reviewable entry surfaces:

1. `docs/AI_QUICKSTART.md`
2. `python scripts/start_agent_session.py --agent <your-id>`
3. `AI_ONBOARDING.md`
4. `docs/foundation/README.md`
5. `task.md`

This reduces the risk that later agents widen into architecture or repo-wide reading too early.

### 2. Docs Gateway Was Repaired

`docs/README.md` was cleaned up and re-established as a **guided docs gateway**.
It now clearly differs from `docs/INDEX.md`, which remains the **full registry**.

### 3. Foundation vs. Task Ownership Was Clarified

`docs/foundation/README.md` now clearly acts as the **thin project packet**.
`task.md` remains the **owner of the live short board / accepted current program**.

This prevents the foundation packet from silently becoming a second task board.

### 4. Reviewable Scope Was Made Honest

The current landing-layer reviewable set is now explicit about what it includes and what it excludes.
That means reviewers can inspect the docs-alignment pass without accidentally treating the mirror-specific root README edits as canonical-ready cleanup.

### 5. Current Collaboration Scope Was Made Explicit

A bounded collaboration note was added:

- `docs/plans/tonesoul_collaboration_boundary_and_success_criteria_2026-04-19.md`

It defines this wave as a repo/docs/onboarding/workflow cleanup effort rather than a rewrite of ToneSoul's core worldview.

## What Landed In The Follow-On Cleanup

After the original reviewable pass, one bounded follow-on cleanup was completed on the landing layer:

### 6. `docs/INDEX.md` Was Cleaned And Deconfused

`docs/INDEX.md` was first repaired as an honest inventory surface and then split so that older mixed-encoding raw registry residue no longer lives inside the maintained main index.

Current state:

- `docs/INDEX.md` = clean maintained full registry / routing index
- `docs/LEGACY_RAW_REGISTRY.md` = preserved historical raw residue only

This reduces the risk that later agents treat old mixed-encoding registry blocks as live authority or first-hop routing.

## What This Wave Did Not Do

This wave did **not**:

- rewrite ToneSoul's epistemic center
- replace its identity vocabulary
- upgrade interpretive prose into canonical runtime truth
- widen maturity claims beyond the evidence ladder
- silently treat mirror-specific root README edits as part of the reviewable docs-only pass
- claim that the whole repo is now converged or finished

## Current Result

The repo's landing layer is now more legible in five ways:

- easier to enter
- easier to continue across later agents
- easier to inspect for authority and routing order
- easier to browse without mistaking raw residue for maintained entry surfaces
- easier to selectively learn from without bulk-reading the whole repository

## What Still Remains After This Wave

This cleanup wave does **not** mean the whole repo is finished.
It means the entry and routing layer is substantially more coherent, and the main index is now clean enough to stop misleading first-hop readers.

Remaining work is now narrower and is still likely to include:

- final owner/reviewer reading of emphasis and wording
- any separate handling of root `README.md` / `README.zh-TW.md` if a canonical-safe manual port is ever wanted
- deeper repo-wide docs convergence work outside the landing layer

## Compressed Verdict

This wave should be read as a landing-layer cleanup and alignment pass, plus one bounded index deconfusion follow-on cleanup.
It is not a philosophical rewrite, not a full-repo completion claim, and not approval to bulk-merge mirror-specific root README edits into canonical surfaces.
