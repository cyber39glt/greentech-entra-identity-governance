# Step 7 — Test Plan: Mover (JML-2026-002)

**Date:** 2026-11-19

| ID | Test | Method | Expected | Actual | Pass/Fail | Evidence |
|---|---|---|---|---|---|---|
| T07-01 | Both managers approved before change | Request form Part 2 times vs audit log | Approvals earlier than first change | | | Request form |
| T07-02 | Before snapshot shows Finance access | Before snapshot | SG-FIN-Staff, SG-APP-LedgerPro-Users present | | | `snapshots/JML-2026-002-…-before-*.md` |
| T07-03 | Finance access removed | Change report | Removed (2): SG-APP-LedgerPro-Users, SG-FIN-Staff | | | `JML-2026-002-change-report.md` |
| T07-04 | Operations access added | Change report | Added (2): SG-APP-FieldOps-Users, SG-OPS-Staff | | | same |
| T07-05 | Baseline kept | Change report | Unchanged (1): SG-ALL-Employees | | | same |
| T07-06 | Attributes and manager updated | Change report → attribute changes | Department, Job title, Manager changed | | | same |
| T07-07 | Sessions revoked | Audit logs → "Invalidate all refresh tokens for user" (or similar) | Entry present, actor adm-anakamura | | | `step07-03-audit-log.png` |
| T07-08 | Samuel no longer in LedgerPro group | Groups → SG-APP-LedgerPro-Users → Members | Samuel Eze not listed | | | `step07-02-ledgerpro-members.png` |

## Notes / issues found

-
