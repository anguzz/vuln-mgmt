# Enforce PowerShell Execution Policy to RemoteSigned
# Applies to 64-bit and 32-bit Windows PowerShell
# Scope: LocalMachine
# Safe for Tanium / SYSTEM execution

$DesiredPolicy = 'RemoteSigned'
$LogPrefix = '[ExecutionPolicy]'

function Set-Policy {
    param (
        [string]$PowerShellPath,
        [string]$Architecture
    )

    if (Test-Path $PowerShellPath) {
        try {
            $CurrentPolicy = & $PowerShellPath -NoProfile -Command "Get-ExecutionPolicy -Scope LocalMachine"
            Write-Output "$LogPrefix $Architecture current policy: $CurrentPolicy"

            if ($CurrentPolicy -ne $DesiredPolicy) {
                & $PowerShellPath -NoProfile -Command "Set-ExecutionPolicy -ExecutionPolicy $DesiredPolicy -Scope LocalMachine -Force"
                Write-Output "$LogPrefix $Architecture policy set to $DesiredPolicy"
            } else {
                Write-Output "$LogPrefix $Architecture policy already compliant"
            }
        }
        catch {
            Write-Error "$LogPrefix $Architecture failed: $_"
        }
    }
    else {
        Write-Output "$LogPrefix $Architecture PowerShell not found"
    }
}

# 64-bit PowerShell
Set-Policy -PowerShellPath "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -Architecture "64-bit"

# 32-bit PowerShell
Set-Policy -PowerShellPath "$env:WINDIR\SysWOW64\WindowsPowerShell\v1.0\powershell.exe" -Architecture "32-bit"

# Final verification
$Final64 = & "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -Command "Get-ExecutionPolicy -Scope LocalMachine"
$Final32 = & "$env:WINDIR\SysWOW64\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -Command "Get-ExecutionPolicy -Scope LocalMachine"

Write-Output "$LogPrefix Final 64-bit policy: $Final64"
Write-Output "$LogPrefix Final 32-bit policy: $Final32"
