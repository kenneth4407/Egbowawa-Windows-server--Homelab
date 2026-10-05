# Egbowawa-SmartHub — Windows Server Enterprise Homelab

## Project Overview

Egbowawa-SmartHub is my Windows Server homelab project. I created this environment to gain practical experience with Windows Server, Active Directory, networking, PowerShell, and enterprise system administration.

Rather than creating a new lab for every topic I learn, I am continuing to build on the same environment. As I learn technologies such as Group Policy, DNS, DHCP, file services, permissions, security, PowerShell automation, and other Windows Server features, I will implement and document them in Egbowawa-SmartHub.

The environment is designed to represent a mid-sized organization with over 100 employee accounts across multiple departments.

---

## Lab Environment

- **Domain:** `Egbowawa.local`
- **Environment Name:** Egbowawa-SmartHub
- **Virtualization Platform:** Proxmox VE
- **Domain Controllers:** `smarthub-dc` and `smarthub-core`
- **Server Platforms:** Windows Server Desktop Experience and Windows Server Core
- **Client Operating System:** Windows 11 Pro
- **Directory Service:** Active Directory Domain Services (AD DS)
- **DNS:** Active Directory-integrated DNS
- **Automation:** Windows PowerShell

---

## Domain Controllers

The `Egbowawa.local` domain currently has two Domain Controllers.

### `smarthub-dc`

`smarthub-dc` is a Windows Server Domain Controller running the Desktop Experience. It was used to build and manage the initial Active Directory environment.

Administrative tasks performed from this server include:

- Managing Active Directory users and computers
- Creating and managing Organizational Units
- Managing security groups
- Managing computer objects
- Running PowerShell administration commands
- Managing DNS
- Joining and managing domain clients

### `smarthub-core`

`smarthub-core` is an additional Domain Controller running Windows Server Core.

I added Server Core to the environment to gain experience working with a Windows Server installation that does not rely on the full desktop graphical interface.

This also introduced me to managing Windows Server through tools such as:

- PowerShell
- Command Prompt
- SConfig
- Remote administration tools

Having two Domain Controllers also allows me to continue learning about Active Directory replication, DNS redundancy, Domain Controller discovery, and availability as the project develops.

---

## Company Departments

The Active Directory environment is divided into several business departments:

- Information Technology
- Human Resources
- Finance
- Sales
- Marketing
- Operations
- Customer Service
- Management

Each department has its own users and Global Security Group.

Departmental computer OUs are also used to organize workstations.

---

# Phase 1 — Active Directory Foundation

## Objective

The goal of Phase 1 was to build the Active Directory foundation that the rest of Egbowawa-SmartHub will use.

I focused on understanding and working with Active Directory objects rather than simply creating a large number of users.

This phase included Organizational Unit design, user and group administration, PowerShell automation, domain joining, DNS configuration, and administrative account organization.

---

## Active Directory Structure

I created the main `Egbowawa-SmartHub` OU and organized the environment underneath it.

The main structure includes:

```text
Egbowawa.local
│
└── Egbowawa-SmartHub
    │
    ├── Users
    │   ├── IT
    │   ├── Human-Resources
    │   ├── Finance
    │   ├── Sales
    │   ├── Marketing
    │   ├── Operations
    │   ├── Customer-Service
    │   ├── Management
    │   └── Disabled-Users
    │
    ├── Computers
    │   ├── IT-Computers
    │   ├── HR-Computers
    │   ├── Finance-Computers
    │   ├── Sales-Computers
    │   ├── Marketing-Computers
    │   ├── Operations-Computers
    │   ├── CustomerService-Computers
    │   ├── Management-Computers
    │   └── Shared-Computers
    │
    ├── Servers
    │
    ├── Groups
    │   ├── Security-Groups
    │   └── Distribution-Groups
    │
    ├── Admin-Accounts
    │
    └── Service-Accounts
```

This structure separates different types of Active Directory objects and gives me a foundation for applying more advanced configurations later.

For example, the departmental computer OUs will allow different Group Policies to be applied to different groups of computers during Phase 2.

---

## User Accounts

The environment currently contains over 100 employee accounts distributed across the different departments.

Instead of keeping all users in one location, employee accounts are placed in their appropriate departmental OU.

