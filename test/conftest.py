from unittest.mock import patch

import pytest

from my_lib.calculator import Calculator


@pytest.fixture
def calculator():
    """
    Returns a Calculator instance.
    Scope is 'function' by default (new instance per test).
    """
    return Calculator()


@pytest.fixture
def mock_project_properties():
    """
    Returns a mocked ProjectProperties instance.
    Patches 'my_lib.calculator.ProjectProperties'
    because Calculator imports it directly.
    """
    with patch("my_lib.calculator.ProjectProperties") as MockClass:
        mock_instance = MockClass.return_value
        mock_instance.name.return_value = "Mocked Project Name"
        yield mock_instance
