# Chloride Browser - Windows Native Host Installer
# Run: powershell -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = "Stop"

$HostName = "com.superrealchlorine.chloride_host"
$ExtensionId = "chloride-firefox@superrealchlorine.com"

$ScriptDir = $PSScriptRoot
$InstallDir = Join-Path $env:LOCALAPPDATA "Chloride"

$HostScript = Join-Path $ScriptDir "chloride-host.py"

Write-Host ""
Write-Host "=========================================="
Write-Host " Chloride Protocol Windows Installer"
Write-Host "=========================================="
Write-Host ""

# Check required files
if (!(Test-Path $HostScript)) {
	throw "chloride-host.py not found."
}

# Find Python
$Python = Get-Command python -ErrorAction SilentlyContinue

if (!$Python) {
	$Python = Get-Command py -ErrorAction SilentlyContinue
}

if (!$Python) {
	throw "Python 3 is required. Install Python and try again."
}

$PythonCommand = $Python.Source

Write-Host "[1/5] Python found: $PythonCommand"

# Create installation directory
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# Install PyInstaller
Write-Host "[2/5] Checking PyInstaller..."

& $PythonCommand -m pip install --user pyinstaller

if ($LASTEXITCODE -ne 0) {
	throw "Failed to install PyInstaller."
}

# Build standalone Windows executable
Write-Host "[3/5] Building native host..."

$BuildDir = Join-Path $env:TEMP "chloride-build"

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

& $PythonCommand -m PyInstaller `
	--onefile `
	--clean `
	--name chloride-host `
	--distpath $BuildDir `
	--workpath (Join-Path $BuildDir "work") `
	--specpath $BuildDir `
	$HostScript

if ($LASTEXITCODE -ne 0) {
	throw "Failed to build chloride-host.exe."
}

$Executable = Join-Path $BuildDir "chloride-host.exe"

if (!(Test-Path $Executable)) {
	throw "Build completed but executable was not found."
}

Copy-Item $Executable (Join-Path $InstallDir "chloride-host.exe") -Force

# Generate native messaging manifest
Write-Host "[4/5] Creating native messaging manifest..."

$Manifest = @{
	name = $HostName
	description = "Native TCP messaging bridge for Chloride Protocol"
	path = (Join-Path $InstallDir "chloride-host.exe")
	type = "stdio"
	allowed_extensions = @($ExtensionId)
}

$ManifestPath = Join-Path $InstallDir "$HostName.json"

$Manifest |
	ConvertTo-Json -Depth 5 |
	Set-Content -Path $ManifestPath -Encoding UTF8

# Register Firefox native messaging host
Write-Host "[5/5] Registering Firefox..."

$RegistryPath = "HKCU:\Software\Mozilla\NativeMessagingHosts\$HostName"

New-Item -Path $RegistryPath -Force | Out-Null

Set-Item -Path $RegistryPath -Value $ManifestPath

Write-Host ""
Write-Host "=========================================="
Write-Host " Installation completed!"
Write-Host "=========================================="
Write-Host ""
Write-Host "Executable: $InstallDir\chloride-host.exe"
Write-Host "Manifest:   $ManifestPath"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Open Firefox."
Write-Host "2. Navigate to about:debugging#/runtime/this-firefox"
Write-Host "3. Click Load Temporary Add-on."
Write-Host "4. Select manifest.json from this repository."
Write-Host ""
Write-Host "Restart Firefox if necessary."
