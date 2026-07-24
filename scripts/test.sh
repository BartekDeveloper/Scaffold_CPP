#!/usr/bin/env bash

set -euo pipefail

preset="${1:-debug}"

ctest --test-dir "build/${preset}" --output-on-failure
