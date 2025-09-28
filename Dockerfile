# Build stage - install dependencies and tools
FROM python:3.12-slim AS builder

# Install uv package manager directly
RUN pip install uv

# install uv package manager the below doesn't work, so I had to use pip install as the direct package manager
#COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set working directory to match your project structure
WORKDIR /simple-server-RoshniSingh101

# copy dependency files first (for better caching)
COPY pyproject.toml ./

# install dependencies without the project itself
RUN uv sync --no-install-project --no-editable

# Copy source code
COPY . .

# install the complete project
RUN uv sync --no-editable

# final stage - runtime environment
FROM python:3.12-slim

# install uvicorn directly if it's not in dependencies
RUN pip install uvicorn

# set up virtual environment variables
ENV VIRTUAL_ENV=/simple-server-RoshniSingh101/.venv
ENV PATH="/simple-server-RoshniSingh101/.venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

# set working directory
WORKDIR /simple-server-RoshniSingh101

# copy the virtual environment from builder
COPY --from=builder /simple-server-RoshniSingh101/.venv /simple-server-RoshniSingh101/.venv

EXPOSE 8000

CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]