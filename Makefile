# Variables
PYTHON := python3
PIP := pip
PIP_COMPILE := pip-compile
RUFF := ruff
PYTEST := pytest
TWINE := twine

# Default target (runs when you just type "make")
.PHONY: all
all: lock install upgrade lint test build

# --- Dependency Management ---

.PHONY: venv
venv:
	@echo "🛠 Creating virtual environment..."
	$(PYTHON) -m venv .venv
	@. ./.venv/bin/activate
	@echo "✅ virtual environment created."

# Lock: Generates requirements.txt from pyproject.toml
.PHONY: lock
lock:
	@echo "🔒 Locking dependencies..."
	$(PIP_COMPILE) -o requirements.txt pyproject.toml --resolver=backtracking
	@echo "✅ requirements.txt generated."

# Upgrade: Updates all packages to the latest allowed versions
.PHONY: upgrade
upgrade:
	@echo "⬆️  Upgrading dependencies..."
	$(PIP_COMPILE) --upgrade -o requirements.txt pyproject.toml --resolver=backtracking
	@echo "✅ requirements.txt upgraded."

# Install: Syncs environment with locked deps and installs the app
.PHONY: install
install:
	@echo "📦 Installing dependencies..."
	$(PIP) install -r requirements.txt
	$(PIP) install -e ".[dev]"
	@echo "✅ Environment synced."

# --- Quality Assurance (Linting & Testing) ---

# Lint: Checks code style without modifying files
.PHONY: lint
lint:
	@echo "🔍 Linting code..."
	$(RUFF) check .
	$(RUFF) format --check .
	@echo "✅ Lint check passed."

# Format: Automatically fixes code style issues
.PHONY: format
format:
	@echo "💅 Formatting code..."
	$(RUFF) check --fix .
	$(RUFF) format .
	@echo "✅ Code formatted."

# Test: Runs the unit/integration tests
.PHONY: test
test:
	@echo "🧪 Running tests..."
	$(PYTEST)

# --- Packaging & Publishing ---

# Build: Creates the distribution files (Wheel & Tarball)
.PHONY: build
build: clean
	@echo "🏗️  Building package..."
	$(PYTHON) -m build
	@echo "✅ Build complete. Artifacts in dist/"

# Publish: Uploads artifacts to the repository
# Usage: make publish repo=nexus
.PHONY: publish
publish: build
	@echo "🚀 Publishing to repository..."
	# If 'repo' arg is provided, use it; otherwise default to standard upload
ifdef repo
	$(TWINE) upload --repository $(repo) dist/*
else
	$(TWINE) upload dist/*
endif
	@echo "✅ Published successfully."

# --- Utilities ---

# Clean: Removes build artifacts and caches
.PHONY: clean
clean:
	@echo "🧹 Cleaning up..."
	rm -rf dist/ build/ *.egg-info src/*.egg-info .pytest_cache .coverage test/.coverage .ruff_cache
	find . -type d -name __pycache__ -exec rm -r {} +
	@echo "✅ Clean complete."