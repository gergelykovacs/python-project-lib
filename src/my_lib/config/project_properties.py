import json
from importlib.resources import files


class ProjectProperties:
    def name(self) -> str:
        resource_path = files("my_lib.resources").joinpath("project_properties.json")
        json_content = resource_path.read_text(encoding="utf-8")
        config = json.loads(json_content)
        return config.get("name")
