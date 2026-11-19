# Step 3 — Test Plan: Users and Groups

**Type:** Implemented · **Tester:** Lab owner (`adm-aaba`) · **Date:** 2026-11-13

| ID | Test | Method | Expected result | Actual result | Pass | Evidence |
|---|---|---|---|---|---|---|
| T03-01 | 17 lab users exist with correct department, title, employeeId | Verify script | All `User exists` / `Department` / `Job title` checks PASS | | | `results/step03-verification-*.csv` |
| T03-02 | Manager links set | Verify script | 16 `Manager` checks PASS (CEO has no manager) | | | same |
| T03-03 | 20 security groups exist with correct owners | Verify script | All `Group exists` / `Owner` checks PASS | | | same |
| T03-04 | Memberships match design | Verify script | All `Members` checks PASS (57 memberships) | | | same |
| T03-05 | Least privilege: Finance Manager is **owner but not member** of Payroll group | Portal: SG-FIN-Payroll-Restricted → Owners / Members | Emeka Barros listed under Owners only | | | `step03-04-payroll-owner-not-member.png` |
| T03-06 | Contractors/guests not in SG-ALL-Employees | Portal: SG-ALL-Employees → Members | 17 members, all `GT` employees | | | `step03-03-all-employees-members.png` |
| T03-07 | No passwords stored in project | Search the project folder for "password" | Only matches are documentation text and the script's password **generator** (no actual values) | | | Note in results |
| T03-08 | Script is safe to re-run | Run create script a second time | All lines show `Skipped`; 0 `Created`, 0 `Error` | | | `results/step03-run-log-*.csv` (2nd run) |

## Notes / issues found

-
