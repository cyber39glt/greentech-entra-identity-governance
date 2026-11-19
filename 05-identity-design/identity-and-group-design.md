# Identity and Group Design

**Step:** 3 · **Status:** Implemented (assigned groups) · Designed (dynamic groups, role-assignable groups — need Entra ID P1)

## 1. Design principles

1. **Access through groups, never directly to people.** Removing someone from a group is how access is removed. (BR-02, AP-02)
2. **One group, one purpose.** Department groups describe *who you are*; application and resource groups describe *what you can open*.
3. **Every group has a business owner** — the manager accountable for who is in it. Owners do not automatically get access (the Finance Manager owns the Payroll group but is not a member).
4. **Sensitive access is separate.** Payroll and HR records have their own restricted groups so they can be reviewed more often.
5. **Employees, contractors and guests are separated** so contractors never inherit "all staff" access by accident.

## 2. Naming standards

| Object | Pattern | Example |
|---|---|---|
| Employee account | `firstname.lastname@<domain>` | `samuel.eze@…` |
| Contractor account | `ext.firstname.lastname@<domain>` | `ext.chen.gagnon@…` |
| Guest account | Invited via B2B, shows `#EXT#` | `noah.grant_partner.example#EXT#@…` |
| Admin account | `adm-<initials>@<domain>` (cloud-only, no mailbox) | `adm-anakamura@…` |
| Break-glass account | `bg-emergency0#@<tenant>.onmicrosoft.com` | `bg-emergency01@…` |
| Security group | `SG-<SCOPE>-<Purpose>[-Restricted]` | `SG-FIN-Payroll-Restricted` |

Scope codes: `ALL`, `EXE`, `IT`, `FIN`, `HR`, `SAL`, `MKT`, `OPS`, `APP` (application), `SPO` (SharePoint site), `EXT` (external), `SEC` (security control).

## 3. User attributes used for governance

| Attribute | Example | Used for |
|---|---|---|
| `employeeId` | GT0050 | Links the account to the HR register |
| `department` | Finance | Group membership decisions; future dynamic rules |
| `jobTitle` | Financial Analyst | Role-based access |
| `employeeType` | Employee / Contractor | Separating contractors from staff |
| `employeeHireDate` | 2024-05-01 | Joiner evidence |
| `manager` | Emeka Barros | Approver for access changes |
| `companyName` | GreenTech Solutions Ltd. | Identifies lab objects |
| `usageLocation` | CA | Required before any licence can be assigned |

## 4. Group catalogue (20 groups)

| Group | Category | Owner | Purpose |
|---|---|---|---|
| SG-ALL-Employees | Baseline | HR Manager | All permanent employees — intranet, M365 baseline |
| SG-ALL-Managers | Role | HR Manager | People managers — approvers |
| SG-EXE-Leadership | Department | CEO | Executive team |
| SG-IT-Staff | Department | IT Manager | IT department |
| SG-FIN-Staff | Department | Finance Manager | Finance department and Finance site |
| SG-HR-Staff | Department | HR Manager | HR department |
| SG-SAL-Staff | Department | Sales Director | Sales department |
| SG-MKT-Staff | Department | Marketing Manager | Marketing department |
| SG-OPS-Staff | Department | Operations Manager | Operations department |
| SG-OPS-Frontline | Role | Operations Manager | Field workers — mobile apps only |
| SG-FIN-Payroll-Restricted | Sensitive | Finance Manager | Payroll data (PayFlow) |
| SG-HR-Records-Restricted | Sensitive | HR Manager | Employee records |
| SG-APP-LedgerPro-Users | Application | Finance Manager | ERP access |
| SG-APP-TalentHub-Users | Application | HR Manager | HRIS access |
| SG-APP-PipelineCRM-Users | Application | Sales Director | CRM access |
| SG-APP-FieldOps-Users | Application | Operations Manager | Field scheduling app |
| SG-SPO-ExternalAudit-Members | Resource | Finance Manager | Time-bound audit site (Step 9) |
| SG-EXT-Contractors | External | IT Manager | All contractors (Step 9) |
| SG-EXT-Guests | External | IT Manager | All B2B guests (Step 9) |
| SG-SEC-BreakGlass-Exclude | Security | IT Manager | Break-glass accounts — excluded from Conditional Access |

## 5. Access matrix (lab users)

✔ = member · O = owner (not member)

