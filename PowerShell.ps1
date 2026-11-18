# ============================================================
# ANDROID DEVELOPMENT SHELL
# Project-specific configuration
# ============================================================

# Project name (display only)
$ProjectName = "Mihon Custom Title"

# Java / JDK
$JavaHome = "C:\Program Files\Android\Android Studio\jbr"

# Android SDK
$AndroidSdk = "$env:LOCALAPPDATA\Android\Sdk"

# Android Studio executable
$AndroidStudioExe = "C:\Program Files\Android\Android Studio\bin\studio64.exe"


# ============================================================
# INITIALIZATION - DO NOT EDIT BELOW THIS LINE
# ============================================================

$ErrorActionPreference = "Stop"

try {
    # ============================================================
    # UTF-8 CONSOLE CONFIGURATION
    # ============================================================

    # Set Windows console code page to UTF-8.
    & chcp.com 65001 > $null

    # Configure .NET console input and output.
    $Utf8Encoding = [System.Text.UTF8Encoding]::new($false)

    [Console]::InputEncoding = $Utf8Encoding
    [Console]::OutputEncoding = $Utf8Encoding

    # Configure encoding for data piped to native applications.
    $OutputEncoding = $Utf8Encoding

    # ============================================================

    # Determine project root from this script's location.
    $ProjectRoot = (Resolve-Path -LiteralPath $PSScriptRoot).Path

    Set-Location -LiteralPath $ProjectRoot

    $JavaExe = Join-Path $JavaHome "bin\java.exe"
    $AdbExe = Join-Path $AndroidSdk "platform-tools\adb.exe"
    $StudioBin = Split-Path -Parent $AndroidStudioExe

    # Validate required tools.
    $requiredPaths = @(
        @{ Name = "Java"; Path = $JavaExe },
        @{ Name = "Android SDK"; Path = $AndroidSdk },
        @{ Name = "ADB"; Path = $AdbExe },
        @{ Name = "Android Studio"; Path = $AndroidStudioExe }
    )

    foreach ($item in $requiredPaths) {
        if (-not (Test-Path -LiteralPath $item.Path)) {
            throw "$($item.Name) not found: $($item.Path)"
        }
    }

    # Configure Java.
    $env:JAVA_HOME = $JavaHome

    # Configure Android SDK.
    $env:ANDROID_HOME = $AndroidSdk
    $env:ANDROID_SDK_ROOT = $AndroidSdk

    # Add tool directories to PATH without duplicating entries.
    $pathEntries = @(
        (Join-Path $JavaHome "bin"),
        (Join-Path $AndroidSdk "platform-tools"),
        (Join-Path $AndroidSdk "emulator"),
        $StudioBin,
        (Join-Path $AndroidSdk "cmdline-tools\latest\bin")
    )

    foreach ($entry in $pathEntries) {
        if (Test-Path -LiteralPath $entry -PathType Container) {
            $normalizedEntry = $entry.TrimEnd('\')

            $alreadyPresent = $env:Path -split ';' |
                Where-Object {
                    $_.Trim().TrimEnd('\') -ieq $normalizedEntry
                }

            if (-not $alreadyPresent) {
                $env:Path = "$entry;$env:Path"
            }
        }
    }

    # Display environment information.
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host "              ANDROID DEVELOPMENT SHELL" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor DarkCyan

    Write-Host ""
    Write-Host "PROJECT" -ForegroundColor Yellow
    Write-Host "  Name:       $ProjectName"
    Write-Host "  Root:       $ProjectRoot"

    Write-Host ""
    Write-Host "JAVA" -ForegroundColor Yellow
    Write-Host "  JAVA_HOME:  $env:JAVA_HOME"
    Write-Host "  Executable: $JavaExe"
    Write-Host "  Status:     OK" -ForegroundColor Green

    Write-Host ""
    Write-Host "ANDROID SDK" -ForegroundColor Yellow
    Write-Host "  SDK:        $AndroidSdk"
    Write-Host "  ADB:        $AdbExe"
    Write-Host "  Status:     OK" -ForegroundColor Green

    Write-Host ""
    Write-Host "ANDROID STUDIO" -ForegroundColor Yellow
    Write-Host "  Executable: $AndroidStudioExe"
    Write-Host "  Status:     OK" -ForegroundColor Green

    Write-Host ""
    Write-Host "TOOLS CHECK" -ForegroundColor Yellow

    $javaCommand = Get-Command java -ErrorAction Stop
    $adbCommand = Get-Command adb -ErrorAction Stop

    Write-Host "  Java:       $($javaCommand.Source)" -ForegroundColor Green
    Write-Host "  ADB:        $($adbCommand.Source)" -ForegroundColor Green

    Write-Host ""
    Write-Host "  Gradle wrapper: $(Test-Path (Join-Path $ProjectRoot 'gradlew.bat'))"

    if (-not (Test-Path (Join-Path $AndroidSdk "cmdline-tools"))) {
        Write-Host "  Note: Android SDK Command-line Tools are not installed." -ForegroundColor DarkYellow
    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host " Environment initialized successfully!" -ForegroundColor Green
    Write-Host " Ready to work." -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host ""

}
catch {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " ENVIRONMENT INITIALIZATION FAILED" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
}