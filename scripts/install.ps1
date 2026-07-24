param(
    [string]$Preset = "release-msvc",
    [string]$Prefix = "artifacts/install/$Preset"
)

$ErrorActionPreference = "Stop"

cmake --preset $Preset
cmake --build --preset $Preset
cmake --install "build/$Preset" --prefix $Prefix

Write-Host "Installed scaffold to $Prefix"
