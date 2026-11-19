# Architecture

## 1. Identity governance overview

```mermaid
flowchart LR
    HR[HR request<br/>simulated form] --> APR[Manager approval<br/>simulated form]
    APR --> ADM[Identity & Access Admin<br/>adm-anakamura<br/>User + Groups Admin]
    ADM --> USR[Entra ID user<br/>HR attributes + manager]
    ADM --> GRP[Security groups<br/>role access profiles]
    GRP --> APPS[Apps & data<br/>LedgerPro · FieldOps · CRM · SharePoint]
    USR --> MFA[Security defaults<br/>MFA]
    ADM --> LOG[Audit logs]
    USR --> SIGN[Sign-in logs]
    LOG --> EV[Evidence<br/>snapshots · change reports · screenshots]
    SIGN --> EV
```

## 2. Lifecycle

```mermaid
flowchart LR
    J[Joiner<br/>profile groups + MFA day one] --> M[Mover<br/>remove old profile → add new]
    M --> L[Leaver<br/>block → revoke → remove → evidence]
    C[Contractor<br/>ext. account + sponsor + end date] --> L
```

## 3. Access model

```mermaid
flowchart TB
    subgraph Accounts
      D[Daily account<br/>no admin roles]
      A[adm- account<br/>narrow Entra role]
      B[Break-glass x2<br/>Global Administrator]
    end
    D --> BASE[SG-ALL-Employees]
    D --> DEPT[Department group<br/>SG-FIN-Staff …]
    D --> APP[App group<br/>SG-APP-LedgerPro-Users …]
    D -. separate approval .-> SENS[Restricted group<br/>SG-FIN-Payroll-Restricted]
    A --> ROLE[Helpdesk / User / Groups Admin<br/>Security Reader]
    B --> EXC[SG-SEC-BreakGlass-Exclude<br/>excluded from Conditional Access - designed]
```

## 4. Lab environment

| Component | Detail |
|---|---|
| Tenant | Microsoft Entra ID Free (dedicated test tenant) |
| Azure subscription | Expired — no Azure resources; Azure RBAC designed only |
| Identities | 17 employees + 1 joiner + 1 contractor; 3 `adm-` accounts; 2 break-glass; 1 lab owner admin |
| Groups | 20 assigned security groups with business owners |
| Automation | Microsoft Graph PowerShell (create, verify, snapshot, compare) |
| MFA | Security defaults + Microsoft Authenticator |
