# Python Project - Library (Module)

Python Project Blueprint

## Development

Check the [Makefile](./Makefile) for automation as the initial step, it defines all project commands.

### Make Commands

| Make Command               | Description                                                                             |
|:---------------------------|:----------------------------------------------------------------------------------------|
| `make venv`                | Creates a virtual environment in `.venv`.                                               |
| `make lock`                | Generates `requirements.txt` from `pyproject.toml` using `pip-compile`.                 |
| `make upgrade`             | Updates all packages in `requirements.txt` to the latest allowed versions.              |
| `make install`             | Syncs the environment with locked dependencies and installs the app in editable mode.   |
| `make setup`               | Installs dependencies and sets up git hooks (runs `install` and `pre-commit install`).  |
| `make outdated`            | Checks for newer versions of dependencies using `pip-check-updates`.                    |
| `make pip-upgrade`         | Upgrades `pip` to its latest version.                                                   |
| `make lint`                | Checks code style using `ruff` without modifying files.                                 |
| `make format`              | Automatically fixes code style issues using `ruff`.                                     |
| `make security`            | Runs `bandit` to check for security vulnerabilities.                                    |
| `make test`                | Runs unit and integration tests using `pytest` (also runs `security`).                  |
| `make sbom`                | Generates a Software Bill of Materials (SBOM) in `sbom.json`.                           |
| `make audit`               | Generates a security audit report in `audit.json`.                                      |
| `make build`               | Creates distribution files (Wheel & Tarball) in `dist/`.                                |
| `make publish`             | Uploads artifacts to the repository using `twine`.                                      |
| `make docker-build`        | Builds the Docker image for the application.                                            |
| `make docker-run`          | Runs the Docker container with mounted volumes for testing.                             |
| `make docker-build-lambda` | Builds the Lambda Docker image.                                                         |
| `make docker-run-lambda`   | Runs the Lambda Docker container.                                                       |
| `make lambda-invoke`       | Invokes the Lambda function locally.                                                    |
| `make docs`                | Generates documentation from docstrings into the `docs/` directory.                     |
| `make clean`               | Removes build artifacts, caches, and generated files.                                   |
| `make all`                 | Runs the full development cycle: `lock`, `install`, `upgrade`, `lint`, `test`, `build`. |

The `make publish` require 

```shell
export TWINE_USERNAME=your_ldap_user
export TWINE_PASSWORD=your_ldap_password
export TWINE_REPOSITORY_URL="https://nexus.mycompany.com/repository/pypi-internal/"
```

environment variables.

## Usage

Once the library (module) is published or just built locally, it can be used.

### Exposing the library as a CLI

The library can be exposed as a CLI program `calc-cli`. The `make install` will create a local executable as 
[./.venv/bin/calc-cli](./.venv/bin/calc-cli).

```shell
calc-cli --operation add --a 1 --b 2
calc-cli -o add -a 1 -b 2

calc-cli --operation divide --a 1 --b 2
calc-cli -o divide -a 1 -b 2
```

To install the calculator CLI `calc-cli` and the library use `pipx`.

```shell
brew install pipx

pipx install my-lib            # if the library is already published
pipx install /path/to/my-lib/  # if it needs to be installed from source; my-lib/ is the project root not the dist/ folder

pipx uninstall my-lib # to remove the CLI; the name here must be the package name regardless how it was installed
```

### Containerised Library Examples

Two examples are provided in the [client](./client) directory.

1. [Lambda](./client/lambda_function.py) - AWS Lambda function.
2. [Python CLI](./client/client.py) – Python CLI application.

These are both containerised and can be run locally.

### Installing from a repository

```toml
# ~/.config/pip/pip.conf
[global]
index-url = https://nexus.mycompany.com/repository/pypi-group/simple
trusted-host = nexus.mycompany.com
```

```shell
pip install my_app==0.1.0
```

### Installing from local package

```shell
pip install /path/to/my_project/dist/my_lib-0.1.0-py3-none-any.whl
```

### Using the library or module

A sample client application can be found in the [client](./client) directory.

## Notes

### Deployments

A library can be containerised and deployed example to AWS as Lambda or to Kubernetes.

- Place infrastructure IaC in the [infrastructure](./infrastructure) directory to build and maintain infrastructure as code.
- Place Helm Chart in the [charts](./charts) directory for Kubernetes deployment.

### Testing git hooks

Install git pre-commit hook by running `make setup`.

To test it, add the following `bad.py` to [src/my_lib](./src/my_lib).

```python

import yaml
with open("bad.yaml") as f:
    data = yaml.load(f)
    print(data)
```

Run

```shell
git add -A
git commit -m 'Testing git hook' 
```

1. Fix linting issues by running `make format`.
2. Then observe security issue when trying to commit.

Finally remove the `bad.py` file.

### Troubleshooting

If virtualenv gets broken it will not expose binaries properly example:

```shell
make test
make: pytest: No such file or directory
```

In such case reset it by:

```shell
rm -rf .venv
make venv
make install
```

### Deployment alternative configuration

Twine accepts configuration from `~/.pypirc`

```toml
# ~/.pypirc
[distutils]
index-servers =
    nexus

[nexus]
# NOTE: Ensure this URL ends with a trailing slash
repository = https://nexus.mycompany.com/repository/pypi-internal/
username = your_ldap_user
password = your_ldap_password
```

and

```shell
make publish repo=nexus
```

command can be used to publish the artefacts.

## References

- [Python](https://www.python.org)
- [Python - Releases](https://www.python.org/downloads/)
- [Python 3.14 - Documentation](https://docs.python.org/3.14/)
- [PIP](https://pip.pypa.io/en/stable/)
- [PyPI - Package Index](https://pypi.org)
- [pyproject.toml](https://packaging.python.org/en/latest/guides/writing-pyproject-toml/)
- [PyTest](https://docs.pytest.org/en/stable/)
- [Ruff - Linting](https://docs.astral.sh/ruff/)
- [Twine - Package Publishing](https://twine.readthedocs.io/en/stable/)
- [Emoji Library](https://openmoji.org/library/) - Used in Makefile
