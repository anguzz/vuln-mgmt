<#
.SYNOPSIS
    Force disable SMBv1 (server + all optional features) unconditionally.
    Designed for Tanium / Intune remediation.
#>

Write-Host "=== Disabling SMBv1 ==="

try {
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
    Write-Host "SMBv1 server protocol disabled."
}
catch {
    Write-Warning "Failed to disable SMBv1 server protocol: $_"
}

# SMBv1 feature names
$features = @(
    "SMB1Protocol",
    "SMB1Protocol-Client",
    "SMB1Protocol-Server",
    "SMB1Protocol-Deprecation"
)

# disables all SMBv1 optional features
foreach ($feature in $features) {
    try {
        Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction Stop
        Write-Host "Disabled feature: $feature"
    }
    catch {
        Write-Warning "Failed or already disabled: $feature"
    }
}

Write-Host "=== SMBv1 disable complete (restart may be required) ==="
exit 0
