param (
    [switch]$SkipAndroid = $false
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$ReleaseDir = "$ProjectRoot\Dastra_Release_Artifacts"
$DeveloperDir = "$ReleaseDir\Dastra_Developer"
$CommunityDir = "$ReleaseDir\Dastra_Community"
$InnoCompiler = "$env:LOCALAPPDATA\Programs\Inno Setup 6\iscc.exe"

if (-not (Test-Path $InnoCompiler)) {
    $InnoCompiler = "C:\Program Files (x86)\Inno Setup 6\iscc.exe"
    if (-not (Test-Path $InnoCompiler)) {
        Write-Error "Inno Setup compiler (iscc.exe) not found."
    }
}

function Generate-InfoFile {
    param (
        [string]$Path,
        [string]$Edition,
        [string]$Profile,
        [string]$Channel,
        [string]$License
    )
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Commit = (git rev-parse --short HEAD)
    $Content = @"
Dastra Release Information
========================================
Edition:         $Edition
Build Profile:   $Profile
Release Channel: $Channel
License Tier:    $License
Build Date:      $Date
Git Commit:      $Commit
Target Platforms: Windows x64, Android
"@
    Set-Content -Path $Path -Value $Content
}

function Generate-Checksums {
    param (
        [string]$Dir
    )
    $Files = Get-ChildItem -Path $Dir -Recurse -File | Where-Object { $_.Name -ne "SHA256SUMS.txt" -and $_.Name -ne "Release_Info.txt" }
    $ChecksumFile = "$Dir\SHA256SUMS.txt"
    $Hashes = @()
    foreach ($File in $Files) {
        $Hash = (Get-FileHash -Algorithm SHA256 -Path $File.FullName).Hash.ToLower()
        $Hashes += "$Hash  $($File.Name)"
    }
    Set-Content -Path $ChecksumFile -Value ($Hashes -join "`n")
}

Write-Host "========================================"
Write-Host " Building Dastra Release Editions"
Write-Host "========================================"

# Ensure directories
if (Test-Path $ReleaseDir) { Remove-Item -Path $ReleaseDir -Recurse -Force }
New-Item -Path "$DeveloperDir\Windows" -ItemType Directory -Force | Out-Null
New-Item -Path "$DeveloperDir\Android" -ItemType Directory -Force | Out-Null
New-Item -Path "$CommunityDir\Windows" -ItemType Directory -Force | Out-Null
New-Item -Path "$CommunityDir\Android" -ItemType Directory -Force | Out-Null

Write-Host "`n--- [1/2] Building Developer Edition ---"
$DeveloperDartDefines = "--dart-define=EDITION=Developer --dart-define=BUILD_PROFILE=Developer --dart-define=RELEASE_CHANNEL=Development --dart-define=LICENSE_TIER=`"Internal Developer`""

# Build Windows
Write-Host "Building Flutter Windows (Developer)..."
Invoke-Expression "flutter build windows --release $DeveloperDartDefines"

Write-Host "Creating Developer Portable ZIP..."
Compress-Archive -Path "$ProjectRoot\build\windows\x64\runner\Release\*" -DestinationPath "$DeveloperDir\Windows\DastraDeveloperPortable.zip" -Force

Write-Host "Compiling Developer Setup..."
& $InnoCompiler "/DMyAppName=Dastra Developer" "/DMyAppOutputBaseFilename=DastraDeveloperSetup" "/DMyAppDataFolder=DastraDeveloper" "$ProjectRoot\scripts\windows_setup.iss"
Copy-Item "$ProjectRoot\releases\DastraDeveloperSetup.exe" -Destination "$DeveloperDir\Windows\DastraDeveloperSetup.exe"

# Build Android
if (-not $SkipAndroid) {
    Write-Host "Building Flutter APK (Developer)..."
    Invoke-Expression "flutter build apk --release $DeveloperDartDefines"
    Copy-Item "$ProjectRoot\build\app\outputs\flutter-apk\app-release.apk" -Destination "$DeveloperDir\Android\DastraDeveloper.apk"
}

Generate-InfoFile -Path "$DeveloperDir\Release_Info.txt" -Edition "Developer" -Profile "Developer" -Channel "Development" -License "Internal Developer"
Generate-Checksums -Dir "$DeveloperDir\Windows"
if (-not $SkipAndroid) { Generate-Checksums -Dir "$DeveloperDir\Android" }


Write-Host "`n--- [2/2] Building Community Edition ---"
$CommunityDartDefines = "--dart-define=EDITION=Community --dart-define=BUILD_PROFILE=Public --dart-define=RELEASE_CHANNEL=Stable --dart-define=LICENSE_TIER=Community"

# Build Windows
Write-Host "Building Flutter Windows (Community)..."
Invoke-Expression "flutter build windows --release $CommunityDartDefines"

Write-Host "Creating Community Portable ZIP..."
Compress-Archive -Path "$ProjectRoot\build\windows\x64\runner\Release\*" -DestinationPath "$CommunityDir\Windows\DastraPortable.zip" -Force

Write-Host "Compiling Community Setup..."
& $InnoCompiler "/DMyAppName=Dastra" "/DMyAppOutputBaseFilename=DastraSetup" "/DMyAppDataFolder=Dastra" "$ProjectRoot\scripts\windows_setup.iss"
Copy-Item "$ProjectRoot\releases\DastraSetup.exe" -Destination "$CommunityDir\Windows\DastraSetup.exe"

# Build Android
if (-not $SkipAndroid) {
    Write-Host "Building Flutter APK (Community)..."
    Invoke-Expression "flutter build apk --release $CommunityDartDefines"
    Copy-Item "$ProjectRoot\build\app\outputs\flutter-apk\app-release.apk" -Destination "$CommunityDir\Android\Dastra.apk"
}

Generate-InfoFile -Path "$CommunityDir\Release_Info.txt" -Edition "Community" -Profile "Public" -Channel "Stable" -License "Community"
Generate-Checksums -Dir "$CommunityDir\Windows"
if (-not $SkipAndroid) { Generate-Checksums -Dir "$CommunityDir\Android" }

Write-Host "`nBuilds complete! Artifacts located in: $ReleaseDir"
