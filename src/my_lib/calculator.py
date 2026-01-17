from my_lib.config.project_properties import ProjectProperties


class Calculator:
    """Sample calculator class for performing basic arithmetic operations."""

    def add(self, a: int, b: int) -> int:
        """Adds two integers."""
        return a + b

    def divide(self, a: int, b: int) -> float:
        """Divides two numbers."""
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b

    def name(self) -> str:
        """Returns the real name of the calculator."""
        return ProjectProperties().name()
