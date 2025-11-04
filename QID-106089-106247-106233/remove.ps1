# QID106247 - Remove .NET 5x 6.x  7.x Runtime and Windows Desktop Runtime
# Silent, production-safe version for Intune Remediation or standalone use.


$ErrorActionPreference = 'SilentlyContinue'
$LogDir = "C:\Logs\Remove-DOTNET"
$LogFile = "logRemoval.txt"



Start-Transcript -Path "$LogDir\$LogFile" -Append
# Seperate sections for each .NET using same logic, 
# it can be consolidated but don't want to adjust regex since I already had it working for dotnet 6 and expanded to 5 and 7


Write-Host "----- Starting .NET 5 removal process -----" -ForegroundColor Cyan
# Remove all .NET 5.x runtimes (Runtime + Windows Desktop, x86/x64)

$AppNames = @(
    "Microsoft .NET Runtime - 5.*",
    "Microsoft Windows Desktop Runtime -5.*",
    "Microsoft .NET Host FX Resolver - 5.*",
    "Microsoft .NET Host - 5.*"
)

$RegistryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$Uninstalled = $false

foreach ($AppName in $AppNames) {
    foreach ($Path in $RegistryPaths) {
        $Apps = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
        foreach ($App in $Apps) {
            $DisplayName = $App.GetValue("DisplayName")
            $UninstallString = $App.GetValue("UninstallString")

            if ($DisplayName -like $AppName) {
                $Guid = $App.PSChildName
                if ($Guid -match "^{.*}$") {
                    Write-Host "Uninstalling $DisplayName ($Guid)..." -ForegroundColor Yellow
                    Start-Process "MsiExec.exe" -ArgumentList "/X $Guid /quiet /norestart" -NoNewWindow -Wait
                    $Uninstalled = $true
                }
            }
        }
    }
}

if ($Uninstalled) {
    Write-Host "`nUninstallation of .NET 5 components completed successfully." -ForegroundColor Green
} else {
    Write-Host "`nNo .NET 5 components were found to uninstall." -ForegroundColor Cyan
}

