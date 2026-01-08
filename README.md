# Sample Python Project

## Make automation

Check [Makefile](./Makefile) for command automation.

## Install dependencies

```shell
# If install from toml
pip install -e ".[dev]"
# If install from lock txt
pip install -r requirements.txt
```

## Test

```shell
ruff check .
ruff format --check .
ruff format .
```

```shell
pytest
```

## Build and package

```shell
pip install pip-tools
# Generate lock file
pip-compile -o requirements.txt pyproject.toml
```

```shell
pip install build
python -m build
```

## Deploy

```shell
pip install twine
```

### Option 1

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

```shell
twine upload --repository nexus dist/*
```

### Option 2

```shell
export TWINE_USERNAME=your_ldap_user
export TWINE_PASSWORD=your_ldap_password
export TWINE_REPOSITORY_URL="https://nexus.mycompany.com/repository/pypi-internal/"

twine upload dist/*
```

## Usage

```toml
# ~/.config/pip/pip.conf
[global]
index-url = https://nexus.mycompany.com/repository/pypi-group/simple
trusted-host = nexus.mycompany.com
```

```shell
pip install my_app==0.1.0
```

Or locally

```shell
pip install /path/to/my_project/dist/my_app-0.1.0-py3-none-any.whl
```

Then

```python
from my_app.calculator import Calculator

calc = Calculator()
print(f"2 + 3 = {calc.add(2, 3)}")
```

## TODO

- Start version the project.
- Add test with testcontainers.
- Add more logic for tests, mocking and integration testing.
- Create new app in which there is a containerised app using this package.
