# Risk Assessment

Likelihood and impact: 1 (low) – 5 (high). Score = L × I. Controls reference the procedures and steps in this project.

| ID | Risk | L | I | Score | Control in this project | Status | Residual risk |
|---|---|:-:|:-:|:-:|---|---|---|
| R-01 | Orphaned accounts after people leave | 4 | 4 | 16 | Leaver procedure: block, revoke, remove, evidence | Procedure + lab test | Low — depends on HR notifying IT |
| R-02 | Privilege creep after transfers | 4 | 4 | 16 | Mover procedure: old manager signs off removal; change report | Procedure + lab test | Medium — manual without dynamic groups |
| R-03 | Weak or no MFA | 4 | 5 | 20 | Security defaults; MFA registered on day one | Implemented | Medium — no per-group rules, 14-day window for unregistered users |
| R-04 | Standing Global Administrator | 3 | 5 | 15 | Narrow roles on `adm-` accounts; GA limited to break-glass + lab owner | Implemented (lab exception documented) | Medium — no PIM |
| R-05 | Shared accounts on field tablets | 3 | 3 | 9 | Named accounts for every user (policy) | Designed | Medium |
| R-06 | Contractor accounts without end dates | 4 | 4 | 16 | `ext.` prefix, sponsor, end date, offboard on end date | Procedure + lab test | Medium — expiry is manual |
| R-07 | Unreviewed guests | 3 | 4 | 12 | Sponsor + quarterly review | Designed (needs P2) | High until P2 |
| R-08 | Excessive access to payroll/HR data | 3 | 5 | 15 | Restricted groups, owner-not-member, role profiles | Implemented | Low–medium — no access reviews |
| R-09 | No audit trail for access changes | 3 | 4 | 12 | Request forms + audit logs + snapshots | Implemented | Medium — free tier keeps logs 7 days |
| R-10 | Admin work from daily accounts | 3 | 5 | 15 | Separate cloud-only `adm-` accounts | Implemented | Low |
| R-11 | Lockout of tenant by policy mistake | 2 | 5 | 10 | Two tested break-glass accounts | Implemented | Medium — security defaults cannot exclude them |
| R-12 | Over-privileged admin app consent (found in Step 3) | 3 | 4 | 12 | Recorded; restrict user consent, review enterprise apps | Finding | Medium |
