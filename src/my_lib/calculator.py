from my_lib.config.project_properties import ProjectProperties


class Calculator:
    def add(self, a: int, b: int) -> int:
        return a + b

    def divide(self, a: int, b: int) -> float:
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b

    def name(self) -> str:
        return ProjectProperties().name()
