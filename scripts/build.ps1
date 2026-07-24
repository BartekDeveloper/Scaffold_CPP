param(
    [string]$Preset = "debug"
)

$ErrorActionPreference = "Stop"

cmake --preset $Preset
cmake --build --preset $Preset
