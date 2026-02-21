import json
from unittest.mock import MagicMock

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


@pytest.fixture
def mock_calculator(mocker) -> MagicMock:
    """Patches Calculator in lambda_function so the handler uses a mock."""
    mock_cls = mocker.patch("lambda_function.Calculator")
    return mock_cls.return_value


class TestHandler:
    """Tests mirroring the Makefile lambda-invoke scenarios."""

    def test_add(self, make_event, mock_calculator):
        mock_calculator.add.return_value = 5
        result = handler(make_event({"operation": "add", "a": "2", "b": "3"}), None)
        assert result["statusCode"] == 200
        assert json.loads(result["body"])["result"] == 5
        mock_calculator.add.assert_called_once_with(2, 3)
        mock_calculator.divide.assert_not_called()

    def test_add_missing_b_defaults_to_zero(self, make_event, mock_calculator):
        mock_calculator.add.return_value = 2
        result = handler(make_event({"operation": "add", "a": "2"}), None)
        assert result["statusCode"] == 200
        assert json.loads(result["body"])["result"] == 2
        mock_calculator.add.assert_called_once_with(2, 0)
        mock_calculator.divide.assert_not_called()

    def test_divide(self, make_event, mock_calculator):
        mock_calculator.divide.return_value = 1.5
        result = handler(make_event({"operation": "divide", "a": "3", "b": "2"}), None)
        assert result["statusCode"] == 200
        assert json.loads(result["body"])["result"] == 1.5
        mock_calculator.divide.assert_called_once_with(3, 2)
        mock_calculator.add.assert_not_called()

    def test_divide_missing_a_defaults_to_zero(self, make_event, mock_calculator):
        mock_calculator.divide.return_value = 0.0
        result = handler(make_event({"operation": "divide", "b": "2"}), None)
        assert result["statusCode"] == 200
        assert json.loads(result["body"])["result"] == 0.0
        mock_calculator.divide.assert_called_once_with(0, 2)
        mock_calculator.add.assert_not_called()

    def test_divide_by_zero(self, make_event, mock_calculator):
        mock_calculator.divide.side_effect = ValueError("Cannot divide by zero")
        result = handler(make_event({"operation": "divide", "a": "3", "b": "0"}), None)
        assert result["statusCode"] == 400
        assert "Cannot divide by zero" in result["body"]
        mock_calculator.add.assert_not_called()

    def test_missing_operation_defaults_to_invalid(self, make_event, mock_calculator):
        result = handler(make_event({"a": "3", "b": "2"}), None)
        assert result["statusCode"] == 400
        assert "Invalid operation" in result["body"]
        mock_calculator.add.assert_not_called()
        mock_calculator.divide.assert_not_called()
