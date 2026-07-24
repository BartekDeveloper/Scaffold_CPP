#!/usr/bin/env bash

set -euo pipefail

preset="${1:-debug}"
mode="${2:---check}"

if [[ "${mode}" == "--apply" ]]; then
    cmake --build --preset "${preset}" --target format
else
    cmake --build --preset "${preset}" --target format-check
fi
