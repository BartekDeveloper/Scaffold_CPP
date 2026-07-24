param(
    [string]$Preset = "debug",
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

if ($Apply) {
    cmake --build --preset $Preset --target format
}
else {
    cmake --build --preset $Preset --target format-check
}
