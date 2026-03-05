# Variables
VENV_PATH := .venv/bin
SYSTEM_PYTHON := python3
PYTHON := $(VENV_PATH)/python3
PIP := $(VENV_PATH)/pip
PIP_COMPILE := $(VENV_PATH)/pip-compile
RUFF := $(VENV_PATH)/ruff
PYTEST := $(VENV_PATH)/pytest
TWINE := $(VENV_PATH)/twine
BANDIT := $(VENV_PATH)/bandit
PRECOMMIT := $(VENV_PATH)/pre-commit
PCU := $(VENV_PATH)/pcu
DOCKER := docker
VERSION := $(strip $(shell cat VERSION))

# Default target (runs when you just type "make")
.PHONY: all
all: lock install upgrade lint test build

# --- Dependency Management ---

.PHONY: venv
venv:
	@echo "🛠 Creating virtual environment..."
	$(SYSTEM_PYTHON) -m venv .venv
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
	@echo "⬆️ Upgrading dependencies..."
	$(PIP_COMPILE) --upgrade -o requirements.txt pyproject.toml --resolver=backtracking
	@echo "✅ requirements.txt upgraded."

# Install: Syncs environment with locked deps and installs the app
.PHONY: install
install:
	@echo "📦 Installing dependencies..."
	$(PIP) install -r requirements.txt
	$(PIP) install -e ".[dev]"
	@echo "✅ Environment synced."

# Setup: Installs dependencies and sets up git hooks
.PHONY: setup
setup: install
	@echo "🪝 Installing Git hooks..."
	$(PRECOMMIT) install
	@echo "✅ Setup complete."

# Outdated: Checks for newer versions of dependencies
.PHONY: outdated
outdated:
	@echo "🔍 Checking for newer versions of dependencies..."
	$(PCU) pyproject.toml -t latest --extra dev --fail_on_update
	@echo "✅ Dependency outdated check passed."

# compatibility: Checks each dependencies for python version compatibility
.PHONY: compatibility
compatibility:
	@echo "🔍 Checking dependencies for python version compatibility..."
ifdef py_version
	$(PYTHON) check_compatibility.py $(py_version)
else
	$(PYTHON) check_compatibility.py
endif
	@echo "✅ Compatibility check done."

# PIP Upgrade: upgrade PIP to its latest version
.PHONY: pip-upgrade
pip-upgrade:
	@echo "⬆️ Upgrading pip..."
	$(PIP) install --upgrade pip
	@echo "✅ pip upgraded."

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

# Security: Runs bandit to check for vulnerabilities
.PHONY: security
security:
	@echo "🛡️ Running security scan..."
	# -c: configuration file, -r: recursive
	$(BANDIT) -c pyproject.toml -r .
	@echo "✅ Security scan passed."

# Test: Runs the unit/integration tests
.PHONY: test
test: security
	@echo "🧪 Running tests..."
	$(PYTEST)

# SBOM: Generates Software Bill of Materials in CycloneDX JSON format
.PHONY: sbom
sbom: install
	@echo "📋 Generating SBOM..."
	$(VENV_PATH)/cyclonedx-py requirements requirements.txt -o sbom.json
	@echo "✅ SBOM generated as sbom.json"

# Audit: Generates security audit report in JSON format
.PHONY: audit
audit: install
	@echo "🔒 Running security audit..."
	$(VENV_PATH)/pip-audit -r requirements.txt --format=cyclonedx-json --output=audit.json
	@echo "✅ Security audit saved as audit.json"

# --- Packaging & Publishing ---

# Build: Creates the distribution files (Wheel & Tarball)
.PHONY: build
build: clean install
	@echo "🏗️ Building package..."
	$(PIP) install build
	$(PYTHON) -m build
	@echo "✅ Build complete. Artifacts in dist/"

# Docker Build: Creates the Docker image
.PHONY: docker-build
docker-build: build
	@echo "🏗️ Building the Docker image..."
	$(DOCKER) build -t my-lib-client:$(VERSION) .
	@echo "✅ Docker build complete."

# Docker Run: Runs the Docker container
.PHONY: docker-run
docker-run:
	@echo "🚀 Running the Docker container..."
	$(DOCKER) run --rm my-lib-client:$(VERSION)
	@echo "✅ Docker container stopped."

# Docker Build Lambda: Creates the Lambda Docker image
.PHONY: docker-build-lambda
docker-build-lambda: build
	@echo "🏗️ Building the Lambda Docker image..."
	$(DOCKER) build -f Dockerfile.lambda -t my-lib-lambda:$(VERSION) .
	@echo "✅ Docker build complete."

# Docker Run Lambda: Runs the Lambda Docker container
.PHONY: docker-run-lambda
docker-run-lambda:
	@echo "🚀 Running the Lambda Docker container..."
	$(DOCKER) run --rm -p 9000:8080 my-lib-lambda:$(VERSION)
	@echo "✅ Docker container stopped."

# Docker Run Lambda: Runs the Lambda Docker container
.PHONY: lambda-invoke
lambda-invoke:
	@echo "▶ Invoking the Lambda function..."
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"body": "{\"operation\": \"add\", \"a\": \"2\", \"b\": \"3\"}"}' | jq
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"body": "{\"operation\": \"add\", \"a\": \"2\"}"}' | jq
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"body": "{\"operation\": \"divide\", \"a\": \"3\", \"b\": \"2\"}"}' | jq
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"body": "{\"operation\": \"divide\", \"b\": \"2\"}"}' | jq
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"body": "{\"operation\": \"divide\", \"a\": \"3\", \"b\": \"0\"}"}' | jq
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"body": "{\"a\": \"3\", \"b\": \"2\"}"}' | jq
	@echo "✅ Done."

# Publish: Uploads artifacts to the repository
# Usage: make publish repo=nexus
.PHONY: publish
publish: build
	@echo "🚀 Publishing to repository..."
	# If 'repo' arg is provided, use it; otherwise default to standard upload
ifdef repo
	$(TWINE) upload --repository $(repo) dist/* --verbose > twine-publish.log 2>&1
else
	$(TWINE) upload dist/* --verbose > twine-publish.log 2>&1
endif
	@echo "✅ Published successfully."

# --- Utilities ---

 Docs: Generates documentation from docstrings in Markdown format
.PHONY: docs
docs: install
	@echo "📚 Generating documentation..."
	$(VENV_PATH)/pdoc -o docs src/my_lib src/my_lib/config
	@echo "✅ Documentation generated in docs/ directory"

# Clean: Removes build artifacts and caches
.PHONY: clean
clean:
	@echo "🧹 Cleaning up..."
	rm -rf docs/ dist/ build/ *.egg-info src/*.egg-info .pytest_cache .coverage test/.coverage .ruff_cache
	find . -type d -name __pycache__ -exec rm -r {} +
	@echo "✅ Clean complete."