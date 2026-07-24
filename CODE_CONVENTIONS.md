# Code Conventions

This document defines the default coding conventions for scaffold.

The goal is consistency, readability, and maintainability. When in doubt, prefer the simpler and more explicit implementation.

## Core Principles

- Write clear code before clever code.
- Prefer small, focused changes.
- Keep functions and files easy to navigate.
- Avoid unnecessary abstractions.
- Make performance decisions intentionally and measurably.
- Keep the build warning-clean.

## Language Standard

- Use C++23.
- Prefer standard library facilities over custom utility code when practical.
- Avoid compiler-specific behavior unless there is a strong reason and it is documented.

## Formatting

Formatting is controlled by the repository-local `.clang-format`.

Current high-level formatting expectations:

- 4-space indentation
- no tabs for indentation
- 100 character column limit
- attached braces
- pointer alignment on the left
- sorted includes when formatting runs

Do not manually fight the formatter. Run the formatter and accept its output.

## Static Analysis

Static analysis is controlled by the repository-local `.clang-tidy`.

General expectations:

- treat static analysis findings seriously
- avoid introducing new warnings
- prefer fixes that improve clarity rather than suppressions
- only suppress a warning when the code is correct and the reason is documented

## Naming

The naming rules follow the repository tooling configuration.

### Types

Use `CamelCase` for:

- classes
- structs
- enums
- type aliases
- typedefs
- template parameters

Examples:

```cpp
class MessageStore;
struct DeliveryResult;
enum class ConnectionState;
using UserId = std::uint64_t;
```

### Functions and Methods

Use `CamelCase` for functions and methods.

Examples:

```cpp
void SendMessage();
std::string FormatUserName();
```

### Variables

Use `lower_case` for:

- local variables
- parameters
- non-constant variables
- public members
- global variables only when absolutely necessary

Examples:

```cpp
int retry_count = 0;
std::string message_text;
```

### Private and Protected Members

Use `lower_case_` with a trailing underscore.

Examples:

```cpp
std::string name_;
int retry_count_;
```

### Constants

Use `CamelCase` for named constants.

Examples:

```cpp
constexpr int MaxRetries = 3;
constexpr std::size_t DefaultBufferSize = 4096;
```

### Macros

Use `UPPER_CASE`.

Macros should be rare. Prefer:

- `constexpr`
- `enum class`
- inline functions
- templates

## Includes

- Include only what you use.
- Prefer standard headers such as `<string>`, `<vector>`, and `<memory>`.
- Do not use `#include <bits/stdc++.h>` in normal project code.
- Keep includes ordered and formatter-friendly.
- Prefer project headers before implementation details when that improves clarity.

## Namespace Usage

- Do not write `using namespace std;` in shared code.
- Keep namespace imports narrow and local.
- Prefer explicit qualification when it improves readability.

Good:

```cpp
std::string name;
std::vector<int> values;
```

Avoid:

```cpp
using namespace std;
```

## File Organization

- Keep one clear responsibility per file.
- Put reusable implementation in library code, not in example/test drivers.
- Keep test-only helpers in test code unless they are reused by production code.
- Add headers when public interfaces become stable and intentionally shared.

## Functions

- Prefer short, focused functions.
- Use descriptive names.
- Pass data in the simplest correct form.
- Avoid hidden side effects.
- Return values should communicate success, failure, or computed results clearly.

## Classes and Structs

- Prefer `struct` for simple data aggregates.
- Prefer `class` when invariants or encapsulation matter.
- Keep ownership and lifetime rules obvious.
- Make constructors explicit when implicit conversion would be surprising.

## Error Handling

- Validate assumptions at the right boundary.
- Fail clearly and predictably.
- Do not ignore recoverable failures silently.
- Use assertions for programmer errors, not runtime control flow.

## Memory and Resource Management

- Prefer RAII.
- Prefer standard containers and smart pointers where ownership is dynamic.
- Avoid raw owning pointers.
- Keep ownership obvious in APIs.

## Comments and Documentation

- Write code that mostly explains itself.
- Add comments when intent is not obvious from the code alone.
- Document invariants, assumptions, edge cases, and non-obvious tradeoffs.
- Do not add redundant comments that only restate the code.
- Add Doxygen-friendly comments to public headers and public APIs when they define part of the intended project surface.

Good comment:

```cpp
// Retry once because the server may close an idle connection between heartbeats.
```

Weak comment:

```cpp
// Increment i
++i;
```

### Public API Documentation

- Treat `lib/interface.hpp` and headers under `lib/interfaces/` as the public API surface.
- Public declarations should have concise Doxygen comments when their purpose or usage is not obvious.
- Prefer documenting behavior, inputs, outputs, ownership, and important constraints.
- Keep implementation-heavy commentary in source files unless it is required to use the API correctly.

## Testing Expectations

- Add or update tests for behavior changes when practical.
- Keep tests readable and behavior-focused.
- Prefer targeted unit tests over broad fragile tests.
- Do not rely only on manual testing when behavior can be checked automatically.

## Warnings and Quality Gates

Before submitting changes, aim to pass:

```sh
cmake --preset debug
cmake --build --preset debug
ctest --test-dir build/debug --output-on-failure
cmake --build --preset debug --target format-check
cmake --build --preset debug --target tidy
```

## Preferred Change Style

- Choose the smallest correct change.
- Do not add abstractions before they are needed.
- Do not introduce compatibility code without a real consumer or requirement.
- Keep unrelated cleanup separate from behavioral changes.
