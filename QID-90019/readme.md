### QID 90019 – LanMan/NTLMv1 Authentication Method Detected

**Overview:**  
LanMan (LM) and NTLMv1 are weak authentication methods deprecated since the late 1990s. If enabled, they allow password sniffing and offline cracking attacks. Microsoft introduced NTLMv2 in Windows NT 4.0 SP4 and made it the default authentication method starting with Windows 7 and Windows Server 2008 R2. Kerberos remains the preferred protocol in domain environments, but NTLMv2 is still used where Kerberos is not available.

**Impact:**  
Qualys detected a server allowing LM/NTLMv1 authentication. Left unpatched, this could enable network-level credential theft.  
- Affected systems: Windows Server.  
- Windows 10/11 endpoints already default to NTLMv2 and do not require policy changes.

**Remediation Approach:**  
The vulnerable server was remediated by enforcing NTLMv2-only authentication:  

- **LMCompatibilityLevel = 5** (*Send NTLMv2 response only. Refuse LM & NTLM*)  
- **NoLMHash = 1** (*Do not store LM hashes*)  

This was applied directly via local policy/registry update to close the finding.

For endpoints, the same setting is available in Intune via the **Settings Catalog** under *Local Policies → Security Options*:  
- **Network Security: LAN Manager authentication level**  
- **Network Security: Do not store LAN Manager hash value on next password change**  

However, since modern OS defaults already enforce NTLMv2, no additional Intune deployment was required for workstations.

**Default Values (per Microsoft documentation):**

| Policy Context                        | Default Value                 |
|--------------------------------------|-------------------------------|
| Stand-Alone Server Default            | Send NTLMv2 response only     |
| Domain Controller Effective Default   | Send NTLMv2 response only     |
| Member Server Effective Default       | Send NTLMv2 response only     |
| Client Computer Effective Default     | Send NTLMv2 response only     |

**Status:**  
- Vulnerable server remediated by enforcing NTLMv2-only authentication.  
- Endpoints already compliant by default. Intune policy available for consistency if required.

**References:**  
- [Microsoft – Network security: LAN Manager authentication level](https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-security-lan-manager-authentication-level)  
- [Microsoft – Do not store LAN Manager hash value on next password change](https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-security-do-not-store-lan-manager-hash-value-on-next-password-change)  
- [WOSHUB – How to Disable NTLM Authentication in Windows Domain (2024)](https://woshub.com/disable-ntlm-authentication-windows-domain)  
