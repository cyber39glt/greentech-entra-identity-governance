# Final Assessment Report — Identity Governance for GreenTech Solutions Ltd.

**Author:** Augustine Alfred Aba · **Environment:** Microsoft Entra ID Free test tenant · **Organization:** fictional

## 1. Executive summary
GreenTech Solutions Ltd. is a fictional 250-person renewable energy company growing ~20% a year, with high field-staff turnover, contractors and external partners. Its identity risks are typical of a growing business: orphaned accounts, access that piles up when people move, weak MFA and too many permanent administrators.

This project designed an identity governance model for GreenTech and tested it in a free Microsoft Entra ID tenant. It shows that a meaningful baseline — group-based access, MFA, separate least-privilege admin accounts, documented joiner/mover/leaver procedures and audit evidence — is achievable **without paid licensing**, and identifies exactly which controls need Entra ID P1/P2 to become automatic.

## 2. Scope and method

| In scope | Approach |
|---|---|
| Identity design (naming, attributes, 20 security groups, role access profiles) | Designed and implemented |
| 17 representative employee identities (from a 250-person register) | Created with Microsoft Graph PowerShell, verified by script |
| MFA | Security defaults; tested with standard and admin users |
| Least privilege | Separate `adm-` accounts with narrow roles; positive and negative tests |
| Joiner, mover, leaver, contractor | Procedures with RACI, risks, controls and tests; approvals simulated with request forms |
| Conditional Access, PIM, access reviews, entitlement management, lifecycle workflows, Azure RBAC | Designed only (licence or subscription not available) |

**Implemented** = configured in the tenant. **Simulated** = paper process standing in for a ticketing/approval system. **Designed** = documented, not configured.

## 3. Lab status

✅ = done in the lab · 📝 = designed/documented only.

| Area | Status | Evidence |
|---|---|---|
| Company profile, register, requirements | ✅ | `01-company`, `02-staff-register` |
| Break-glass and lab admin accounts | ✅ | `07-configuration/step02-tenant-assessment.md` |
| Users and groups (scripted + verified) | ✅ | `08-testing/step03-test-plan.md`, `08-testing/results` |
| MFA via security defaults | ✅ | `08-testing/step04-test-plan.md` |
| Least-privilege admin roles | ✅ | `08-testing/step05-test-plan.md` |
| Joiner (JML-2026-001) | ✅ | `06-procedures/requests`, `09-evidence/snapshots` |
| Mover (JML-2026-002) | ✅ | `09-evidence/snapshots/JML-2026-002-change-report.md` |
| Leaver (JML-2026-003) | 📝 | `06-procedures/03-leaver-procedure.md` |
| Contractor (JML-2026-004) | 📝 | `06-procedures/04-contractor-guest-procedure.md` |
| Guest lifecycle | 📝 | `06-procedures/04-contractor-guest-procedure.md` |
| Premium controls | 📝 | `07-configuration/premium-controls-design.md` |
| Azure RBAC | 📝 | `05-identity-design/admin-roles-rbac-design.md` |

## 4. Key findings

| # | Finding | Severity | Recommendation |
|---|---|---|---|
| F1 | Security defaults give users up to 14 days to register MFA; unregistered accounts (e.g. a frontline technician) could have MFA registered by an attacker who learns the password | High | Register MFA on day one in the joiner procedure (done); Temporary Access Pass + Conditional Access with P1 |
| F2 | Security defaults cannot exclude break-glass accounts | Medium | Conditional Access with exclusion group and FIDO2 keys (P1) |
| F3 | Without dynamic groups, mover and leaver removals are manual — the main cause of privilege creep | High | Old-manager sign-off and change reports now; dynamic groups / Lifecycle Workflows with licensing |
| F4 | Admin roles are permanent | Medium | PIM eligible assignments (P2) |
| F5 | Granting Graph PowerShell consent added a highly privileged enterprise app to the tenant | Medium | Restrict user consent; review enterprise apps monthly |
| F6 | Audit and sign-in logs are kept only 7 days on the free tier | Medium | Capture evidence at change time (done); P1 for 30 days; export to Log Analytics |
| F7 | Lab owner keeps Global Administrator (documented exception) | Low (lab) | No standing Global Administrator in production |

## 5. What worked well
- **Owner-but-not-member** on the payroll group separates managing access from having it.
- **Negative tests** (helpdesk cannot reset an admin's password, identity admin cannot grant herself Global Administrator) proved least privilege rather than assuming it.
- **Snapshots and change reports** turn "I removed his access" into a file showing exactly what was removed — evidence an auditor can check.
- **Scripted provisioning** made the build repeatable and verifiable (PASS/FAIL against the design).

## 6. Recommendations (priority order)
1. Entra ID P1 for all users: Conditional Access (CA01–CA06) and dynamic department groups.
2. Entra ID P2 for administrators and Finance/HR: PIM and quarterly access reviews of restricted groups.
3. Entra ID Governance as growth continues: lifecycle workflows driven from HR data; 90-day access packages for contractors and guests.
4. Until licensed: run the monthly checks in `10-monitoring-audit/monitoring-and-audit.md`.

## 7. Lessons learned
- Identity governance starts with HR data and business owners, not portal settings.
- Removing access is harder than granting it, so removal needs its own approver and its own evidence.
- A free tenant can demonstrate the principles; licensing mainly buys automation and enforcement.
- Being explicit about what was implemented, simulated or only designed makes the work more credible, not less.