| User | Title | ALL-Emp | ALL-Mgr | Dept group | Sensitive | App |
|---|---|:-:|:-:|---|---|---|
| Maya Adeyemi | CEO | ✔ | ✔ | EXE-Leadership | — | — |
| Paula Mwangi | IT Manager | ✔ | ✔ | IT-Staff | — | — |
| Ana Nakamura | Identity & Access Admin | ✔ | | IT-Staff | — | — |
| Julia Kowalski | Security Analyst | ✔ | | IT-Staff | — | — |
| Sofia Barros | Service Desk Analyst | ✔ | | IT-Staff | — | — |
| Emeka Barros | Finance Manager | ✔ | ✔ | FIN-Staff | Payroll **O** | LedgerPro |
| Emeka Sutherland | Payroll Specialist | ✔ | | FIN-Staff | Payroll ✔ | LedgerPro |
| Samuel Eze | Financial Analyst | ✔ | | FIN-Staff | — | LedgerPro |
| Paula Walsh | HR Manager | ✔ | ✔ | HR-Staff | HR-Records ✔ | TalentHub |
| Sara Bajwa | HR Administrator | ✔ | | HR-Staff | HR-Records ✔ | TalentHub |
| Owen Moreau | Sales Director | ✔ | ✔ | SAL-Staff | — | PipelineCRM |
| Rosa Sutherland | Account Executive | ✔ | | SAL-Staff | — | PipelineCRM |
| Nia Delgado | Marketing Manager | ✔ | ✔ | MKT-Staff | — | — |
| Paula Kim | Content Writer | ✔ | | MKT-Staff | — | — |
| Ingrid Novak | Operations Manager | ✔ | ✔ | OPS-Staff | — | FieldOps |
| Tariq Sutherland | Project Manager | ✔ | | OPS-Staff | — | FieldOps |
| Hannah Kariuki | Solar Installation Technician | ✔ | | OPS-Staff + OPS-Frontline | — | FieldOps |

Break-glass accounts `bg-emergency01` and `bg-emergency02` → `SG-SEC-BreakGlass-Exclude`.

Source of truth: `scripts/data/lab-memberships.csv` (57 memberships).

## 6. Lab reporting lines

Where a person's real manager (per the register) is not one of the 17 lab users, the lab sets the manager to the nearest lab user higher up the chain. Example: Rosa Sutherland reports to a Regional Sales Manager in the register; in the lab her manager is the Sales Director, Owen Moreau. This keeps every approval in the workflows traceable to a real lab account.

## 7. Free-tier limits and the designed alternative

| Capability | Free tier | Licence needed | What this project does |
|---|---|---|---|
| Assigned security groups | ✅ | — | **Implemented** |
| Group owners | ✅ | — | **Implemented** |
| Manager attribute | ✅ | — | **Implemented** |
| Dynamic membership groups | ❌ | Entra ID P1 | **Designed** — rules below; manual membership is used instead |
| Role-assignable groups (assign Entra roles to a group) | ❌ | Entra ID P1 | **Designed** — roles assigned directly to `adm-` accounts in Step 5 |
| Group expiration policy | ❌ | Entra ID P1 (applies to M365 groups) | **Designed** |

### Designed dynamic membership rules (for when P1 is available)

| Group | Rule |
|---|---|
| SG-ALL-Employees | `(user.employeeType -eq "Employee") -and (user.accountEnabled -eq true)` |
| SG-FIN-Staff | `(user.department -eq "Finance") -and (user.employeeType -eq "Employee")` |
| SG-OPS-Staff | `(user.department -eq "Operations") -and (user.employeeType -eq "Employee")` |
| SG-OPS-Frontline | `(user.department -eq "Operations") -and (user.jobTitle -in ["Solar Installation Technician","Energy Auditor","Battery Storage Specialist"])` |
| SG-EXT-Contractors | `(user.employeeType -eq "Contractor")` |
| SG-EXT-Guests | `(user.userType -eq "Guest")` |

Sensitive groups (Payroll, HR Records) and application groups stay **assigned**, with owner approval, even with P1. Automatic access to payroll data based on an HR attribute is a risk in its own right.

**Why it matters:** With dynamic groups, a mover's department change would remove Finance access automatically. On the free tier that removal is a manual step, which is exactly the risk (R-02 privilege creep) the Mover procedure in Step 7 must control.