foreach ($Path in $RegistryPaths) {
    Get-ChildItem -Path $Path -ErrorAction SilentlyContinue |
    Where-Object { $_.GetValue("DisplayName") -match "Microsoft\s+(\.NET|Windows\s+Desktop)\s+(Runtime|Host|Host\s+FX\s+Resolver)\s+-\s+5\." } |
    ForEach-Object {
        Write-Host "Removing stale registry key: $($_.PSChildName)" -ForegroundColor Cyan
        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Clean up residual folders
$paths = @(
  "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\5.0.*",
  "C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\5.0.*",
  "C:\Program Files (x86)\dotnet\shared\Microsoft.NETCore.App\5.0.*",
  "C:\Program Files (x86)\dotnet\shared\Microsoft.WindowsDesktop.App\5.0.*"
)

foreach ($p in $paths) {
    Get-ChildItem $p -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Write-Log "Deleting residual: $($_.FullName)"
        Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Cleaning complete. Checking remaining runtimes..."

try {
    $runtimes = & "$env:ProgramFiles\dotnet\dotnet.exe" --list-runtimes 2>$null
    $remaining = ($runtimes | Select-String "5\.0\.")
    if ($remaining) {
        Write-Host " .NET 5 still detected. Manual cleanup may be required."
    } else {
        Write-Host " .NET 5 successfully removed."
    }
} catch {
    Write-Host "Unable to query dotnet runtime list."
}

Write-Host "----- End of .NET 5 removal process -----"
Write-Host ""
Write-Host "----- Starting .NET 6 removal process -----" -ForegroundColor Cyan
# Remove all .NET 6.x runtimes (Runtime + Windows Desktop, x86/x64)
# Keeps your structure and adds wildcard + multiple-name handling

$AppNames = @(
    "Microsoft .NET Runtime - 6.*",
    "Microsoft Windows Desktop Runtime - 6.*",
    "Microsoft .NET Host FX Resolver - 6.*",
    "Microsoft .NET Host - 6.*"
)


$RegistryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$Uninstalled = $false

foreach ($AppName in $AppNames) {
    foreach ($Path in $RegistryPaths) {
        $Apps = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
        foreach ($App in $Apps) {
            $DisplayName = $App.GetValue("DisplayName")
            $UninstallString = $App.GetValue("UninstallString")

            if ($DisplayName -like $AppName) {
                $Guid = $App.PSChildName
                if ($Guid -match "^{.*}$") {
                    Write-Host "Uninstalling $DisplayName ($Guid)..." -ForegroundColor Yellow
                    Start-Process "MsiExec.exe" -ArgumentList "/X $Guid /quiet /norestart" -NoNewWindow -Wait
                    $Uninstalled = $true
                }
            }
        }
    }
}

if ($Uninstalled) {
    Write-Host "`nUninstallation of .NET 6 components completed successfully." -ForegroundColor Green
} else {
    Write-Host "`nNo .NET 6 components were found to uninstall." -ForegroundColor Cyan
}

foreach ($Path in $RegistryPaths) {
    Get-ChildItem -Path $Path -ErrorAction SilentlyContinue |
    Where-Object { $_.GetValue("DisplayName") -match "Microsoft\s+(\.NET|Windows\s+Desktop)\s+(Runtime|Host|Host\s+FX\s+Resolver)\s+-\s+6\." } |
    ForEach-Object {
        Write-Host "Removing stale registry key: $($_.PSChildName)" -ForegroundColor Cyan
        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Clean up residual folders
$paths = @(
  "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\6.0.*",
  "C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\6.0.*",
  "C:\Program Files (x86)\dotnet\shared\Microsoft.NETCore.App\6.0.*",
  "C:\Program Files (x86)\dotnet\shared\Microsoft.WindowsDesktop.App\6.0.*"
)

foreach ($p in $paths) {
    Get-ChildItem $p -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Write-Log "Deleting residual: $($_.FullName)"
        Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Cleaning complete. Checking remaining runtimes..."

try {
    $runtimes = & "$env:ProgramFiles\dotnet\dotnet.exe" --list-runtimes 2>$null
    $remaining = ($runtimes | Select-String "6\.0\.")
    if ($remaining) {
        Write-Host " .NET 6 still detected. Manual cleanup may be required."
    } else {
        Write-Host " .NET 6 successfully removed."
    }
} catch {
    Write-Host "Unable to query dotnet runtime list."
}

Write-Host "----- End of .NET 6 removal process -----"
Write-Host ""
Write-Host "----- Starting .NET 7 removal process -----" -ForegroundColor Cyan
# Remove all .NET 7.x runtimes (Runtime + Windows Desktop, x86/x64)

$AppNames = @(
    "Microsoft .NET Runtime - 7.*",
    "Microsoft Windows Desktop Runtime - 7.*",
    "Microsoft .NET Host FX Resolver - 7.*",
    "Microsoft .NET Host - 7.*"
)


$RegistryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$Uninstalled = $false

foreach ($AppName in $AppNames) {
    foreach ($Path in $RegistryPaths) {
        $Apps = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
        foreach ($App in $Apps) {
            $DisplayName = $App.GetValue("DisplayName")
            $UninstallString = $App.GetValue("UninstallString")

            if ($DisplayName -like $AppName) {
                $Guid = $App.PSChildName
                if ($Guid -match "^{.*}$") {
                    Write-Host "Uninstalling $DisplayName ($Guid)..." -ForegroundColor Yellow
                    Start-Process "MsiExec.exe" -ArgumentList "/X $Guid /quiet /norestart" -NoNewWindow -Wait
                    $Uninstalled = $true
                }
            }
        }
    }
}

if ($Uninstalled) {
    Write-Host "`nUninstallation of .NET 7 components completed successfully." -ForegroundColor Green
} else {
    Write-Host "`nNo .NET 7 components were found to uninstall." -ForegroundColor Cyan
}

foreach ($Path in $RegistryPaths) {
    Get-ChildItem -Path $Path -ErrorAction SilentlyContinue |
    Where-Object { $_.GetValue("DisplayName") -match "Microsoft\s+(\.NET|Windows\s+Desktop)\s+(Runtime|Host|Host\s+FX\s+Resolver)\s+-\s+7\." } |
    ForEach-Object {
        Write-Host "Removing stale registry key: $($_.PSChildName)" -ForegroundColor Cyan
        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}


# Clean up residual folders
$paths = @(
  "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\7.0.*",
  "C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\7.0.*",
  "C:\Program Files (x86)\dotnet\shared\Microsoft.NETCore.App\7.0.*",
  "C:\Program Files (x86)\dotnet\shared\Microsoft.WindowsDesktop.App\7.0.*"
)

foreach ($p in $paths) {
    Get-ChildItem $p -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Write-Log "Deleting residual: $($_.FullName)"
        Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Cleaning complete. Checking remaining runtimes..."

try {
    $runtimes = & "$env:ProgramFiles\dotnet\dotnet.exe" --list-runtimes 2>$null
    $remaining = ($runtimes | Select-String "7\.0\.")
    if ($remaining) {
        Write-Host " .NET 7 still detected. Manual cleanup may be required."
    } else {
        Write-Host " .NET 7 successfully removed."
    }
} catch {
    Write-Host "Unable to query dotnet runtime list."
}

Write-Host "----- End of .NET 7 removal process -----"
dotnet --list-runtimes
Stop-Transcript

exit 0
