param(
    [string]$Preset = "debug"
)

$ErrorActionPreference = "Stop"

cmake --preset $Preset -DENABLE_CLANG_TIDY=ON
cmake --build --preset $Preset --target tidy
