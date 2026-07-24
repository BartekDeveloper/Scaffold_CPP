#!/usr/bin/env bash

set -euo pipefail

preset="${1:-debug}"

cmake --preset "${preset}" -DENABLE_CLANG_TIDY=ON
cmake --build --preset "${preset}" --target tidy
