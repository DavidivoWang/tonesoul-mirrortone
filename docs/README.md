# ToneSoul Documentation Gateway

> Purpose: guided documentation entrypoint for ToneSoul architecture, status surfaces, and continuity/governance reading order.
> Last Updated: 2026-04-19
> Status: curated docs gateway. Use this after `README.md` or `docs/foundation/README.md` when you still need help choosing the next lane.
> Not This: not the exhaustive registry. Use `docs/INDEX.md` only when you intentionally need broader inventory coverage.

---

## AI Reading Stack

| Lane | Files | Authority | Use When |
|------|-------|-----------|----------|
| **Operational Start** | `AI_QUICKSTART.md` | `operational` | first minute of a later agent session |
| **Working Reference** | `AI_REFERENCE.md` | `operational` | term lookup, routing, red-line checks during work |
| **Canonical Anchor** | see section below | `canonical` | before architecture or runtime claims |
| **Design Center** | `../DESIGN.md` | `design_center` | when you need the durable design rationale and non-drift invariants |
| **Whole-System Guide** | `architecture/TONESOUL_SYSTEM_OVERVIEW_AND_SUBSYSTEM_GUIDE.md` | `deep_map` | when you need one grounded explanation of the whole stack |
| **Deep Anatomy** | `narrative/TONESOUL_ANATOMY.md` | `deep_map` | before repo-wide refactor or whole-system explanation |
| **Interpretive Lane** | `notes/TONESOUL_DEEP_READING_ANCHOR_2026-03-26.md`, `narrative/TONESOUL_CODEX_READING.md` | `interpretive` | when the map is already clear but the load-bearing meaning still feels diffuse |
| **Code-Level Lookup** | `status/codebase_graph_latest.md` | `generated_truth` | when you need to know what a specific `tonesoul/...` module does, its layer, or its coupling |

Do not collapse these into one layer. Operational guides help an agent work; canonical anchors decide authority; deep and interpretive docs help explanation.

---

## First-Hop Route

### Human / developer
1. `../README.md`
2. `foundation/README.md`
3. this file (`docs/README.md`)
4. one chosen lane only

### AI agent
1. `AI_QUICKSTART.md`
2. `python scripts/start_agent_session.py --agent <your-id>`
3. `../AI_ONBOARDING.md`
4. `foundation/README.md`
5. `../task.md`
6. only then widen into deeper contracts or code

### Design / whole-system reasoning
1. `../DESIGN.md`
2. `architecture/TONESOUL_SYSTEM_OVERVIEW_AND_SUBSYSTEM_GUIDE.md`
3. canonical contracts relevant to the current question

---

## Canonical Architecture Anchor

Start here when making system-level claims:

1. `architecture/TONESOUL_EXTERNALIZED_COGNITIVE_ARCHITECTURE.md`
2. `notes/TONESOUL_ARCHITECTURE_MEMORY_ANCHOR_2026-03-22.md`
3. `notes/TONESOUL_RUNTIME_ADAPTER_MEMORY_ANCHOR_2026-03-23.md`
4. `architecture/KNOWLEDGE_SURFACES_BOUNDARY_MAP.md`
5. `architecture/TONESOUL_EIGHT_LAYER_CONVERGENCE_MAP.md`
6. `notes/TONESOUL_RUNTIME_REVIEW_LOGIC_ANCHOR_2026-03-26.md`
7. `architecture/TONESOUL_MULTI_AGENT_SEMANTIC_FIELD_CONTRACT.md`
8. `architecture/TONESOUL_SHARED_R_MEMORY_OPERATIONS_CONTRACT.md`
9. `architecture/TONESOUL_RUNTIME_COMPACTION_AND_GAMIFICATION_CONTRACT.md`

---

## Routing By Question

### “What does `tonesoul/<x>.py` do?”
- Go to: `status/codebase_graph_latest.md`
- Do not use: `CORE_MODULES.md` as a file-level lookup table

