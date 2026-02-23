# Project Guidelines

## Core Tech Stack
- **Primary Language:** Python 3.12+
- **Framework:** N/A (this is a custom library)
- **Type Checking:** Strictly use Python Type Hints (`mypy` compatible).
- **Documentation:** Use Google-style docstrings for all public functions and classes.

## Development Standards
- **Coding Style:** Adhere strictly to PEP 8.
- **Async Patterns:** Prefer `async/await` for all I/O bound operations.
- **Error Handling:** Use custom exception classes; avoid "bare" `except:` blocks.
- **Dependency Injection:** N/A (this is a custom library).

## Project Architecture
- **Location:** Source code is organized under `src/my_lib/` and `client/` folders.
- **Structure:** Configuration in `config/`, static resource files in `resources/`, and entry points in `calculator.py`.
- **Refactoring:** When modifying existing code, maintain the existing variable naming conventions unless they violate PEP 8.
- **Imports:** Use relative imports (e.g., `from .service import ExampleService`).

## Testing Requirements
- **Framework:** Use `pytest`.
- **Coverage:** Aim for 80%+ coverage on all new logic.
- **Mocks:** Use `unittest.mock` or `pytest-mock` for external API calls.
- **Location:** All tests for `src/my_lib/` must reside in the `tests/` directory, mirroring the source structure without the `my_lib/` directory path prefix. Tests for `client/` folder files must be placed in the `client/` folder.

## Performance & Optimization
- **Memory:** Avoid loading large datasets into memory; use generators or streaming where possible.
- **Efficiency:** Prioritize `list comprehensions` over manual `for` loops for simple transformations.

## Agent Behavior
- **Analysis:** Before writing code, explain your plan in 2-3 bullet points.
- **Context:** If a task requires knowledge of a file not currently open, ask me to open it or use your indexing to find it.
- **Safety:** Do not delete files or large blocks of code without explicit confirmation.