# NOTE: VCPKG is still broken, there are little more issues (CI/CD ones) too.
# DO NOT USE YET UNLESS YOU KNOW HOW TO FIX IT.

# Scaffold

Modern C++ project scaffold built using CMake and focused on a clean local development workflow.

This repository is currently an early-stage project structure. It already includes:

- CMake-based builds
- Debug and release presets
- Sanitizer presets
- Optional `vcpkg` manifest mode dependency management
- Formatting with `clang-format`
- Static analysis with `clang-tidy`
- API documentation with Doxygen
- A basic application and test layout

The codebase is intentionally small right now and is expected to grow into a reusable project template over time.


## Project Status

This repository is currently in scaffold stage 😉
That means the build system, tooling, and repository structure are being present only. 

## QUICK_START

Build and test the default local setup:

```sh
cmake --preset debug
cmake --build --preset debug
ctest --test-dir build/debug --output-on-failure
```

If you want dependency resolution through `vcpkg`:

```sh
export VCPKG_ROOT=/path/to/vcpkg
cmake --preset debug-vcpkg
cmake --build --preset debug-vcpkg
ctest --test-dir build/debug-vcpkg --output-on-failure
```

For a practical onboarding walkthrough, see [GUIDE.MD](./GUIDE.MD).

Script alternatives:

```sh
./scripts/build.sh debug
./scripts/test.sh debug
./scripts/generate_docs.sh
```


## Repository Layout

```text
.
├── vcpkg.json
├── tests
│   └── tests.cpp
├── testapp
│   └── testapp.cpp
├── scripts
│   ├── tidy.sh
│   ├── tidy.ps1
│   ├── test.sh
│   ├── test.ps1
│   ├── install.sh
│   ├── install.ps1
│   ├── generate_docs.sh
│   ├── generate_docs.ps1
│   ├── format.sh
│   ├── format.ps1
│   ├── build.sh
│   └── build.ps1
├── lib
│   ├── lib.cpp
│   ├── interfaces
│   └── interface.hpp
├── generate_docs.sh
├── cmake
│   └── MyLibConfig.cmake.in
├── README.md
├── LICENSE.md
├── GUIDE.MD
├── Doxyfile.in
├── CONTRIBUTORS.md
├── CONTRIBUTING_GUIDE.md
├── CODE_CONVENTIONS.md
├── CMakePresets.json
└── CMakeLists.txt
```

(generated via 'tree --gitignore -C -vr -L 2')


## Requirements

Recommended local tools:

- CMake 3.25+
- Ninja
- A C++23-capable compiler (preferably Clang)
- Clang tools:
  - `clang-format`
  - `clang-tidy`
- Doxygen

Optional but useful:

- `ccache`
- `mold`
- `gold`
- `jemalloc`
- `mimalloc`
- `vcpkg`

## Dependency Management

This scaffold supports two dependency paths:

- default configure flow with `FetchContent` fallback for test dependencies
- `vcpkg` manifest mode through dedicated presets

The repository includes a `vcpkg.json` manifest for project dependencies. To use the `vcpkg` presets, set `VCPKG_ROOT` in your environment so CMake can locate `vcpkg.cmake`.

Example:

```sh
export VCPKG_ROOT=/path/to/vcpkg
cmake --preset debug-vcpkg
cmake --build --preset debug-vcpkg
ctest --test-dir build/debug-vcpkg --output-on-failure
```

If you prefer not to use `vcpkg`, the default presets still work and CMake can fall back to fetching GoogleTest during configure.


## Quick Start

Configure a debug build:

```sh
cmake --preset debug
```

Build the project:

```sh
cmake --build --preset debug
```

Run tests:

```sh
ctest --test-dir build/debug --output-on-failure
```

Or use the helper scripts:

```sh
./scripts/build.sh debug
./scripts/test.sh debug
```


## Build Presets

Included presets are:

- `debug`
- `debug-vcpkg`
- `debug-gcc`
- `debug-clang`
- `debug-msvc`
- `debug-asan`
- `debug-asan-vcpkg`
- `debug-ubsan`
- `debug-tsan`
- `debug-msan`
- `docs`
- `docs-vcpkg`
- `release`
- `release-vcpkg`
- `release-msvc`
- `release-lto`
- `release-thinlto`

Examples:

```sh
cmake --preset debug-asan
cmake --build --preset debug-asan
ctest --test-dir build/debug-asan --output-on-failure
```

```sh
cmake --preset release
cmake --build --preset release
```

```sh
cmake --preset release-vcpkg
cmake --build --preset release-vcpkg
```


## Formatting

Format project sources in place:

```sh
cmake --build --preset debug --target format
```

Check formatting without modifying files:

```sh
cmake --build --preset debug --target format-check
```


## Static Analysis

Run `clang-tidy` explicitly after configuring:

```sh
cmake --build --preset debug --target tidy
```

Enable `clang-tidy` during compilation:

```sh
cmake --preset debug -DENABLE_CLANG_TIDY=ON
cmake --build --preset debug
```

## Documentation Generation

Generate API documentation with Doxygen:

```sh
cmake --preset docs
cmake --build --preset docs --target docs
```

Or use the helper script:

```sh
./generate_docs.sh
```

To use the `vcpkg` docs preset:

```sh
./generate_docs.sh docs-vcpkg
```

Generated HTML output will be placed under:

```text
docs/html/index.html
```

The Doxygen configuration targets `lib/interface.hpp` and `lib/interfaces/` as the public API surface and also includes test sources as supplemental documentation for the scaffold.

PowerShell alternative:

```powershell
./scripts/generate_docs.ps1
```

## CI And Release Automation

GitHub Actions workflows are included for:

- GCC CI builds on Linux
- Clang CI builds on Linux
- MSVC CI builds on Windows
- Doxygen documentation generation and artifact upload
- GitHub Release asset publishing
- GHCR container publishing on release
- NuGet package publishing on release


## Development Notes

- `compile_commands.json` is enabled through CMake configuration.
- Clang is recommended, though other compilers may work.
- Public headers are limited to `lib/interface.hpp` and headers under `lib/interfaces/`.
- Optional performance-oriented tooling such as `ccache` and alternative linkers may be enabled automatically when available.


## Documentation

- Contribution process: [`CONTRIBUTING_GUIDE.md`](./CONTRIBUTING_GUIDE.md)
- Coding standards: [`CODE_CONVENTIONS.md`](./CODE_CONVENTIONS.md)
- Contributors: [`CONTRIBUTORS.md`](./CONTRIBUTORS.md)


## Roadmap


## License

This project is licensed under the [MIT License](./LICENSE.md).
