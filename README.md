# Python Project - Library (Module)

Python Project Blueprint

## Make automation

Check the [Makefile](./Makefile) for automation as a first step, it defines all project commands.

Short summary of commands in a desired order of use.

```shell
make venv # Create virtual environment (first)

make install # Install dependencies
mske lock    # Lock dependencies
make upgrade # Upgrade dependencies

make lint   # Check the code style
make format # Fix style issues
make test   # Run tests

make build # Create distributable packages (artefacts)

# Set repository access configurations
export TWINE_USERNAME=your_ldap_user
export TWINE_PASSWORD=your_ldap_password
export TWINE_REPOSITORY_URL="https://nexus.mycompany.com/repository/pypi-internal/"
make publish # Publish the artefacts

make clean # Remove all generated files

make all # In development (lock install upgrade lint test build)
```

## Usage

Once the library (module) is published or just built locally it can be used. 

### Installing from repository

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

```python
from my_lib.calculator import Calculator

calc = Calculator()
print(f"2 + 3 = {calc.add(2, 3)}")
```

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

## Notes

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
twine upload --repository nexus dist/*
```

command can be used to publish the artefacts.

## TODO

- Add more logic for tests, mocking and integration testing.
- Add distributed resource file.
