# Implementation governance

Date: 2026-11-06. Operational governance for the locked Aedify v1 plan. This directory does not change product scope or milestone sequencing.

## Source index

1. [Agent rules](../../AGENTS.md), [engineering rules](../../rules.md), [mobile design](../../DESIGN.md).
2. [Locked PRD](../../references/PRD-Aedify-v1-FINAL-relocked.md).
3. [Architecture](../../references/aedify-v1-architecture-implementation-plan-v1.0.md), [roadmap v1.3](../../references/aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md), [package decisions](../../references/aedify-package-validation-decision-log-v1.md).
4. [AI instructions](../../references/aedify-ai-companion-instruction-set-v1.10.md), [AI plan](../../references/aedify-v1-ai-implementation-plan-v1.0/00-ai-implementation-plan-index-v1.0.md).
5. [Build backlog](../../references/aedify-v1-build-ticket-backlog-v1.0/00-build-ticket-backlog-index-v1.0.md), [canonical ticket index](../../references/aedify-v1-build-ticket-backlog-v1.0/18-backlog-traceability-matrix-v1.0.md).
6. [Data plan](../../references/aedify-v1-data-model-implementation-plan-v1.0/00-data-model-plan-index-v1.0.md), [feature plan](../../references/aedify-v1-feature-by-feature-build-plan-v1.0/00-feature-build-plan-index-v1.0.md), [test plan](../../references/aedify-v1-testing-acceptance-plan-v1.0/00-testing-acceptance-plan-index-v1.0.md).
7. [Requirement traceability](requirements-traceability.md), [current status](../implementation.md), [change history](../changelog.md), [remaining-gap closure](../m0-m6-gap-closure.md).

## Ready and done

The [locked Definition of Ready/Done](../../references/aedify-v1-build-ticket-backlog-v1.0/01-ticket-governance-and-template-v1.0.md) governs every ticket. Ready work identifies source requirements, dependencies, owning module, data/AI/privacy impacts, acceptance cases and scope exclusions. Done work supplies implemented behavior and actual test evidence, migration/rollback checks where needed and privacy checks for touched private paths.

The board uses Todo, In Progress and Done. Future milestones stay Todo; M7 must remain unstarted under the user's current instruction. Done describes the implemented ticket plus its recorded automated evidence. A user-authorized verification hold is tracked separately and never represented as a passing test. Held live M2/M3 checks and physical M6 checks remain open until the user resumes them.

## Change control and templates

New behavior outside the locked PRD requires explicit user approval and a versioned change request before implementation. Bug fixes and implementation of existing requirements do not silently rewrite the baseline. Change requests must record the current/requested behavior, affected requirements, architecture/data/privacy/package impact, approval and version decision. Defect reports need synthetic reproduction, expected/actual behavior and impact. Implementation tickets follow the locked governance template linked above; reviews use the [PR checklist](../../.github/PULL_REQUEST_TEMPLATE.md).

## Fixture, privacy and validation rules

- Use artificial names/dates, generated media and synthetic keys. Never commit real keys, identity, health notes, private media, raw prompts/responses, external-file extracts or native logs from unrelated apps.
- Isolate databases, files and native queues; clean up fixtures, restore normal entrypoints after integration runs and preserve user app data. Device captures contain synthetic data only; inspect host copies and remove generated app copies.
- Every private path gets meaningful success/failure sentinels at touched diagnostic/export/provider boundaries. Logs use fixed event identifiers and safe diagnostic metadata. Exports use dedicated allowlisted DTOs; never serialize local database rows.
- Future AI fixtures need valid, invalid, repairable and non-repairable structured outputs, schema/business/exercise-ID/privacy validation, approved repair bounds and explicit user review before persistence. Future import/export fixtures need positive/negative versions, ownership validation and privacy exclusions.
- Golden/reference fixture changes require a named behavior reason, source requirement, reviewed before/after diff and regenerated artifacts. Never update expected output solely to hide a failing case.
- Record format/analyze/tests actually run, failures resolved, checks held/skipped and their reasons. Automated success does not certify live services, physical devices or future features.

## Board and labels

The private [Aedify v1 implementation board](https://github.com/orgs/Aedify-Fitness/projects/1) is linked to `Aedify-Fitness/aedify-app`. Cards contain their roadmap milestone, owning workstream, change-control state and a source link to dependency gates. Human assignees remain unassigned until chosen by the project owner. Built-in Status separates completed implementation from future/held work; the Roadmap milestone field supports milestone grouping. No future implementation is authorized by importing its planning card.

Repository labels `M0`–`M14` follow the roadmap's numbering. The versioned [board verification snapshot](board-state.json) records the final inventory and holds. No key, user payload or private test output belongs in a card.

Maintain the traceability document and board snapshot against the indexed locked sources when requirements or ticket status change. Verify milestone/workstream/change-control fields, dependency links and explicit holds when updating the board. Future work stays Todo until implementation is authorized. Existing locked source files remain in `references/`; they are not duplicated or rewritten.

The Python helpers and YAML issue templates introduced during gap closure were removed at the user's request on 2026-11-06. The board, labels, traceability snapshot and PR checklist remain available; CI runs its existing Flutter generation, formatting, analysis and test gates.