### “What are the legitimate import directions between layers?”
- Go to: `ARCHITECTURE_BOUNDARIES.md`

### “What is this repo about at the design level?”
- Go to: `../DESIGN.md`
- Then: `architecture/TONESOUL_EXTERNALIZED_COGNITIVE_ARCHITECTURE.md`

### “What should an AI read first before touching anything?”
- Go to: `AI_QUICKSTART.md`
- Then: `python scripts/start_agent_session.py --agent <your-id>`
- Then: `../AI_ONBOARDING.md`

### “I still cannot tell which doc lane is right.”
- Stay here in `docs/README.md`
- Use `docs/INDEX.md` only if guided routing is still insufficient

---

## High-Value Clusters

### Governance / safety
- `architecture/TONESOUL_ABC_FIREWALL_DOCTRINE.md`
- `architecture/TONESOUL_OBSERVABLE_SHELL_OPACITY_CONTRACT.md`
- `7D_AUDIT_FRAMEWORK.md`
- `7D_EXECUTION_SPEC.md`

### Control plane / readiness
- `architecture/TONESOUL_TASK_TRACK_AND_READINESS_CONTRACT.md`
- `architecture/TONESOUL_PLAN_DELTA_CONTRACT.md`
- `architecture/TONESOUL_MIRROR_RUPTURE_FAIL_STOP_AND_LOW_DRIFT_ANCHOR_CONTRACT.md`

### Continuity / handoff
- `architecture/TONESOUL_SHARED_R_MEMORY_OPERATIONS_CONTRACT.md`
- `architecture/TONESOUL_CONTINUITY_IMPORT_AND_DECAY_CONTRACT.md`
- `architecture/TONESOUL_RECEIVER_INTERPRETATION_BOUNDARY_CONTRACT.md`
- `architecture/TONESOUL_CONTINUITY_SURFACE_LIFECYCLE_MAP.md`
- `architecture/TONESOUL_CONTEXT_CONTINUITY_ADOPTION_MAP.md`

### Council / deliberation
- `architecture/TONESOUL_COUNCIL_DOSSIER_AND_DISSENT_CONTRACT.md`
- `architecture/TONESOUL_ADAPTIVE_DELIBERATION_MODE_CONTRACT.md`
- `architecture/TONESOUL_COUNCIL_REALISM_AND_INDEPENDENCE_CONTRACT.md`
- `architecture/TONESOUL_COUNCIL_CONFIDENCE_AND_CALIBRATION_MAP.md`

### Evidence / overclaim boundary
- `architecture/TONESOUL_CLAIM_TO_EVIDENCE_MATRIX.md`
- `architecture/TONESOUL_EVIDENCE_LADDER_AND_VERIFIABILITY_CONTRACT.md`
- `architecture/TONESOUL_TEST_AND_VALIDATION_TOPOLOGY_MAP.md`
- `status/claim_authority_latest.json`

### Documentation governance
- `architecture/DOC_AUTHORITY_STRUCTURE_MAP.md`
- `architecture/BASENAME_DIVERGENCE_DISTILLATION_MAP.md`
- `status/doc_authority_structure_latest.json`
- `status/doc_convergence_inventory_latest.json`

---

## Reality And Reading Discipline

Do not:
- treat all docs as equal authority
- treat narrative or interpretive surfaces as runtime truth
- treat status mirrors as replacements for code or canonical contracts
- widen public claims beyond the evidence ladder
- use `docs/INDEX.md` as the first hop when a guided lane is enough

Prefer:
- bounded entry before repo-wide guessing
- canonical architecture before narrative
- session-start bundle before deep theory
- design center before broad explanation
- generated code graph before hand-wavy file guessing

---

## Minimal Rule

If you are unsure where to start:
- start from `AI_QUICKSTART.md` if you are an agent
- start from `foundation/README.md` if you need the thin project packet
- start from `../README.md` if you are a human evaluator
- start from `docs/INDEX.md` only when you intentionally need exhaustive coverage
