
# **SMBv1 Remediation – QID 379223**

*Disable SMBv1 Protocol Across Windows Endpoints (Intune + Tanium)*

This document covers the **Qualys finding QID 379223**, background information on SMBv1 risks, and the remediation approach using **ADMX-backed Intune policies** plus a **PowerShell enforcement script**.


## **Overview**

**QID 379223 — Windows SMB Version 1 (SMBv1) Detected**
Qualys is reporting that several Windows endpoints still have SMBv1 enabled. SMBv1 has been deprecated by Microsoft for years and remains one of the **highest-risk ransomware exploit vectors** due to legacy protocol weaknesses (e.g., EternalBlue-class attacks).

This remediation consists of:

* **ADMX-backed Intune configuration** to block SMBv1 usage at the driver level
* **PowerShell enforcement** to disable or remove any remaining SMBv1 Windows Optional Features
* Validation using **Tanium** to confirm removal of all related SMB1 components


## **Background / Vulnerability Description**

| Item                 | Details                                                                                                                         |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **CVE Impact**       | SMBv1 has been tied to multiple wormable exploits, including EternalBlue (WannaCry), NotPetya, and various ransomware families. |
| **Qualys Detection** | QID **379223 – Windows SMB Version 1 Detected**                                                                                 |
| **Severity**         | **High to Critical** (varies by scanner profile)                                                                                   |
| **Attack Surface**   | Legacy file sharing protocol allowing remote code execution, lateral movement, and ransomware propagation.                      |
| **Vendor Position**  | Microsoft has deprecated SMBv1 since ~2017 and removed it by default starting Windows 10 1709 / Server 2016+.                   |


## **Observed Behavior**

Qualys reports SMBv1 as active across multiple endpoints:

* **QID 379223 – SMBv1 Detected**
* Some devices still had SMB1 optional features installed
* Some devices showed SMBv1 driver/runtime enabled via ADMX-related registry paths



## **Intune ADMX Configuration**

Intune’s **MS Security Guide (ADMX-backed)** policy is configured to block SMBv1 for both client and server drivers.

#### **Configuration Values**

| Setting                            | Policy Name                | Registry Path                                                         | Expected Value |
| ---------------------------------- | -------------------------- | --------------------------------------------------------------------- | -------------- |
| **Configure SMB v1 Server**        | ConfigureSMBV1Server       | `HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters\SMB1` | `0`            |
| **Configure SMB v1 Client Driver** | ConfigureSMBV1ClientDriver | `HKLM\SYSTEM\CurrentControlSet\Services\mrxsmb10\Start`               | `4` (Disabled) |

**Important Notes**

* `Start = 3` = manual start (still allowed; **not secure**)
* `Start = 4` = **fully disabled**
* These ADMX policies prevent the SMBv1 client/server drivers from loading at boot.


## **Registry Validation**

Expected registry state:

```reg
HKLM\System\CurrentControlSet\Services\LanmanServer\Parameters\SMB1 = 0
HKLM\System\CurrentControlSet\Services\mrxsmb10\Start = 4
```

Any deviations indicate SMBv1 is still enabled or partially installed.



## **Tanium Findings**

Using the Tanium sensor **Get Windows Features**, searching for “SMB1” identified endpoints with these installed components:

* `SMB1Protocol` (parent feature)
* `SMB1Protocol-Client`
* `SMB1Protocol-Server`
* `SMB1Protocol-Deprecation` (wrapper for legacy support)

If any of these are present/enabled, Windows still considers SMB1 partially available.


## **Remediation Script (`disable.ps1`)**

This script:

* Disables SMBv1 server driver (`Set-SmbServerConfiguration`)
* Removes all SMBv1 Windows Optional Features
* Works safely in **Tanium**, **Intune remediation**, or **on-demand execution**
* Suppresses restart

### **Script Output Example**

```powershell
 .\disable.ps1
=== Disabling SMBv1 ===
SMBv1 server protocol disabled.
WARNING: Restart is suppressed because NoRestart is specified.


Path          :
Online        : True
RestartNeeded : True

Disabled feature: SMB1Protocol
WARNING: Restart is suppressed because NoRestart is specified.
Path          :
Online        : True
RestartNeeded : True

Disabled feature: SMB1Protocol-Client
WARNING: Restart is suppressed because NoRestart is specified.
Path          :
Online        : True
RestartNeeded : True

Disabled feature: SMB1Protocol-Server
WARNING: Restart is suppressed because NoRestart is specified.
Path          :
Online        : True
RestartNeeded : True

Disabled feature: SMB1Protocol-Deprecation
=== SMBv1 disable complete (restart may be required) ===
```


# **Deployment Steps (Intune)**

### **Remediation Package**

* **Detection Script:** Check for SMBv1 driver or features
* **Remediation Script:** `disable.ps1`
* Configure restart behavior policy as needed

---

# **Deployment Steps (Tanium)**

1. Upload `disable.ps1` as an **Action** or **Package**
2. Target using:

   ```
   Get Windows Features from all entities with Windows Features contains SMB1
   ```
3. Deploy as:

   * **Once** to remove existing SMBv1
   * **Recurring** for enforcement (optional)

---

# **Outcome**

After rollout:

* Qualys QID 379223 should drop from affected endpoints
* Tanium Windows Features should show **all SMB1 features removed/disabled**
* ADMX-backed Intune configuration ensures continued prevention of SMBv1 loading
* Ransomware lateral movement vector significantly reduced

---

# **References**

* MS Security Guide CSP
  [https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-mssecurityguide](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-mssecurityguide)
* Stop Using SMB1
  [https://techcommunity.microsoft.com/blog/filecab/stop-using-smb1/425858](https://techcommunity.microsoft.com/blog/filecab/stop-using-smb1/425858)
* Detect / Disable SMBv1
  [https://learn.microsoft.com/en-us/windows-server/storage/file-server/troubleshoot/detect-enable-and-disable-smbv1-v2-v3](https://learn.microsoft.com/en-us/windows-server/storage/file-server/troubleshoot/detect-enable-and-disable-smbv1-v2-v3)
* SMBv1 removed by default
  [https://learn.microsoft.com/en-us/windows-server/storage/file-server/troubleshoot/smbv1-not-installed-by-default-in-windows](https://learn.microsoft.com/en-us/windows-server/storage/file-server/troubleshoot/smbv1-not-installed-by-default-in-windows)
* INF AddService reference (driver start types)
  [https://learn.microsoft.com/en-us/windows-hardware/drivers/install/inf-addservice-directive](https://learn.microsoft.com/en-us/windows-hardware/drivers/install/inf-addservice-directive)

