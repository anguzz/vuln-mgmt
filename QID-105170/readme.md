# Vulnerability Remediation: Disable AutoPlay (QID 105170)

**Detection Source:** Qualys  
**Vulnerability ID:** QID 105170  
**Issue:** Microsoft Windows Explorer AutoPlay not disabled  
**Impact:** Increases risk of malware execution from removable media.  

---

## Existing Safeguards
- **EDR Enforcement:** Removable media usage is already restricted at the endpoint level via the organization’s EDR platform (e.g., CrowdStrike).  
- This prevents malicious code from executing via USB or external drives.  

---

## Remediation Approach
To address compliance findings and reduce vulnerability counts in Qualys:

1. **Testing Phase**  
   - Deployed a configuration profile using the **Intune Settings Catalog**.  
   - Applied the **NoDriveTypeAutoRun** policy to a pilot test group.  
   - Disabled AutoPlay on all drives, further hardening endpoints.  

2. **Monitoring**  
   - Observed pilot endpoints for any functional issues.  
   - No impact detected (e.g., removable media workflows already blocked by EDR).  

3. **Rollout**  
   - Phased rollout extended to all managed endpoints.  
   - Ensured alignment between vulnerability management (Qualys), endpoint hardening (Intune), and threat prevention (EDR).  

---

## Outcome
- Successfully mitigated **QID 105170** by enforcing the “Disable AutoPlay” setting via Intune.  
- Reduced vulnerability findings across the fleet while maintaining operational stability.  
- Documented layered defense: **EDR + Intune policy** to address both real-world threats and compliance requirements.  
