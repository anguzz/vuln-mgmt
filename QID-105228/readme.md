# QID-105228: Built-in Guest Account Not Renamed

## Overview
Qualys detected that the default **Guest** account on Windows endpoints had not been renamed.  
Even though the account was disabled, keeping its default name increases risk by exposing a known username, which can make brute force attacks easier.

## Risk
- Knowing a valid account name lowers the effort needed for brute force or password-spray attacks.
- While the account was disabled, leaving it with the default name meant the vulnerability continued to appear in scans.

## Intune Remediation
- Devices > Configurations > Create settings catalog
- Policy name: Rename guest account
- Applied a **Local Policies Security Options**:
  - **Accounts: Rename Guest Account**  
  - Renamed the built-in Guest account (even in its disabled state) to a non-standard label.

## Notes
- This change had no impact on users or services, since the account was already disabled.
- Renaming was a quick, low-impact way to remediate and maintain compliance.

