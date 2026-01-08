# Variables
PYTHON := python3
PIP := pip
PIP_COMPILE := pip-compile
RUFF := ruff
TWINE := twine

# Default target (runs when you just type "make")
.PHONY: all
all: install lint test

# --- Dependency Management ---

# Lock: Generates requirements.txt from pyproject.toml
# Java Equivalent: mvn versions:update-properties / Dependency Locking
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
# Java Equivalent: mvn install
.PHONY: install
install:
	@echo "📦 Installing dependencies..."
	$(PIP) install -r requirements.txt
	$(PIP) install -e ".[dev]"
	@echo "✅ Environment synced."

# --- Quality Assurance (Linting & Testing) ---

# Lint: Checks code style without modifying files
# Java Equivalent: mvn checkstyle:check
.PHONY: lint
lint:
	@echo "🔍 Linting code..."
	$(RUFF) check .
	$(RUFF) format --check .
	@echo "✅ Lint check passed."

# Format: Automatically fixes code style issues
# Java Equivalent: mvn spotless:apply
.PHONY: format
format:
	@echo "💅 Formatting code..."
	$(RUFF) check --fix .
	$(RUFF) format .
	@echo "✅ Code formatted."

# Test: Runs the unit/integration tests
# Java Equivalent: mvn test
.PHONY: test
test:
	@echo "🧪 Running tests..."
	pytest

# --- Packaging & Publishing ---

# Build: Creates the distribution files (Wheel & Tarball)
# Java Equivalent: mvn package
.PHONY: build
build: clean
	@echo "🏗️  Building package..."
	$(PYTHON) -m build
	@echo "✅ Build complete. Artifacts in dist/"

# Publish: Uploads artifacts to the repository
# Java Equivalent: mvn deploy
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
# Java Equivalent: mvn clean
.PHONY: clean
clean:
	@echo "🧹 Cleaning up..."
	rm -rf dist/ build/ *.egg-info .pytest_cache .coverage .ruff_cache
	find . -type d -name __pycache__ -exec rm -r {} +
	@echo "✅ Clean complete."