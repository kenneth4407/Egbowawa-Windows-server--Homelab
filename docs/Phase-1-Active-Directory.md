# Phase 1 - Active Directory Foundation

## Overview

Phase 1 of my Egbowawa-SmartHub homelab focused on building the Active Directory foundation that I will continue using throughout the rest of the project.

I started by learning the basic Active Directory concepts and then used them to build my own domain structure. The environment includes two Domain Controllers, departmental OUs, over 100 employee accounts, security groups, administrative accounts, PowerShell automation, and a domain-joined Windows 11 client.

**Domain:** `Egbowawa.local`

---

## What I Built

During this phase, I set up:

- Two Domain Controllers: `SMARTHUB-DC` and `SMARTHUB-CORE`
- Main `Egbowawa-SmartHub` OU
- Departmental user OUs
- Departmental computer OUs
- Over 100 employee accounts
- Department-based Global Security Groups
- Separate administrative accounts
- Dedicated IT administrative group
- Service Accounts OU for future use
- PowerShell bulk-user provisioning
- Windows 11 Pro domain client
- Active Directory-integrated DNS
- Domain Controller replication

---

## Active Directory OU Design

I created `Egbowawa-SmartHub` as the main OU for the lab.

Under it, I separated the different types of Active Directory objects:

```text
Egbowawa.local
│
└── Egbowawa-SmartHub
    │
    ├── Users
    ├── Computers
    ├── Servers
    ├── Groups
    ├── Admin-Accounts
    └── Service-Accounts
```

The `Users` OU contains separate OUs for departments such as IT, Human Resources, Finance, Sales, Marketing, Operations, Customer Service, and Management.

I also created departmental computer OUs so that computer configurations can be managed separately as I begin working with Group Policy.

### OU Structure

![Active Directory OU Structure](Screenshot/Active-directory/1-OU-Structure.png)

---

## Users and Departments

Employee accounts are organized according to their department instead of placing every account in one location.

For example:

```text
Users
├── IT
├── Human-Resources
├── Finance
├── Sales
├── Marketing
├── Operations
├── Customer-Service
└── Management
```

This helped me understand that OUs are used to organize and manage Active Directory objects and can also be used as targets for Group Policy.

### Department OUs

![Department OUs](Screenshot/Active-directory/Users-showing-Department-OU.png)

### Example IT Users

![IT Users](Screenshot/Active-directory/IT-department-nd-USERS.png)

---

## Security Groups

I created Global Security Groups for the different departments.

Examples include:

- `GG-IT-Users`
- `GG-HR-Users`
- `GG-Finance-Users`
- `GG-Sales-Users`
- `GG-Marketing-Users`
- `GG-Operations-Users`
- `GG-CustomerService-Users`
- `GG-Management-Users`

One thing I learned during this part of the project is that an OU and a security group serve different purposes.

Putting an employee inside the IT OU does not automatically make the employee a member of `GG-IT-Users`. Group membership has to be assigned separately.

### Security Groups

![Security Groups](ScreenshotActive-directory-Security-Group-nd-Various-Group-in-It.png)

---

## Administrative Accounts

I created separate administrative accounts instead of using normal employee accounts for administrative work.

For example:

```text
kenneth.egbowawa
```

is a normal employee account, while:

```text
adm-kenneth
```

is an administrative identity.

I also created:

```text
GG-IT-Admins
```

for IT administrative accounts.

This introduced me to the idea of separating normal user activity from privileged administrative activity.

### IT Administrative Group

![IT Admin Membership](Screenshot/Active-directory/Admin-Account-Users.png)

---

## PowerShell User Provisioning

After creating some accounts manually through Active Directory Users and Computers, I used PowerShell and CSV data to automate the remaining user creation.

The script checks the username, validates the destination OU and security group, creates the account, and adds the employee to the appropriate departmental group.

This gave me practice with commands and concepts including:

```powershell
Import-Csv
Get-ADUser
Get-ADOrganizationalUnit
Get-ADGroup
New-ADUser
Add-ADGroupMember
foreach
try
catch
```

The full script and sample CSV are available in the `scripts` folder.

I documented the automation process separately in:

[./phase-1-user-automation.md](./phase-1-user-automation.md)
---

## Verifying the Environment with PowerShell

I also used PowerShell to query Active Directory after creating the users.

Instead of relying only on what I could see in ADUC, I checked user counts, departments, account information, and other AD objects directly from PowerShell.

### Employee Count

![AD User Count](Screenshot/Powershell/01-User-Count.png)

### Users by Department

![Department User Count](Screenshot/Powershell/02-User-Verification.png)



---

## Domain Controllers

The domain currently has two Domain Controllers:

### SMARTHUB-DC

Windows Server with Desktop Experience.

This was the main server I initially used to configure and manage the domain.

### SMARTHUB-CORE

Windows Server Core running as an additional Domain Controller.

Adding Server Core gave me experience working with a server without relying on the normal Windows desktop interface.

---

## Active Directory Replication

After adding the second Domain Controller, I used:

```powershell
repadmin /replsummary
```

to check Active Directory replication.

At the time of testing, both Domain Controllers reported:

```text
0 replication failures
```

I also used:

```powershell
repadmin /showrepl
```

to look at more detailed replication information.

This helped me understand that simply having two Domain Controllers is not enough. Replication between them should also be checked and verified.

### Domain Controller and Replication Verification

![Domain Controller Replication](Screenshot/Domain-Cntrollers/01-Domain-Controller-Replication-Verification.png)

More details are documented in:

[Domain-Controller-Replication.md](docs/Domain-Controller-Replication.md)

---

## Windows 11 Domain Client

I created a Windows 11 Pro VM and joined it to:

```text
Egbowawa.local
```

Before joining the domain, I configured the client to use the internal Active Directory DNS server so that it could locate the domain and its Domain Controllers.

After joining the domain, I moved the computer object into its departmental computer OU and tested signing in using a normal domain user account.

I verified the client using commands such as:

```text
hostname
whoami
echo %logonserver%
```

and:

```powershell
Get-CimInstance Win32_ComputerSystem |
Select-Object Name,Domain,PartOfDomain
```

### Domain Client Verification

![Windows 11 Domain Client](Screenshot/Clients/01-Domain-Login.png)

---

## An Important Thing I Learned

While testing the Windows 11 client, I noticed that users from other departments could also sign in to the computer.

At first, I expected departmental OUs to prevent this.

I learned that placing an IT computer inside the `IT-Computers` OU does not automatically mean only IT users can sign in to it.

This helped me understand the difference between:

**Authentication** — verifying who a user is.

**Authorization** — deciding what that authenticated user is allowed to access or do.

I will continue working with this concept during the Group Policy and security parts of the project.

---

## Phase 1 Result

At the end of Phase 1, I had a working Active Directory environment containing:

```text
Egbowawa.local
       │
       ├── SMARTHUB-DC
       │
       ├── SMARTHUB-CORE
       │
       └── Egbowawa-SmartHub
                │
                ├── 100+ Users
                ├── Department OUs
                ├── Computer OUs
                ├── Security Groups
                ├── Admin Accounts
                └── Domain-Joined Windows 11 Client
```

The environment is now the foundation for the next stage of the project.

## Next Phase

**Phase 2 — Group Policy Fundamentals**

In Phase 2, I will continue using the existing users, groups, OUs, and computers rather than creating a separate environment.

This will allow me to see how Group Policy can be used to centrally manage the environment I built during Phase 1.
