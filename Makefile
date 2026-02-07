SHELL := /bin/bash

COMPOSE_FILE := compose/local-stack.yml
ENV_FILE := .env

.PHONY: help env up down restart logs ps clean rebuild

help:
	@echo "Devtools commands:"
	@echo "  make env      - create .env from .env.template if missing"
	@echo "  make up       - build and start the local stack"
	@echo "  make down     - stop the local stack"
	@echo "  make restart  - restart the local stack"
	@echo "  make logs     - tail logs"
	@echo "  make ps       - show running services"
	@echo "  make clean    - stop stack and remove volumes"
	@echo "  make rebuild  - rebuild images and start"

env:
	@if [ ! -f "$(ENV_FILE)" ]; then \
		cp .env.template $(ENV_FILE); \
		echo "Created $(ENV_FILE) from .env.template"; \
	else \
		echo "$(ENV_FILE) already exists"; \
	fi

up: env
	docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE) up --build

down:
	docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE) down

restart: down up

logs:
	docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE) logs -f

ps:
	docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE) ps

clean:
	docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE) down -v --remove-orphans

rebuild: env
	docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE) up --build --force-recreate
