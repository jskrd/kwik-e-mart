DOCKER_COMPOSE_FILE := deployments/docker-compose.yml

.PHONY: build down up

build:
	docker compose -f $(DOCKER_COMPOSE_FILE) --project-directory . build

down:
	docker compose -f $(DOCKER_COMPOSE_FILE) --project-directory . down

up:
	docker compose -f $(DOCKER_COMPOSE_FILE) --project-directory . up
