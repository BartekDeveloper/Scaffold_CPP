param(
    [string]$Preset = "debug"
)

$ErrorActionPreference = "Stop"

ctest --test-dir "build/$Preset" --output-on-failure
