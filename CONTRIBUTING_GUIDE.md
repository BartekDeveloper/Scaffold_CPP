# Contributing Guide

Thanks for wanting to contribute to this project scaffolding.

This project is currently small and evolving, so the best contributions are usually focused, clear, and easy to review.

## Goals For Contributions

Prefer contributions that improve one or more of the following:

- correctness
- readability
- maintainability
- test coverage
- build reliability
- documentation quality
- template readiness

## Before You Start

Make sure you have the basic toolchain installed:

- CMake 3.25+
- Ninja
- a C++23-capable compiler
- `clang-format`
- `clang-tidy`

Recommended optional tools:

- `ccache`
- `mold` or `gold`
- `vcpkg`
- Doxygen

## Dependency Management

The project supports a repo-local `vcpkg.json` manifest and also keeps a non-`vcpkg` path through `FetchContent` for test dependencies.

If you want to use the `vcpkg` presets, set `VCPKG_ROOT` first:

```sh
export VCPKG_ROOT=/path/to/vcpkg
cmake --preset debug-vcpkg
cmake --build --preset debug-vcpkg
```

If you prefer a machine-local override instead of exporting environment variables globally, use a local `CMakeUserPresets.json` file.

Compiler-pinned presets are available when you want to force a specific toolchain, including `debug-gcc`, `debug-clang`, `debug-msvc`, `release-gcc`, `release-clang`, and `release-msvc`.

## Repository Setup

Configure a local debug build:

```sh
cmake --preset debug
```

Build the project:

```sh
cmake --build --preset debug
```

Helper script alternative:

```sh
./scripts/build.sh debug
```

Run tests:

```sh
ctest --test-dir build/debug --output-on-failure
```

Helper script alternative:

```sh
./scripts/test.sh debug
```

## Development Workflow

A simple default workflow:

1. Understand the problem before editing code.
2. Make the smallest correct change.
3. Keep unrelated changes out of the same patch.
4. Build locally.
5. Run tests locally.
6. Run formatting and analysis checks.
7. Update documentation if behavior or workflow changed.

## Branching

If you use topic branches, prefer short descriptive names such as:

- `fix/test-build`
- `docs/readme-refresh`
- `feat/message-parser`

## Coding Expectations

Follow [`CODE_CONVENTIONS.md`](./CODE_CONVENTIONS.md).

Key expectations:

- use C++23
- keep code warning-clean
- prefer explicit, readable code
- avoid unnecessary abstractions
- avoid `using namespace std;` in shared code
- avoid `#include <bits/stdc++.h>` in production-quality project code

## Build And Test Checklist

Before submitting changes, run the normal local checks.

### Build

```sh
cmake --preset debug
cmake --build --preset debug
```

### Test

```sh
ctest --test-dir build/debug --output-on-failure
```

### Format Check

```sh
cmake --build --preset debug --target format-check
```

To apply formatting:

```sh
cmake --build --preset debug --target format
```

### Static Analysis

```sh
cmake --build --preset debug --target tidy
```

### Optional Sanitizer Passes

For riskier changes, run one or more sanitizer builds:

```sh
cmake --preset debug-asan
cmake --build --preset debug-asan
ctest --test-dir build/debug-asan --output-on-failure
```

```sh
cmake --preset debug-ubsan
cmake --build --preset debug-ubsan
ctest --test-dir build/debug-ubsan --output-on-failure
```

### Documentation

Generate the Doxygen site:

```sh
cmake --preset docs
cmake --build --preset docs --target docs
```

Helper script alternatives:

```sh
./scripts/generate_docs.sh
```

```powershell
./scripts/generate_docs.ps1
```

Open the generated entry point at `docs/html/index.html`.

## Documentation Expectations

Update documentation when you change:

- project setup
- build commands
- testing workflow
- coding conventions
- public behavior
- public headers or API semantics
- repository layout that contributors need to understand

At minimum, consider whether the change should update:

- `README.md`
- `CODE_CONVENTIONS.md`
- `CONTRIBUTORS.md`
- `CONTRIBUTING_GUIDE.md`

## Commit Guidance

Keep commits focused and readable.

Good commit characteristics:

- one primary purpose
- concise subject
- no unrelated formatting churn
- easy-to-review diff

Example subjects:

- `docs: expand contributor guide`
- `build: add sanitizer preset note`
- `tests: cover parser edge cases`

## Pull Request Expectations

A good change submission should include:

- a clear summary of what changed
- why the change was needed
- any important tradeoffs
- local validation performed
- follow-up work if something is intentionally deferred

## Review Checklist

Before requesting review, confirm:

- the project builds
- relevant tests pass
- formatting is clean
- static analysis is acceptable
- docs were updated if needed
- the change is limited to the intended scope

## What To Avoid

Avoid these common problems:

- mixing refactors with behavior changes without need
- adding unused abstractions
- changing unrelated files
- leaving formatting issues for reviewers
- documenting features that do not exist yet
- skipping tests for behavior that can be checked automatically

## Questions And Discussion

If a change has unclear scope or tradeoffs, discuss the approach before expanding the patch unnecessarily.

When in doubt, choose the simpler implementation and document any assumptions.
