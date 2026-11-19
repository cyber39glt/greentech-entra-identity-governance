# Staff and Role Register

`staff-role-register.csv` lists every GreenTech identity: 250 employees, 10 contractors, 5 external partner contacts and 1 pending hire. **All names are fictional** and generated for this lab. `greentech.example` and `partner.example` are reserved example domains, not real ones.

## Columns

| Column | Meaning |
|---|---|
| EmployeeID | `GT####` employee, `CT###` contractor, `EP###` external partner |
| DisplayName / GivenName / Surname | Fictional identity |
| Department / JobTitle | Used to derive group membership |
| ManagerID / ManagerName | Reporting line (approver for access requests) |
| EmploymentType | Employee, Contractor, External Partner, Employee (pending hire) |
| Location | Toronto HQ, Mississauga Warehouse, Field (Ontario), Remote, External |
| AccessTier | Executive, Manager, Privileged, Highly Sensitive, Sensitive, Standard, Frontline, Contractor, Guest |
| PrivilegedRole | Admin role held (always via a separate `adm-` account) |
| StartDate / EndDate | EndDate is mandatory for contractors and partners |
| ProposedUPN | Design value; in the lab tenant the domain becomes your `*.onmicrosoft.com` domain |
| LabUser | `Yes` = this identity will be created in the test tenant |
| LabScenario | Role it plays in testing (Joiner, Mover, Leaver, Contractor, Guest, baseline) |

## Lab identities

| ID | Name | Title | Scenario |
|---|---|---|---|
| GT0001 | Maya Adeyemi | Chief Executive Officer | Executive persona |
| GT0007 | Paula Mwangi | IT Manager | Approver for privileged access |
| GT0008 | Ana Nakamura | Identity & Access Administrator | Performs JML changes (admin role holder) |
| GT0013 | Julia Kowalski | Security Analyst | Read-only log review |
| GT0020 | Sofia Barros | Service Desk Analyst | Helpdesk Administrator scope test |
| GT0032 | Emeka Barros | Finance Manager | Approves Joiner |
| GT0047 | Emeka Sutherland | Payroll Specialist | Sensitive data access test |
| GT0050 | Samuel Eze | Financial Analyst | **MOVER**: Finance → Operations |
| GT0062 | Paula Walsh | HR Manager | Owner of JML process |
| GT0070 | Sara Bajwa | HR Administrator | Initiates Joiner/Leaver requests |
| GT0077 | Owen Moreau | Sales Director | Department manager persona |
| GT0085 | Rosa Sutherland | Account Executive | **LEAVER** |
| GT0137 | Nia Delgado | Marketing Manager | Contractor sponsor |
| GT0144 | Paula Kim | Content Writer | Standard user baseline |
| GT0166 | Ingrid Novak | Operations Manager | Approves Mover |
| GT0167 | Tariq Sutherland | Project Manager | Operations baseline |
| GT0181 | Hannah Kariuki | Solar Installation Technician | Frontline baseline |
| CT010 | Chen Gagnon | Freelance Copywriter (Contractor) | **CONTRACTOR** with 90-day expiry |
| EP003 | Noah Grant | External Auditor (Partner) | **GUEST** (B2B) |
| GT0251 | Adaeze Lindqvist | Financial Analyst (pending hire) | **JOINER** — created in Step 6, not before |
