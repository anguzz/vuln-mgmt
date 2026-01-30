# MITRE ATT&CK T1059.001 (PowerShell) - PowerShell Execution Policy Hardening  

## Overview

Tanium reporting identified a subset of Windows endpoints running permissive PowerShell execution policies (`Bypass` or `Unrestricted`). These settings increase the risk of unauthorized or automatic script execution and are commonly abused in post-exploitation and defense-evasion scenarios.

This hardening initiative standardizes PowerShell execution policies to **RemoteSigned** (or **Restricted**, where required) across all managed endpoints using Tanium.

**Status:** Confirmed successful  
**Date:** 2026-01-29

---

## Background / Risk Context

PowerShell execution policies are not a security boundary, but they provide an important **defense-in-depth** control. Permissive policies such as `Bypass` and `Unrestricted` allow scripts to run without validation, increasing exposure to:

- Living-off-the-land (LOLBins) abuse  
- Unauthorized script execution  
- Malware and post-exploitation frameworks leveraging PowerShell  

This remediation helps reduce exposure to **MITRE ATT&CK T1059.001 (PowerShell)** by limiting how scripts are executed on endpoints.

---

## Discovery

### Tanium Question

**Question:**  
`Get PowerShell Effective Execution Policy from all entities`

This returns:
- PowerShell bitness (32-bit / 64-bit)
- Effective execution policy
- Endpoint count per policy

### Sample Output

| Bitness | Effective Policy | Count   |
|---------|------------------|---------|
| 32-bit  | RemoteSigned     | <count> |
| 64-bit  | RemoteSigned     | <count> |
| 32-bit  | Restricted       | <count> |
| 64-bit  | Restricted       | <count> |
| 32-bit  | Bypass           | <count> |
| 64-bit  | Bypass           | <count> |
| 32-bit  | Unrestricted     | <count> |
| 64-bit  | Unrestricted     | <count> |
| 32-bit  | AllSigned        | <count> |
| 64-bit  | AllSigned        | <count> |

Endpoints reporting `Bypass` or `Unrestricted` are in scope for remediation. Ensure you filter out any groups or devices after that have policy changed on purpose.


---

## Remediation Approach

Execution policies are enforced **at the machine scope** for both:

* 32-bit PowerShell
* 64-bit PowerShell

Remediation is deployed via a Tanium package to targeted endpoints only.

---

## Tanium Package Details

### Package Name

```
Enforce PowerShell Execution Policy - RemoteSigned
```

### Execution Command

```cmd
cmd.exe /c %windir%\SysNative\WindowsPowershell\v1.0\PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File Enforce-RemoteSigned.ps1
```

**Why SysNative:**
Ensures the script runs in **64-bit PowerShell** even though Tanium executes from a 32-bit context by default, allowing both registry hives to be enforced correctly.

---

## Enforcement Script (Enforce-RemoteSigned.ps1)

This script enforces the **RemoteSigned** PowerShell execution policy at the **LocalMachine** scope for both **64-bit** and **32-bit** Windows PowerShell. It is designed to run safely under **SYSTEM context** (e.g., via Tanium) and is idempotent.

### Key Behavior
- Checks the current LocalMachine execution policy per architecture
- Sets the policy to `RemoteSigned` if non-compliant
- Leaves already-compliant systems unchanged
- Logs current state and final verification for both architectures

### Scope & Compatibility
- **Scope:** LocalMachine  
- **Architectures:** 64-bit and 32-bit PowerShell  
- **Execution Context:** SYSTEM / Tanium-safe  
- **User Impact:** None

The script concludes with a verification step to confirm enforcement was successful across both PowerShell architectures.

> Note: The script intentionally launches with `-ExecutionPolicy Bypass` to ensure it can run even on systems currently set to restrictive policies.

---

## Verification / Detection Logic

### Tanium Verification Query

```sql
(
  ( PowerShell Effective Execution Policy:Bitness contains 32
    and PowerShell Effective Execution Policy:Effective Policy contains RemoteSigned )
  and
  ( PowerShell Effective Execution Policy:Bitness contains 64
    and PowerShell Effective Execution Policy:Effective Policy contains RemoteSigned )
)
```

Endpoints must report **RemoteSigned** for both 32-bit and 64-bit PowerShell to be considered compliant.

---

## Results / Outcome

* Eliminates permissive PowerShell execution policies across endpoints
* Reduces exposure to script-based execution and defense-evasion techniques
* Improves policy consistency across the environment
* Strengthens defense-in-depth alongside existing endpoint protections (e.g., EDR)

This change has no observed impact on endpoint stability or user workflows.

---

## Notes / Clarifications

* This change **does not** affect:

  * Windows Terminal
  * PowerShell profiles
  * `settings.json` or UI preferences
* Execution policy enforcement is independent of the terminal host (Windows Terminal, cmd.exe, VS Code, etc.)
* PowerShell 7+ follows the same policy enforcement when running on Windows

---

## References

* MITRE ATT&CK – PowerShell (T1059.001)
  [https://attack.mitre.org/techniques/T1059/001/](https://attack.mitre.org/techniques/T1059/001/)

* Microsoft – Set-ExecutionPolicy Documentation
  [https://learn.microsoft.com/powershell/module/microsoft.powershell.security/set-executionpolicy](https://learn.microsoft.com/powershell/module/microsoft.powershell.security/set-executionpolicy)

