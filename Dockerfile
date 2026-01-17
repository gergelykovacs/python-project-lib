#
# Dockerfile for building a client
#
FROM python:3.14-slim-bookworm

WORKDIR /app

USER root

RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd -r nonroot_usr && useradd -r -g nonroot_usr nonroot_usr

COPY pyproject.toml .
COPY requirements.txt .
COPY dist dist
COPY client/client.py client.py

#RUN pip config set global.index-url https://nexus.mycompany.com/repository/pypi-packages/simple
#RUN pip config set global.trusted-host nexus.mycompany.com

RUN pip install /app/dist/*.whl
RUN pip install -r requirements.txt

RUN rm -rf dist

RUN chown -R nonroot_usr:nonroot_usr /app

USER nonroot_usr

CMD ["python3", "client.py"]
