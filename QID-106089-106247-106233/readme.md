# QID 106089 / 106247 / 106233 – Removal of End-of-Life .NET 5, 6, and 7 Runtimes

## Overview

These three Qualys detections identify **unsupported Microsoft .NET Core runtimes** that have reached end-of-life:

| QID        | Product            | Status                 | Detection Summary                                          |
| ---------- | ------------------ | ---------------------- | ---------------------------------------------------------- |
| **106089** | Microsoft .NET 5.x | EOL – May 10 2022       | *EOL/Obsolete Software: Microsoft .NET Version 5 Detected* |
| **106247** | Microsoft .NET 6.x | EOL – November 12 2024 | *EOL/Obsolete Software: Microsoft .NET Version 6 Detected* |
| **106233** | Microsoft .NET 7.x | EOL – May 14 2024      | *EOL/Obsolete Software: Microsoft .NET Version 7 Detected* |

Unsupported runtimes no longer receive security updates, leaving applications that depend on them vulnerable to remote code execution and memory corruption risks.



## Background / Vulnerability Description

| Attribute            | Details                                                                                         |
| -------------------- | ----------------------------------------------------------------------------------------------- |
| **Vendor**           | Microsoft                                                                                       |
| **Detection Source** | Qualys Cloud Agent                                                                              |
| **Category**         | End-of-Life / Obsolete Software                                                                 |
| **Threat Surface**   | Application runtime layer (.NET Core / Desktop runtimes)                                        |
| **Risk Description** | EOL .NET versions no longer receive patches, exposing endpoints to unmitigated vulnerabilities. |
| **Severity**         | Medium – Compliance / Security Exposure                                                         |

**Support Lifecycle:**

* .NET 5 → End of Support May 8 2022
* .NET 6 → End of Support November 12 2024
* .NET 7 → End of Support May 14 2025

Microsoft recommends upgrading all endpoints to **.NET 8**, or newer supported releases.

---



## Script Behavior – `remove.ps1`

1. **Discovery**
   Enumerates both x86 and x64 registry uninstall keys:

   * `HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall`
   * `HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall`

2. **Target Matching**
   Detects entries matching any of the following patterns:

   ```
   Microsoft .NET Runtime - 5.*
   Microsoft Windows Desktop Runtime - 5.*
   Microsoft .NET Host - 5.*
   Microsoft .NET Host FX Resolver - 5.*
   Microsoft .NET Runtime - 6.*
   Microsoft Windows Desktop Runtime - 6.*
   ...
   Microsoft .NET Runtime - 7.*
   Microsoft Windows Desktop Runtime - 7.*
   ```

3. **Uninstallation**
   Executes `msiexec /X {GUID} /quiet /norestart` for each match.

4. **Cleanup**
   Removes stale registry entries and deletes residual folders under:

   ```
   C:\Program Files\dotnet\shared\Microsoft.NETCore.App\5.*  
   C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\5.*  
   C:\Program Files\dotnet\shared\Microsoft.NETCore.App\6.*  
   C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\6.*  
   C:\Program Files\dotnet\shared\Microsoft.NETCore.App\7.*  
   C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\7.*  
   ```

5. **Validation**
   Runs `dotnet --list-runtimes` and verifies that no 5.x, 6.x, or 7.x runtimes remain.

6. **Logging**
   Outputs a detailed transcript to:

   ```
   C:\Logs\Remove-DOTNET\logRemoval.txt
   ```

---

## Correction Notes / Special Considerations

* Script is **idempotent** – safe to rerun; exits cleanly if no target runtimes are found.
* Requires **SYSTEM** or **local administrator** context.
* **No reboot required.**
* Designed for **Windows 10/11 x64** endpoints managed by Intune or Tanium.
* Recommended to install **.NET 8 LTS** prior to removal if applications depend on older versions.
* Script can be extended for Tanium Package or Intune Remediation deployment.

---




## Deployment Plan

| Phase              | Description                                                                                |
| ------------------ | ------------------------------------------------------------------------------------------ |
| **Pilot**          | Deploy to  ring group (Ring 0). Monitor for app compatibility issues.                      |
| **Validation**     | Confirm Qualys QIDs 106089, 106247, and 106233 total count decrease fter 24–48 hours.      |
| **Global Rollout** | Expand deployment to remaining Intune device groups.                                       |
| **Monitoring**     | Validate through Graph API output (`DOTNET6.csv`) and Qualys compliance dashboards.        |

---

## Research Notes

* **Backward Compatibility:** .NET 8 is backward compatible with most apps built on .NET 6/7.
* **Risk of Non-Remediation:** Leaving EOL runtimes installed exposes systems to unpatched CVE chains targeting serialization and runtime parsing functions.
* **Performance:** Negligible impact; no system reboots required.

---

## Outcome

 Legacy .NET runtimes (5.x / 6.x / 7.x) fully removed.
 Qualys QIDs 106089, 106247, and 106233 closed post-remediation.
 Standardized EOL runtime removal process now available in repo for future detections.

---

## References

* [Microsoft .NET Lifecycle Policy](https://learn.microsoft.com/en-us/lifecycle/products/microsoft-net-and-net-core)


