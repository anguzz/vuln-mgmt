# Qualys QIDs 375602 -380172 -383395  – Citrix Workspace Removal

## Overview

**Qualys QIDs:** 375602, 
**Affected Software:** Citrix Workspace (notably 18.12 / 1812, but behavior observed across versions)  
**Environment:** FBM Windows workstations, Tanium-managed

These Qualys findings flag vulnerable or unsupported versions of Citrix Workspace. Standard uninstall mechanisms fail in non-interactive execution contexts (Tanium, SYSTEM), causing remediation attempts to hang or error. A different removal approach is required.


## Background / Vulnerability Description

- **Product:** Citrix Workspace  
- **Vendor:** Citrix Systems, Inc 
- **Issue Type:** Unsupported / vulnerable application versions detected by Qualys  
- **Severity:** Medium–High (per Qualys policy; dependent on exploitability and environment)

### Attack Surface / Risk

- Legacy Citrix Workspace versions include outdated components (e.g., ICA/XenApp Web Plugin).
- Failed removal leaves endpoints non-compliant and repeatedly alerting in Qualys.
- Hung uninstall processes can stall Tanium deployments and remediation workflows.


## Observed Behavior & Failure Analysis

### Standard Uninstall Strings (Detected by Tanium)

- **Older versions (≤ 18.x / 1812):**
```

C:\ProgramData\Citrix\Citrix Workspace <version>\TrolleyExpress.exe /uninstall /cleanup

```

- **Newer versions (25.x+):**
```

"C:\Program Files (x86)\Citrix\Citrix Workspace <version>\bootstrapperhelper.exe" /uninstall /cleanup

```

### What Failed

- Direct execution of uninstall strings via Tanium.
- Registry-based MSI uninstall attempts (both 32-bit and 64-bit paths).
- Highly defensive / “robust” PowerShell uninstall logic.
- Third-party removal via Revo Uninstaller (used for validation).

### Root Cause

Revo surfaced the underlying issue:

```

The standard uninstaller is hitting a 1603 Fatal Error while trying to remove
the XenApp Web Plugin (ICA_Client) component.

This triggers a hidden Windows Installer dialog:
"There is a problem with this Windows Installer package".

````



**Key takeaway:**  

Because Tanium runs in a non-interactive SYSTEM session, it cannot click "OK".
The process hangs until timeout or failure.

Any uninstall path that invokes MSI logic requiring user interaction will fail silently or hang under SYSTEM.


## Correction Notes / Special Considerations

- This is **not** a Tanium scripting issue.
- This is **not** resolvable via MSIEXEC switches or registry discovery.
- The failure is caused by a **hidden modal dialog** that cannot be dismissed in non-interactive sessions.
- Citrix’s own cleanup tooling is required.


## Remediation / Installation Instructions

### Approved Remediation Method: Citrix Receiver Cleanup Utility

**Utility:** Receiver Cleanup Utility (official Citrix tool)  
**Source:**  
https://support.citrix.com/external/article/CTX137494/receiver-cleanup-utility.html

### Successful Uninstall Command

```cmd
cmd.exe /c "C:\ProgramData\Citrix\Citrix Workspace 1812\ReceiverCleanupUtility.exe" /silent
````

* Executes fully non-interactively
* Successfully removes Citrix Workspace and related components
* Resolves Qualys detections for QIDs 375602, 390172, 393395


## Tanium Deployment Details

### Targeting / Query

* **Base Query:**
  `Get Installed Applications from all entities`
* **Filters:**

  * Application contains: `Citrix Workspace`
  * Version: `1812` (or broader as needed)
  * Device scope: FBM workstations

### Package Name

**Qualys QIDs 375602 390172 393395 – Remove Citrix 1812**

### Verification Query

```text
Installed Applications does not contain "Citrix Workspace"
```



## Deployment Steps

1. Use the existing `ReceiverCleanupUtility.exe` already staged on the endpoint as part of the Citrix Workspace base install.
2. Deploy the Tanium package using the SYSTEM context.
3. Pilot the deployment on a small subset of affected FBM workstations.
4. Confirm:
   - Citrix Workspace is no longer present
   - No hung actions or timeouts observed
   - Qualys detections clear on the next scan
5. Expand the deployment to the full affected population.


## Outcome

* Citrix Workspace successfully removed where standard uninstall methods failed.
* Qualys QIDs 375602, 390172, 393395 remediated.
* No interactive prompts or hung Tanium actions.
* Endpoint compliance restored.


## References

* Citrix Receiver Cleanup Utility (CTX137494)
  [https://support.citrix.com/external/article/CTX137494/receiver-cleanup-utility.html](https://support.citrix.com/external/article/CTX137494/receiver-cleanup-utility.html)


- **QID 375602** – Citrix Workspace Privilege Escalation Vulnerability  
  Advisory: CTX307794  
  CVE: https://nvd.nist.gov/vuln/detail/CVE-2021-22907

- **QID 380172** – Citrix Workspace App for Windows Privilege Escalation Vulnerability  
  Advisory: CTX678036  
  CVE: https://nvd.nist.gov/vuln/detail/CVE-2024-6286

- **QID 383395** – Citrix Workspace App for Windows Local Privilege Escalation Vulnerability  
  Advisory: CTX694718  
  CVE: https://nvd.nist.gov/vuln/detail/CVE-2025-4879