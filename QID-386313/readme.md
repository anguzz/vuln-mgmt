# Qualys – QID 386313: Notepad++ Updater Hijacking Vulnerability

## Summary

Qualys has identified a **Notepad++ Updater Hijacking Vulnerability** (QID **386313**) affecting **several thousand endpoints**.
Affected versions include **Notepad++ prior to the fixed release**, where the **WinGUP updater** can be hijacked to deliver malicious installers.

There is **no vendor-side mitigation** other than upgrading to a fixed version or removing the application entirely.

---

## Action Plan

To reduce attack surface exposure, Notepad++ will be removed from endpoints where it is **not actively used**.

### Proposed Remediation

**Intune**

* Unassign Notepad++ from all *Required* deployments
* Re-publish Notepad++ as *Optional / Available*

**Tanium**

* Use the **Unused Software (Asset SIU)** report to identify endpoints not actively using Notepad++
* Remove Notepad++ from those endpoints via Tanium
* Keep Notepad++ available through **Tanium Self Service** for users with a business need

---

## Risk Reduction

This approach significantly reduces vulnerability exposure while preserving access for users who require Notepad++ for business purposes.

---

## Tanium Targeting Queries

### Interact – Usage Discovery

```sql
Get Computer Name and Asset SIU Product Usage having Asset SIU Product Usage:Name contains Notepad++ from all entities with Asset SIU Product Usage:Name contains Notepad++
```

Sample results:

| Computer Name | Vendor         | Name      | Last Used Date     | Usage   | Schema Version |
| ------------- | -------------- | --------- | ------------------ | ------- | -------------- |
| WORKSTATION-A | Notepad++ Team | Notepad++ | Usage not detected | 1       |                |
| WORKSTATION-B | Notepad++ Team | Notepad++ | Recent             | Limited | 1              |

---

### Targeting Unused Installations

```sql
Get Asset SIU Product Usage having Asset SIU Product Usage:Name contains Notepad++ from all entities with Asset SIU Product Usage:Usage equals "Usage not detected"
```

Returned fields:

| Vendor         | Name      | Last Used Date | Usage              | Schema Version | Count    |
| -------------- | --------- | -------------- | ------------------ | -------------- | -------- |
| Notepad++ Team | Notepad++ |                | Usage not detected | 1              | Majority |
| Notepad++ Team | Notepad++ |                | Not installed      | 1              | Minor    |

The **“Usage not detected”** row is used as the deployment target for the removal package.

---

## Tanium Cleanup Script

* `remove.ps1` removes both **EXE** and **MSI** installations of Notepad++

### Tanium Upload Details

* **Package name:** `Qualys - QID 386313 Notepad++ hygiene`
* **Execution command:**

  ```
  cmd.exe /c powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NonInteractive -NoProfile -File remove.ps1
  ```
* **Verification query:**

  ```
  Installed Applications not contains "Notepad++"
  ```
* **Results:** Successfully removed Notepad++ across the targeted endpoint population

---

## Notes

**Usage field values observed:**

* High
* Normal
* Limited
* Usage not detected
* No data returned

---
