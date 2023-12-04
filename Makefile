#!/usr/bin/make

SHELL = /bin/sh

UID := $(shell id -u)
GID := $(shell id -g)

export UID
export GID

shell:
	docker exec -it laravel-boilerplate-app-container bash -c "sudo -u app-user /bin/bash"

up:
	UID=${UID} GID=${GID} docker-compose -f docker-compose.yml --env-file ./docker-configs/.env --profile main up --build -d --remove-orphans

down:
	docker-compose -f docker-compose.yml --profile main down --remove-orphans

up-scan:
	UID=${UID} GID=${GID} docker-compose -f docker-compose.yml --env-file ./docker-configs/.env --profile sonarqube up --build -d --remove-orphans

scan:
	UID=${UID} GID=${GID} docker-compose restart laravel-boilerplate-sonarqube-scanner && docker logs -f laravel-boilerplate-sonarqube-scanner-container

down-scan:
	docker-compose -f docker-compose.yml --profile sonarqube down --remove-orphans