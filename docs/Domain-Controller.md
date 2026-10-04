# Domain Controller and Replication Verification

## My Domain Controllers

My `Egbowawa.local` domain currently has two Domain Controllers:

- `SMARTHUB-DC`
- `SMARTHUB-CORE`

`SMARTHUB-DC` uses the Windows Server Desktop Experience, while `SMARTHUB-CORE` is running Windows Server Core.

I added the second Domain Controller as part of the lab so I could get experience working with more than one DC and learn how Active Directory replication works.

## Checking the Domain Controllers

I used PowerShell to check the Domain Controllers currently available in the domain:

```powershell
Get-ADDomainController -Filter * |
Select-Object HostName,IPv4Address,Site,IsGlobalCatalog
```

This allowed me to verify that both `SMARTHUB-DC` and `SMARTHUB-CORE` were recognized as Domain Controllers in `Egbowawa.local`.

## Checking Active Directory Replication

I used the following command to check the replication status:

```powershell
repadmin /replsummary
```

The replication summary showed:

```text
Source DSA       Fails/Total
SMARTHUB-CORE       0 / 5
SMARTHUB-DC         0 / 5
```

The destination summary also reported zero failures.

At the time of testing, there were no replication failures reported between my Domain Controllers.

## What I Learned

Before setting up the second DC, I understood that a Domain Controller stores Active Directory information, but working with two DCs helped me understand why replication is important.

If I create or modify an Active Directory object through one Domain Controller, the directory changes need to be replicated to the other Domain Controller.

For example:

```text
Create user on SMARTHUB-DC
           ↓
Active Directory change
           ↓
       Replication
           ↓
SMARTHUB-CORE receives the change
```

I also learned that having two Domain Controllers does not automatically mean I should assume replication is working. I need to verify it.

`repadmin /replsummary` gives me a quick way to check the overall replication health, while `repadmin /showrepl` can provide more detailed information about replication partners and individual replication attempts.

This is an area I plan to explore further as I learn more about Active Directory replication, DNS, Sites and Services, and FSMO roles.
