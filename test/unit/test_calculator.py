import pytest


def test_add_simple(calculator):
    # 'calculator' is injected automatically from conftest.py
    assert calculator.add(2, 3) == 5


def test_divide_by_zero(calculator):
    # Asserting exceptions
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        calculator.divide(10, 0)
