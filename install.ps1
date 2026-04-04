# Platform
$win32 = "Demo\Win32"
# Target Build
$debug = "Debug"
$release = "Release"
# Paths
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$source      = "$root\$win32\$debug"
$destination = "$root\$win32\$release"
# Resources
$resources = "$root\Resources\resources.7z"
# Commandlets
$cmd7zip = "$root\Resources\7z2201-extra\7za.exe"

& $cmd7zip x $resources -o"$source" -aoa -y

if (-not (Test-Path $destination)) {
    New-Item -ItemType Directory -Path $destination | Out-Null
}

Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force
