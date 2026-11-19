# Monitoring and Audit Evidence

## 1. Log sources used (free tier)

| Log | Where | What it proves | Free-tier retention |
|---|---|---|---|
| Audit logs | Entra ID → Monitoring & health → Audit logs | Who created/changed users, groups, roles, sessions | 7 days |
| Sign-in logs | Entra ID → Monitoring & health → Sign-in logs | Who signed in, success/failure, MFA details | 7 days |
| Access snapshots | `09-evidence/snapshots/` | A user's full access at a point in time | Permanent (kept in this repo, domain redacted) |
| Change reports | `09-evidence/snapshots/*-change-report.md` | Exactly what a lifecycle change removed and added | Permanent |

**Limitation:** 7-day retention means evidence must be captured during the change. P1/P2 extend this to 30 days; exporting to a Log Analytics workspace or storage account (needs an Azure subscription) keeps it longer.

## 2. What to look for

| Event | Audit log activity | Expected actor |
|---|---|---|
| Joiner | Add user · Add member to group · Update user (manager) | adm-anakamura |
| Mover | Update user · Remove member from group · Add member to group · Invalidate all refresh tokens | adm-anakamura |
| Leaver | Update user (account disabled) · Invalidate all refresh tokens · Reset password · Remove member from group | adm-anakamura |
| Role change | Add member to role | adm-aaba only (lab owner) |
| **Alert-worthy** | Add member to role **Global Administrator**; any sign-in by `bg-emergency0#`; changes made by an unexpected actor | — |

## 3. Monthly checks (manual, free)

1. Global Administrator list contains only break-glass accounts and the documented exception.
2. Users → filter **Account enabled = No**: disabled leavers older than 30 days are deleted.
3. Users with **Employee type = Contractor**: each has an end date in the future on its request.
4. Restricted groups (Payroll, HR Records): owner confirms membership.
5. Enterprise applications: review newly consented apps and their permissions.

## 4. Designed improvements (licensed)
- Diagnostic settings → send audit and sign-in logs to Log Analytics; alert rules for Global Administrator assignments and break-glass sign-ins.
- Microsoft Sentinel analytics rule on break-glass account sign-ins.
- Workbooks for MFA registration and sign-in failures.
