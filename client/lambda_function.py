import json
import logging
from typing import Any, Dict

from aws_lambda_typing.context import Context
from aws_lambda_typing.events import APIGatewayProxyEventV1

from my_lib.calculator import Calculator

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event: APIGatewayProxyEventV1, context: Context) -> Dict[str, Any]:
    event.setdefault("body", "{}")
    body: Dict[str, str] = json.loads(event.get("body"))
    body.setdefault("operation", "none")
    body.setdefault("a", "0")
    body.setdefault("b", "0")
    logger.info(f"operation={body.get('operation')}, a={body.get('a')}, b={body.get('b')}")
    operation = body.get("operation")
    a = int(body.get("a"))
    b = int(body.get("b"))
    calculator = Calculator()
    try:
        match operation:
            case "add":
                result = calculator.add(a, b)
            case "divide":
                result = calculator.divide(a, b)
            case _:
                raise ValueError(f"Invalid operation: {operation}")
    except ValueError as e:
        return {"statusCode": 400, "body": str(e)}
    return {
        "statusCode": 200,
        "body": json.dumps({"result": result}),
        "headers": {"Content-Type": "application/json"},
        "isBase64Encoded": False,
    }
