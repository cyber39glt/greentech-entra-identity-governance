# Access Request JML-2026-001 — New Starter

> **Simulated ticket.** GreenTech has no ticketing system in this lab, so the request and approvals are recorded in this form. The account creation and access changes it describes were **implemented** in the Entra tenant.

## Part 1 — HR request (completed by HR Administrator)

| Field | Value |
|---|---|
| Request type | Joiner — new permanent employee |
| Requested by | Sara Bajwa, HR Administrator |
| Request date | 2026-11-13 |
| Employee name | Adaeze Lindqvist |
| Employee ID | GT0251 |
| Job title | Financial Analyst |
| Department | Finance |
| Manager | Emeka Barros, Finance Manager |
| Employment type | Employee (permanent) |
| Location | Toronto HQ |
| Start date | 2026-11-16 |
| Role access profile | FIN-ANALYST |
| HR checks complete (contract signed, ID verified) | ☑ Yes |

## Part 2 — Manager approval

| Field | Value |
|---|---|
| Approver | Emeka Barros, Finance Manager |
| Access approved | FIN-ANALYST profile: SG-ALL-Employees, SG-FIN-Staff, SG-APP-LedgerPro-Users |
| Access **not** approved | SG-FIN-Payroll-Restricted (not needed for the role) |
| Decision | ☑ Approved |
| Date | 2026-11-13 (simulated approval, recorded before account creation) |

## Part 3 — IT fulfilment (completed by Identity & Access Administrator)

| Field | Value |
|---|---|
| Fulfilled by (admin account used) | adm-anakamura |
| Account created (date/time) | Exact time in audit log entry "Add user" (actor adm-anakamura) |
| UPN | adaeze.lindqvist@<tenant>.onmicrosoft.com |
| Groups added | SG-ALL-Employees, SG-FIN-Staff, SG-APP-LedgerPro-Users |
| Manager set | ☑ |
| Temporary credential delivered to | Manager, by a separate channel (not email to the new hire's personal address) |
| MFA registered on day one | ☑ Yes — first sign-in (see snapshot: microsoftAuthenticator) |
| Snapshot evidence | `09-evidence/snapshots/JML-2026-001-adaeze.lindqvist-after-*.md` |

## Part 4 — Verification and closure

| Check | Result |
|---|---|
| Groups match FIN-ANALYST profile exactly | ☑ |
| Not a member of SG-FIN-Payroll-Restricted | ☑ |
| No admin roles | ☑ |
| Audit log shows actions by adm-anakamura | ☑ |
| Closed by / date | Augustine Aba (as adm-anakamura) / 2026-11-19 |
