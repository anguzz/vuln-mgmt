# Notepad++ Silent Uninstall (EXE + MSI)
# Safe for Intune / Tanium remediation

$LogPath = "C:\Windows\Temp\NotepadPlusPlus_Uninstall.log"

function Write-Log {
    param ($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogPath -Append -Encoding UTF8
}

Write-Log "Starting Notepad++ uninstall remediation."

# -----------------------------
# 1. EXE-based uninstall
# -----------------------------
$ExeUninstallPaths = @(
    "C:\Program Files\Notepad++\uninstall.exe",
    "C:\Program Files (x86)\Notepad++\uninstall.exe"
)

foreach ($Path in $ExeUninstallPaths) {
    if (Test-Path $Path) {
        Write-Log "Found EXE uninstaller: $Path"

        try {
            $proc = Start-Process `
                -FilePath $Path `
                -ArgumentList "/S" `
                -Wait `
                -PassThru `
                -WindowStyle Hidden

            Write-Log "EXE uninstall exit code: $($proc.ExitCode)"
        }
        catch {
            Write-Log "ERROR running EXE uninstaller: $_"
        }
    }
}

# -----------------------------
# 2. MSI-based uninstall
# -----------------------------
$RegistryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($RegPath in $RegistryPaths) {
    if (-not (Test-Path $RegPath)) { continue }

    Get-ChildItem $RegPath | ForEach-Object {
        try {
            $App = Get-ItemProperty $_.PsPath -ErrorAction Stop

            if ($App.DisplayName -and $App.DisplayName -like "Notepad++*") {
                $ProductCode = $_.PSChildName

                if ($ProductCode -match "^\{.*\}$") {
                    Write-Log "Found MSI install: $($App.DisplayName) ($ProductCode)"

                    $proc = Start-Process `
                        -FilePath "msiexec.exe" `
                        -ArgumentList "/x $ProductCode /qn /norestart" `
                        -Wait `
                        -PassThru `
                        -WindowStyle Hidden

                    Write-Log "MSI uninstall exit code: $($proc.ExitCode)"
                }
            }
        }
        catch {
            Write-Log "ERROR reading registry entry: $_"
        }
    }
}

# -----------------------------
# 3. Optional cleanup (safe)
# -----------------------------
Remove-Item "C:\Program Files\Notepad++" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files (x86)\Notepad++" -Recurse -Force -ErrorAction SilentlyContinue

Write-Log "Notepad++ uninstall remediation completed."
exit 0