For example:

```text
Users
│
├── IT
│   ├── Kenneth Egbowawa
│   ├── Amara 
│   └── other IT employees
│
├── Human-Resources
│   └── HR employees
│
├── Finance
│   └── Finance employees
│
└── Sales
    └── Sales employees
```

This makes the directory easier to manage and prepares the environment for department-specific Group Policy configurations.

---

## Security Group Design

I created Global Security Groups to organize employees according to their departments.

Examples include:

- `GG-IT-Users`
- `GG-HR-Users`
- `GG-Finance-Users`
- `GG-Sales-Users`
- `GG-Marketing-Users`
- `GG-Operations-Users`
- `GG-CustomerService-Users`
- `GG-Management-Users`

Users are added to the Global Security Group that represents their department.

For example:

```text
Kenneth Egbowawa
        ↓
GG-IT-Users
```

and:

```text
Finance Employees
        ↓
GG-Finance-Users
```

This provides a foundation for using group-based access to resources later in the project.

As the lab develops, I plan to expand this design when working with file servers, NTFS permissions, share permissions, and concepts such as AGDLP.

---

## Administrative Accounts

I separated normal employee accounts from administrative accounts.

For example:

```text
kenneth.egbowawa
```

is my standard user account.

A separate account:

```text
adm-kenneth
```

is used as an administrative identity.

I also created:

```text
GG-IT-Admins
```

as a dedicated Global Security Group for IT administrative identities.

The purpose of this design is to avoid using a privileged administrative identity for normal user activities.

This also gives me a foundation for learning more about least privilege and delegated Active Directory administration later in the project.

---

## Service Accounts

A dedicated `Service-Accounts` OU was created to keep service identities separate from normal employee and administrator accounts.

The OU is currently being kept available for services that genuinely require their own identities as the lab expands.

Future work in this area may include learning about:

- Traditional service accounts
- Managed Service Accounts (MSA)
- Group Managed Service Accounts (gMSA)
- Service permissions
- Password management for service identities

---

# PowerShell Automation

One of the main parts of Phase 1 was learning how PowerShell can be used to automate repetitive Active Directory administration.

I first created several employee accounts manually using Active Directory Users and Computers so that I understood the normal account creation process.

After understanding the manual process, I created a CSV-based PowerShell workflow to provision users automatically.

The employee CSV contains information such as:

```text
FirstName
LastName
Username
Department
JobTitle
OU
Group
```

The PowerShell script reads this information and creates the corresponding Active Directory accounts.

The automation performs tasks including:

1. Importing employee information from a CSV file
2. Checking whether an account already exists
3. Building the correct Organizational Unit path
4. Creating the Active Directory user
5. Setting the employee's first and last name
6. Configuring the username and User Principal Name
7. Setting the employee's department
8. Setting the employee's job title
9. Enabling the account
10. Assigning a temporary password
11. Requiring a password change at first logon
12. Adding the employee to the appropriate Global Security Group

Some of the PowerShell commands I worked with include:

```powershell
Import-Csv
```

```powershell
Get-ADUser
```

```powershell
New-ADUser
```

```powershell
Add-ADGroupMember
```

I also used `foreach` loops to process multiple employees from the CSV file.

This allowed me to create a large Active Directory user environment without manually creating every account.

---

# Windows 11 Domain Client

I created a Windows 11 Pro virtual machine to test the Active Directory environment from the client side.

Before joining the workstation to the domain, I configured it to use the internal Active Directory DNS server.

This allows the client to locate the `Egbowawa.local` domain and discover the Domain Controllers through DNS.

After confirming network and DNS connectivity, I joined the workstation to:

```text
Egbowawa.local
```

The computer object was then moved into the appropriate departmental computer OU instead of leaving it in the default Active Directory Computers container.

For example:

```text
Egbowawa-SmartHub
│
└── Computers
    │
    └── IT-Computers
        │
        └── IT-PC01
```

I then tested signing in to the workstation using Active Directory domain accounts.

---

## Authentication vs Authorization

While testing the domain-joined workstation, I noticed that users from different departments could sign in to the same domain-joined computer.

This helped me understand an important difference between authentication and authorization.

**Authentication** verifies the identity of the user.

For example:

