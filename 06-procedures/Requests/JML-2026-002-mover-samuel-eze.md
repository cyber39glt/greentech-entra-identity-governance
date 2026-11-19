# Access Request JML-2026-002 — Internal Transfer

> **Simulated ticket.** The request and approvals are recorded in this form. The account changes were **implemented** in the Entra tenant.

## Part 1 — HR request

| Field | Value |
|---|---|
| Request type | Mover — internal transfer |
| Requested by | Sara Bajwa, HR Administrator |
| Request date | 2026-11-19 |
| Employee | Samuel Eze (GT0050) |
| From | Finance — Financial Analyst — manager Emeka Barros |
| To | Operations — Project Coordinator — manager Ingrid Novak |
| Effective date | 2026-11-19 |
| Old profile → new profile | FIN-ANALYST → OPS-COORDINATOR |

## Part 2 — Approvals

| Approver | Decision | Date/time |
|---|---|---|
| Emeka Barros (old manager) — confirms Finance access can be removed and work handed over | ☑ Approved | 2026-11-19 (simulated) |
| Ingrid Novak (new manager) — approves Operations access | ☑ Approved | 2026-11-19 (simulated) |

## Part 3 — Access changes

| Action | Item | Done |
|---|---|---|
| Remove | SG-FIN-Staff | ☑ |
| Remove | SG-APP-LedgerPro-Users | ☑ |
| Add | SG-OPS-Staff | ☑ |
| Add | SG-APP-FieldOps-Users | ☑ |
| Keep | SG-ALL-Employees | ☑ |
| Update | Job title → Project Coordinator | ☑ |
| Update | Department → Operations | ☑ |
| Update | Manager → Ingrid Novak | ☑ |
| Revoke sessions | Forces new sign-in so old group access in existing tokens stops | ☑ |
| Check ownership | Owns no Finance groups/apps (or ownership transferred) | ☑ |

Fulfilled by: `adm-anakamura` · Date: 2026-11-19 (exact times in audit log)

## Part 4 — Verification

| Check | Result |
|---|---|
| Before snapshot taken | `09-evidence/snapshots/JML-2026-002-samuel.eze-before-*.md` |
| After snapshot taken | `09-evidence/snapshots/JML-2026-002-samuel.eze-after-*.md` |
| Change report shows 2 removed, 2 added | ☑ |
| No Finance groups remain | ☑ |
| Audit log entries by adm-anakamura | ☑ |
| Closed by / date | Augustine Aba (as adm-anakamura) / 2026-11-19 |
