$ErrorActionPreference = "Continue"

Write-Host "Creating D:\Android folder..."
New-Item -ItemType Directory -Force -Path "D:\Android"

Write-Host "Moving Android SDK..."
if (Test-Path "C:\Users\LENOVO\AppData\Local\Android\Sdk") {
    Move-Item -Path "C:\Users\LENOVO\AppData\Local\Android\Sdk" -Destination "D:\Android\Sdk" -Force
} else {
    Write-Host "Android SDK not found in C: drive or already moved."
}

Write-Host "Moving Gradle Home..."
if (Test-Path "C:\Users\LENOVO\.gradle") {
    Move-Item -Path "C:\Users\LENOVO\.gradle" -Destination "D:\.gradle" -Force
} else {
    Write-Host ".gradle not found in C: drive or already moved."
}

Write-Host "Setting Environment Variables..."
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "D:\Android\Sdk", "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "D:\Android\Sdk", "User")
[Environment]::SetEnvironmentVariable("GRADLE_USER_HOME", "D:\.gradle", "User")

# Set for current session as well so next commands work immediately
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:ANDROID_SDK_ROOT = "D:\Android\Sdk"
$env:GRADLE_USER_HOME = "D:\.gradle"

Write-Host "Configuring Flutter..."
flutter config --android-sdk D:\Android\Sdk

Write-Host "Migration completed successfully!"
