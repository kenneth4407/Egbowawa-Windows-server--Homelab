# Phase 1 - Active Directory User Automation

## Why I Automated User Creation

When I started building Egbowawa-SmartHub, I created some of the Active Directory users manually through Active Directory Users and Computers (ADUC).

This was useful at the beginning because I wanted to understand the normal process of creating a user, selecting an OU, setting account information, and adding the user to a security group.

Once I understood the manual process, creating over 100 users one at a time did not make much sense. I decided to use a CSV file and PowerShell to automate the rest of the user creation.

## CSV Structure

I created an `Employee.csv` file containing the information PowerShell would need for each employee.

The columns I used were:

```text
FirstName
LastName
Username
Department
JobTitle
OU
Group
```

For example:

```csv
FirstName,LastName,Username,Department,JobTitle,OU,Group
Ovie,Okoro,ovie.okoro,IT,Systems Administrator,IT,GG-IT-Users
Efe,Edewor,efe.edewor,IT,Network Administrator,IT,GG-IT-Users
```

This allowed me to keep the employee information separate from the PowerShell code.

## Reading the CSV with PowerShell

I used:

```powershell
Import-Csv
```

to import the employee information into PowerShell.

I then used a `foreach` loop so that PowerShell could process each employee in the CSV individually.

The basic idea was:

```text
Read employee
      ↓
Check the username
      ↓
Find the correct OU
      ↓
Create the account
      ↓
Add the account to the correct group
      ↓
Move to the next employee
```

## Checking for Existing Users

One thing I wanted the script to handle was an account that already existed.

I used:

```powershell
Get-ADUser
```

to search for the `SamAccountName` before creating the account.

If the username already exists, the script skips that employee instead of trying to create the same account again.

This became useful when testing the script because I could run it again without intentionally recreating users that had already been created.

## Validating the OU

The CSV contains the department OU for each employee.

The script builds the user's Distinguished Name from that information.

For example:

```text
OU=IT,OU=Users,OU=Egbowawa-SmartHub,DC=egbowawa,DC=local
```

Before creating the user, I use:

```powershell
Get-ADOrganizationalUnit
```

to check that the OU actually exists.

If the OU name in the CSV is wrong, the script reports the problem and moves to the next employee.

Working with this helped me understand Distinguished Names better and how PowerShell identifies locations inside Active Directory.

## Validating Security Groups

I also wanted to make sure that the security group listed in the CSV existed before creating the user.

I used:

```powershell
Get-ADGroup
```

for this check.

For example, an IT employee may have:

```text
GG-IT-Users
```

in the Group column.

If that group cannot be found, the script reports the error instead of continuing with that record.

## Creating the User

Once the checks pass, the script uses:

```powershell
New-ADUser
```

to create the account.

The script sets information including:

- First name
- Last name
- Display name
- `SamAccountName`
- User Principal Name (UPN)
- Department
- Job title
- Company
- OU location
- Temporary password

The account is enabled during creation and the user is required to change the temporary password at first logon.

## Password Handling

I did not put the temporary password directly inside the script.

Instead, the script asks for it when it starts:

```powershell
Read-Host "Enter temporary password for new users" -AsSecureString
```

This means the password is not saved as plain text inside the PowerShell script that I upload to GitHub.

## Adding Users to Groups

After creating an account, I use:

```powershell
Add-ADGroupMember
```

to add the employee to the Global Security Group specified in the CSV.

For example:

```text
Lucas Martin
     ↓
IT OU
     ↓
GG-IT-Users
```

I originally learned that putting a user inside the IT OU does not automatically make that user a member of `GG-IT-Users`.

The OU is used to organize and manage Active Directory objects, while the security group is used for membership and can later be used when assigning access to resources.

## Error Handling

I used `try` and `catch` blocks around some of the operations.

This allows the script to report an error without stopping the entire bulk creation process.

For example, if one employee has an invalid OU, the script can report that employee and continue processing the remaining records.

I also used:

```powershell
-ErrorAction Stop
```

with the commands inside the `try` blocks so that PowerShell sends the error to the corresponding `catch` block.

## Commands I Practiced

The main PowerShell commands and concepts I used during this part of the project were:

```powershell
Import-Module
Join-Path
Test-Path
Import-Csv
foreach
Get-ADUser
Get-ADOrganizationalUnit
Get-ADGroup
New-ADUser
Add-ADGroupMember
try
catch
continue
```

The most useful part of this exercise for me was seeing how the manual Active Directory tasks I had already learned could be turned into a repeatable PowerShell process.

Instead of only learning the commands separately, I used them together to solve an actual problem in my lab.
