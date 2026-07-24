# Guide

This guide is a practical starting point for working in the scaffold project template.

It is meant to answer the common first questions:

- what this repository is
- how to build it
- how to run tests
- how dependencies work
- how to generate documentation
- which project documents to read next

## What This Repository Is

An early-stage C++ project scaffold built around:

- CMake
- C++23
- local formatting and static analysis
- optional `vcpkg` manifest mode
- Doxygen documentation generation

At the moment, the project is intentionally small. The build and workflow foundation are being established first so the repository can grow into a reusable template.

## Recommended Reading Order

If you are new to the repository, read these files in this order:

1. `README.md`
2. `GUIDE.MD`
3. `CONTRIBUTING_GUIDE.md`
4. `CODE_CONVENTIONS.md`

Use `CONTRIBUTORS.md` for contributor and maintainer tracking.

## Quick Setup

### Standard Local Build

```sh
cmake --preset debug
cmake --build --preset debug
ctest --test-dir build/debug --output-on-failure
```

Equivalent helper scripts:

```sh
./scripts/build.sh debug
./scripts/test.sh debug
```

### Build With vcpkg

```sh
export VCPKG_ROOT=/path/to/vcpkg
cmake --preset debug-vcpkg
cmake --build --preset debug-vcpkg
ctest --test-dir build/debug-vcpkg --output-on-failure
```

## Repository Layout

Important paths:

- `lib/interface.hpp`: main public library header
- `lib/interfaces/`: additional public interface headers
- `lib/`: library implementation files and public interface entrypoints
- `testapp/`: example or manual test application
- `tests/`: automated tests
- `CMakeLists.txt`: primary build configuration
- `CMakePresets.json`: standard configure and build presets
- `Doxyfile.in`: Doxygen template used by CMake
- `vcpkg.json`: repo-local dependency manifest
- `scripts/`: bash and PowerShell helper entrypoints
- `.github/workflows/`: CI and release automation

## Build Workflows

### Default Configure

The default presets do not require `vcpkg`.

For tests, the build system will try:

1. packaged `GTest`
2. `FetchContent` fallback if allowed

This keeps the scaffold easy to build on a fresh machine.

### vcpkg Configure

The `vcpkg` presets use manifest mode through `CMAKE_TOOLCHAIN_FILE`.

Current `vcpkg`-enabled presets include:

- `debug-vcpkg`
- `debug-asan-vcpkg`
- `release-vcpkg`

Use these when you want project dependencies resolved through `vcpkg` instead of the fallback path.

Compiler-pinned presets are also available for local and CI use:

- `debug-gcc`
- `debug-clang`
- `debug-msvc`
- `release-gcc`
- `release-clang`
- `release-msvc`

## Quality Checks

Run the usual checks before treating a change as ready:

```sh
cmake --preset debug
cmake --build --preset debug
ctest --test-dir build/debug --output-on-failure
cmake --build --preset debug --target format-check
cmake --build --preset debug --target tidy
```

## Documentation Generation

Generate docs with either command:

```sh
cmake --preset docs
cmake --build --preset docs --target docs
```

```sh
./generate_docs.sh
```

```powershell
./scripts/generate_docs.ps1
```

Generated HTML entry point:

```text
docs/html/index.html
```

The documentation setup currently focuses on:

- `lib/interface.hpp`
- headers under `lib/interfaces/`
- repository-level Markdown docs
- test sources as supplemental project reference

## When To Read Which File

Read `README.md` when you need the high-level project overview.

Read `GUIDE.MD` when you need the practical working path through the scaffold.

Read `CONTRIBUTING_GUIDE.md` when you are preparing to make or submit changes.

Read `CODE_CONVENTIONS.md` when you are writing or reviewing code.

## Notes For Future Template Work

This scaffold is still evolving. As the project matures, expect these areas to become more complete:

- richer public headers
- stronger automated test coverage
- more realistic example applications
- better install/export support
- more project-specific Doxygen content
