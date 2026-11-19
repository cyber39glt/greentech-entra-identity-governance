# Procedure 02 — Mover (Internal Transfer)

**Scenario tested:** Samuel Eze moves from Finance (Financial Analyst) to Operations (Project Coordinator) · **Ticket:** JML-2026-002

| Part | Type |
|---|---|
| HR request, old and new manager approvals | **Simulated** (request form) |
| Attribute, manager and group changes; session revocation | **Implemented** (by `adm-anakamura`) |
| Before/after evidence | **Implemented** (snapshot + compare scripts) |
| Automatic removal via dynamic groups / Lifecycle Workflows "mover" | **Designed** — needs P1 / Entra ID Governance |

## 1. Business scenario
Samuel is transferring to Operations. If his Finance access is not removed he keeps the ERP and Finance files he no longer needs — **privilege creep** (risk R-02). Over several moves, one person can collect enough access to commit and hide fraud.

## 2. Responsible personnel (RACI)

| Activity | HR Admin | Old manager (Emeka Barros) | New manager (Ingrid Novak) | Identity & Access Admin | IT Manager |
|---|:-:|:-:|:-:|:-:|:-:|
| Raise transfer request | **R/A** | I | I | I | |
| Confirm old access removed / handover | | **R/A** | | I | |
| Approve new access | | | **R/A** | I | |
| Make changes, collect evidence | | | | **R** | **A** |
| Verify and close | I | I | I | **R** | **A** |

## 3. Step-by-step

| # | Action | Who |
|---|---|---|
| 1 | Raise request with old and new profiles | HR Administrator |
| 2 | Old manager approves removal; new manager approves new access | Both managers |
| 3 | **Before** snapshot | Identity & Access Admin |
| 4 | Update job title, department, manager | Identity & Access Admin (`adm-anakamura`) |
| 5 | **Remove** old-profile groups (do removals first) | Identity & Access Admin |
| 6 | Add new-profile groups | Identity & Access Admin |
| 7 | Check owned objects; transfer any Finance ownership | Identity & Access Admin |
| 8 | Revoke sessions | Identity & Access Admin |
| 9 | **After** snapshot and change report | Identity & Access Admin |
| 10 | Check audit log; close request | Identity & Access Admin |

## 4. Expected outcome
- Groups: SG-ALL-Employees, SG-OPS-Staff, SG-APP-FieldOps-Users — **nothing from Finance**.
- Title Project Coordinator, department Operations, manager Ingrid Novak.
- Change report: 2 removed, 2 added, 1 unchanged.

## 5. Security risks and controls

| Risk | Control |
|---|---|
| Privilege creep (keeps Finance access) | Old profile removed **before** new one added; change report proves removal |
| Removal forgotten because nobody owns it | Old manager must sign off removal, not just new manager approve additions |
| Existing sign-in still carries old group access | Revoke sessions forces a fresh sign-in |
| Orphaned ownership (owns a Finance group) | Owned-objects check in the snapshot |
| Toxic combination (e.g. LedgerPro + FieldOps purchasing) | Profiles reviewed by group owners (designed access reviews, Step 11) |

## 6. Test cases
See `08-testing/step07-test-plan.md`.

## 7. Lesson learned
Everyone remembers to add new access, but nobody chases the old access. Removing the Finance access first, getting the old manager's sign-off, and producing a before/after change report turned "I think it was removed" into proof.

## 8. With premium licensing (designed)
- **Dynamic groups (P1):** changing `department` to Operations removes him from SG-FIN-Staff automatically.
- **Lifecycle Workflows (Entra ID Governance):** a "mover" workflow triggered by the department change notifies both managers and removes access packages.
- **Access reviews (P2):** the LedgerPro owner reviews members quarterly and would catch a missed removal.
