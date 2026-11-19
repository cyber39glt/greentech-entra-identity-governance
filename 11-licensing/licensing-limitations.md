# Licensing Limitations and Recommendations

The lab ran on **Microsoft Entra ID Free** with an expired Azure free subscription. No paid licences or trials were used.

## 1. What the free tier covered vs. what was only designed

| Capability | Licence needed | In this project |
|---|---|---|
| Users, assigned security groups, group owners, manager attribute | Free | Implemented |
| Built-in admin roles (separate admin accounts) | Free | Implemented |
| MFA via security defaults | Free | Implemented |
| Audit and sign-in logs (7 days) | Free | Implemented |
| Graph PowerShell automation | Free | Implemented |
| Azure RBAC on resource groups | Active Azure subscription | Designed |
| Conditional Access | Entra ID P1 | Designed |
| Dynamic membership groups | Entra ID P1 | Designed |
| Role-assignable groups | Entra ID P1 | Designed |
| 30-day log retention | Entra ID P1 | Designed |
| Privileged Identity Management | Entra ID P2 | Designed |
| Identity Protection (risk-based policies) | Entra ID P2 | Designed |
| Access reviews, entitlement management | Entra ID P2 / Entra ID Governance | Designed |
| Lifecycle Workflows | Entra ID Governance | Designed |

## 2. Impact of the gaps

| Gap | Effect on GreenTech |
|---|---|
| No Conditional Access | MFA is all-or-nothing; break-glass accounts cannot be excluded; no device or location rules for payroll data |
| No dynamic groups | Mover and leaver removals depend on people remembering — the main source of privilege creep |
| No PIM | Admin roles are permanent ("standing") rather than activated when needed |
| No access reviews | Nobody is prompted to re-confirm who has payroll, HR or guest access |
| No automatic expiry | Contractor and guest access ends only if someone acts on the end date |

## 3. Recommendation

| Priority | Recommendation | Why |
|---|---|---|
| 1 | **Entra ID P1 for all 250 users** (included in Microsoft 365 Business Premium / E3) | Conditional Access and dynamic groups close the two biggest gaps (MFA rules, mover/leaver automation) |
| 2 | **Entra ID P2 for IT administrators and Finance/HR staff** | PIM for admin roles; access reviews for sensitive groups |
| 3 | **Entra ID Governance** once headcount growth continues | Lifecycle Workflows automate joiner/mover/leaver from HR data; time-bound access packages for contractors and guests |
| — | Until then | Keep the manual procedures, monthly checks and evidence in this project |

Licence pricing changes often and depends on the agreement; check Microsoft's current pricing before budgeting.
