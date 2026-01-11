import json
from importlib.resources import files

class Calculator:
    def add(self, a: int, b: int) -> int:
        return a + b

    def divide(self, a: int, b: int) -> float:
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b

    def name(self) -> str:
        resource_path = files("my_lib.resources").joinpath("config.json")
        json_content = resource_path.read_text(encoding="utf-8")
        config = json.loads(json_content)
        return config.get("name")