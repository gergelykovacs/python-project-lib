import pytest
from my_lib.calculator import Calculator


@pytest.fixture
def calculator():
    """
    Returns a Calculator instance.
    Scope is 'function' by default (new instance per test).
    """
    return Calculator()
