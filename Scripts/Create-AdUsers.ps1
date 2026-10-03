# =====================================================================
# Egbowawa-SmartHub - Bulk Active Directory User Creation
# =====================================================================
#
# Purpose:
# Creates Active Directory user accounts from a CSV file and places
# each user in the appropriate departmental OU and security group.
#
# Domain: Egbowawa.local
# Environment: Egbowawa-SmartHub
#
# Requirements:
# - Active Directory PowerShell module
# - Permission to create users and modify group membership
# - Employee.csv located in the same directory as this script
#
# =====================================================================

Import-Module ActiveDirectory

# Build the path to Employee.csv.
# $PSScriptRoot represents the folder containing this script.
$CsvPath = Join-Path $PSScriptRoot "Employee.csv"

# Verify that the CSV exists before continuing.
if (-not (Test-Path $CsvPath)) {
    Write-Host "[ERROR] Cannot find CSV file: $CsvPath"
    exit
}

# Import employee information from the CSV.
$Users = Import-Csv $CsvPath

# Request a temporary password without storing it as plain text
# inside the script.
$Password = Read-Host "Enter temporary password for new users" -AsSecureString

# Process each employee in the CSV.
foreach ($User in $Users) {

    # Read and clean employee information.
    $Username  = $User.Username.Trim()
    $FirstName = $User.FirstName.Trim()
    $LastName  = $User.LastName.Trim()
    $FullName  = "$FirstName $LastName"
    $GroupName = $User.Group.Trim()

    # Create the user's User Principal Name (UPN).
    $UPN = "$Username@egbowawa.local"

    # Build the Distinguished Name of the user's departmental OU.
    $OUPath = "OU=$($User.OU.Trim()),OU=Users,OU=Egbowawa-SmartHub,DC=egbowawa,DC=local"

    Write-Host ""
    Write-Host "---------------------------------------------"
    Write-Host "Processing: $FullName"
    Write-Host "Username:   $Username"
    Write-Host "OU:         $OUPath"
    Write-Host "Group:      $GroupName"
    Write-Host "---------------------------------------------"

    # Check whether an account with this username already exists.
    $ExistingUser = Get-ADUser `
        -Filter "SamAccountName -eq '$Username'" `
        -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Host "[SKIPPED] $Username already exists."
        continue
    }

    # Verify that the destination OU exists.
    try {
        Get-ADOrganizationalUnit `
            -Identity $OUPath `
            -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Host "[ERROR] OU does not exist:"
        Write-Host $OUPath
        continue
    }

    # Verify that the departmental security group exists.
    try {
        Get-ADGroup `
            -Identity $GroupName `
            -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Host "[ERROR] Group does not exist: $GroupName"
        continue
    }

    # Create the Active Directory user account.
    try {
        New-ADUser `
            -Name $FullName `
            -GivenName $FirstName `
            -Surname $LastName `
            -DisplayName $FullName `
            -SamAccountName $Username `
            -UserPrincipalName $UPN `
            -Department $User.Department `
            -Title $User.JobTitle `
            -Company "Egbowawa SmartHub" `
            -Path $OUPath `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -ErrorAction Stop

        Write-Host "[SUCCESS] Created user: $FullName"
    }
    catch {
        Write-Host "[ERROR] Failed to create $FullName"
        Write-Host $_.Exception.Message
        continue
    }

    # Add the new account to its departmental Global Security Group.
    try {
        Add-ADGroupMember `
            -Identity $GroupName `
            -Members $Username `
            -ErrorAction Stop

        Write-Host "[SUCCESS] Added $Username to $GroupName"
    }
    catch {
        Write-Host "[WARNING] User created, but group membership failed."
        Write-Host $_.Exception.Message
        continue
    }

    Write-Host "[COMPLETE] $FullName successfully configured."
}

Write-Host ""
Write-Host "============================================="
Write-Host "Bulk user creation process finished."
Write-Host "============================================="