```text
User enters domain credentials
        ↓
Domain Controller
        ↓
Active Directory verifies the user
        ↓
Authentication succeeds
```

**Authorization** determines what an authenticated user is allowed to access or do.

Simply placing an HR user inside the HR OU and a computer inside the HR Computers OU does not automatically mean that only HR users can sign in to that computer.

Those types of restrictions require additional configuration.

I plan to explore this further during the Group Policy and security phases of the project.

---

# DNS and Active Directory

DNS is an important part of the Active Directory environment.

The domain clients use the internal DNS service to locate Active Directory resources and Domain Controllers.

For example, a domain client can use DNS to locate services associated with:

```text
Egbowawa.local
```

and Active Directory service records such as:

```text
_ldap._tcp.dc._msdcs.Egbowawa.local
```

This part of the project helped me understand why DNS configuration is one of the first areas to check when a Windows client cannot locate or join an Active Directory domain.

I plan to expand the DNS configuration and troubleshooting documentation as the lab develops.

---

# Phase 1 Work Completed

During Phase 1, I completed the following:

- Built the `Egbowawa.local` Active Directory domain
- Created the `Egbowawa-SmartHub` OU structure
- Created departmental user OUs
- Created departmental computer OUs
- Created over 100 employee accounts
- Created Global Security Groups
- Assigned users to their appropriate departmental groups
- Created separate administrative identities
- Created the `GG-IT-Admins` administrative group
- Created a dedicated Service Accounts OU
- Used PowerShell to create Active Directory users
- Used CSV data for bulk user provisioning
- Automated security group membership
- Worked with Distinguished Names and OU paths
- Created a Windows 11 Pro domain client
- Configured internal DNS for the domain client
- Joined Windows 11 to `Egbowawa.local`
- Organized the domain computer object into its appropriate OU
- Tested Active Directory user authentication
- Worked with both Windows Server Desktop Experience and Windows Server Core
- Added `smarthub-core` as an additional Domain Controller

---

# Current Project Status

## Phase 1 — Active Directory Foundation

Phase 1 covers the initial Active Directory build, including OU design, users, security groups, PowerShell automation, Domain Controllers, replication, and the Windows 11 domain client.

[View Phase 1 Documentation](docs/phase-1-active-directory.md)

Additional documentation:

- [AD User Provisioning with PowerShell](docs/phase-1-user-automation.md)
- [Domain Controller Replication](docs/domain-controller-replication.md)

**Completed**

## Phase 2 — Group Policy Fundamentals

**In Progress**

Phase 2 will continue using the existing Egbowawa-SmartHub environment.

Instead of creating temporary users and computers specifically for Group Policy testing, I will use the existing departmental OUs, security groups, users, and domain-joined Windows clients to learn how Group Policy works in a more realistic environment.

---

# Skills Practiced

The project has given me hands-on practice with:

- Windows Server Administration
- Active Directory Domain Services (AD DS)
- Active Directory Users and Computers (ADUC)
- Domain Controllers
- Windows Server Core
- Organizational Units
- User Objects
- Computer Objects
- Global Security Groups
- Group Membership
- Administrative Account Separation
- Active Directory DNS
- Windows Domain Joining
- Domain Authentication
- Distinguished Names
- PowerShell
- Active Directory PowerShell Module
- CSV-based User Provisioning
- PowerShell Loops
- Active Directory Automation
- Basic Active Directory Troubleshooting

---

# Project Roadmap

Egbowawa-SmartHub will continue to grow as I learn additional Windows Server and infrastructure technologies.

Planned areas include:

- Group Policy
- Advanced DNS Administration
- DHCP
- File Server Administration
- NTFS Permissions
- Share Permissions
- AGDLP Permission Design
- PowerShell Automation
- Active Directory Replication
- FSMO Roles
- Active Directory Sites and Services
- Additional Domain Controller Management
- Delegated Administration
- Managed Service Accounts
- Group Managed Service Accounts
- Windows Server Security
- Backup and Recovery
- Network Segmentation
- VLANs
- Routing and Switching
- Firewall Administration
- Monitoring
- Hybrid Windows Server and Cloud Integration

The goal is to keep improving the same environment as my Windows Server, networking, and system administration knowledge develops.
