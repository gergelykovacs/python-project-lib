import json

import pytest
from aws_lambda_typing.events import APIGatewayProxyEventV1

from lambda_function import handler


@pytest.fixture
def make_event():
    """Helper to build a type-safe API Gateway V1 event."""

    def _make(body: dict) -> APIGatewayProxyEventV1:
        return APIGatewayProxyEventV1(
            body=json.dumps(body),
            resource="",
            path="/",
            httpMethod="POST",
            headers={},
            multiValueHeaders={},
            queryStringParameters=None,
            multiValueQueryStringParameters=None,
            pathParameters=None,
            stageVariables=None,
            requestContext=None,  # type: ignore[arg-type]
            isBase64Encoded=False,
        )

    return _make


class TestHandler:
    """Tests mirroring the Makefile lambda-invoke scenarios."""

    def test_add(self, make_event):
        result = handler(make_event({"operation": "add", "a": "2", "b": "3"}), None)
        assert result["statusCode"] == 200
        assert json.loads(result["body"])["result"] == 5

    def test_add_missing_b_defaults_to_zero(self, make_event):
        result = handler(make_event({"operation": "add", "a": "2"}), None)
        assert result["statusCode"] == 200
        assert json.loads(result["body"])["result"] == 2

    def test_divide(self, make_event):
        result = handler(make_event({"operation": "divide", "a": "3", "b": "2"}), None)
        assert result["statusCode"] == 200
        assert json.loads(result["body"])["result"] == 1.5

    def test_divide_missing_a_defaults_to_zero(self, make_event):
        result = handler(make_event({"operation": "divide", "b": "2"}), None)
        assert result["statusCode"] == 200
        assert json.loads(result["body"])["result"] == 0.0

    def test_divide_by_zero(self, make_event):
        result = handler(make_event({"operation": "divide", "a": "3", "b": "0"}), None)
        assert result["statusCode"] == 400
        assert "Cannot divide by zero" in result["body"]

    def test_missing_operation_defaults_to_invalid(self, make_event):
        result = handler(make_event({"a": "3", "b": "2"}), None)
        assert result["statusCode"] == 400
        assert "Invalid operation" in result["body"]
