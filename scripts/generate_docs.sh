#!/usr/bin/env bash

set -euo pipefail

preset="${1:-docs}"

cmake --preset "${preset}"
cmake --build --preset "${preset}" --target docs

printf 'Documentation generated at docs/html/index.html\n'
