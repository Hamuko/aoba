# --------------- #
# BUILD CONTAINER #
# --------------- #

FROM python:3.13-slim AS build

ENV UV_LINK_MODE=copy

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project

COPY . /app

RUN --mount=type=cache,target=/root/.cache/uv uv sync --locked

RUN uv pip install gallery-dl yt-dlp

# ----------------- #
# RUNTIME CONTAINER #
# ----------------- #

FROM python:3.13-slim

COPY --from=build /app /app

WORKDIR /app

ENV PATH="/app/.venv/bin:$PATH"

CMD ["fastapi", "run", "src/aoba/__init__.py"]
