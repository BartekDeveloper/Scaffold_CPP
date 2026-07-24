param(
    [string]$Preset = "docs"
)

$ErrorActionPreference = "Stop"

cmake --preset $Preset
cmake --build --preset $Preset --target docs

Write-Host "Documentation generated at docs/html/index.html"
