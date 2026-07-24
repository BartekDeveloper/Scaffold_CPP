#!/usr/bin/env bash

set -euo pipefail

preset="${1:-release}"
prefix="${2:-$(pwd)/artifacts/install/${preset}}"

cmake --preset "${preset}"
cmake --build --preset "${preset}"
cmake --install "build/${preset}" --prefix "${prefix}"

printf 'Installed scaffold to %s\n' "${prefix}"
