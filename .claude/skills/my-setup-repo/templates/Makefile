.PHONY: check lint typecheck test fmt test-up test-down install

check: lint typecheck test

lint:
	cd backend && uv run ruff check .
	cd frontend && npm run lint

typecheck:
	cd backend && uv run mypy src
	cd frontend && npm run typecheck

test: test-up
	cd backend && uv run pytest
	cd frontend && npm run test

fmt:
	cd backend && uv run ruff format . && uv run ruff check --fix .
	cd frontend && npm run format

test-up:
	docker compose -f docker-compose.test.yml up -d --wait

test-down:
	docker compose -f docker-compose.test.yml down -v

install:
	cd backend && uv sync
	cd frontend && npm ci
	uv run pre-commit install

types:
	cd frontend && npm run generate-types
