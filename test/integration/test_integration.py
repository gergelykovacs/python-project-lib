import os


def test_external_service_mock(mocker):
    # Given: A mock of an external function (e.g., inside 'os')
    # This is equivalent to Mockito.when(...).thenReturn(...)
    mock_getcwd = mocker.patch("os.getcwd", return_value="/tmp")

    # When
    result = os.getcwd()

    # Then
    assert result == "/tmp"
    mock_getcwd.assert_called_once()
