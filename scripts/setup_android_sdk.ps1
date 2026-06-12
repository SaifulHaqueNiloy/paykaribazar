$ProgressPreference = 'SilentlyContinue'

$sdkPath = "C:\Android"
$zipPath = "$sdkPath\cmdline-tools.zip"

if (-not (Test-Path $sdkPath)) {
    New-Item -ItemType Directory -Force -Path $sdkPath
}

if (-not (Test-Path $zipPath)) {
    Write-Host "Downloading Android SDK Command-Line Tools..."
    Invoke-WebRequest -Uri "https://dl.google.com/android/repository/commandlinetools-win-14742923_latest.zip" -OutFile $zipPath
} else {
    Write-Host "cmdline-tools.zip already exists. Skipping download."
}

Write-Host "Extracting Command-Line Tools..."
if (Test-Path "$sdkPath\temp_cmdline") {
    Remove-Item -Recurse -Force "$sdkPath\temp_cmdline"
}
Expand-Archive -Path $zipPath -DestinationPath "$sdkPath\temp_cmdline" -Force

# Re-structure to cmdline-tools/latest/...
$latestDir = "$sdkPath\cmdline-tools\latest"
if (Test-Path "$sdkPath\cmdline-tools") {
    Remove-Item -Recurse -Force "$sdkPath\cmdline-tools"
}
New-Item -ItemType Directory -Force -Path "$sdkPath\cmdline-tools"

Move-Item -Path "$sdkPath\temp_cmdline\cmdline-tools" -Destination $latestDir -Force

# Clean up zip and temp folder
Remove-Item -Force $zipPath
Remove-Item -Recurse -Force "$sdkPath\temp_cmdline"

Write-Host "Accepting licenses and installing Android SDK platforms & build tools..."
$sdkManager = "$latestDir\bin\sdkmanager.bat"

# Set JAVA_HOME environment variable for the script execution context
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-21.0.11.10-hotspot\"

# Accept all licenses
$yes = "y`ny`ny`ny`ny`ny`ny`n"
$yes | &$sdkManager --licenses

# Install platforms and build tools
&$sdkManager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

Write-Host "Configuring Flutter/Puro with the Android SDK path..."
puro flutter config --android-sdk "C:\Android"

Write-Host "Android SDK Setup Complete!"
