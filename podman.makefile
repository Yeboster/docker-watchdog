.PHONY: help

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

help:
		@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
		@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


build: ## Build the Container image
	sudo podman build -t $(APP_NAME):latest -f ./Dockerfile \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN)

up: ## Run the app in Container
	sudo podman pod create --name $(APP_NAME)
	sudo podman pod create --publish 172.22.1.0:5432:5432 --name db
	sudo podman run --pod db \
		-e POSTGRES_DB=main -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres \
		-d --name postgres postgres
	sudo podman run --name=watchdog --pod=$(APP_NAME) \
		-e TG_TOK -e PG_DB=watchdog_docker -e PG_USER=postgres -e PG_PASS=postgres -e PG_HOST=postgres \
		--mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock \
		--add-host watchdog:127.0.0.1 --add-host watchdog:127.0.0.1 $(APP_NAME):latest

	sudo podman run 

down: ## Stop the containers
	sudo podman pod stop watchdog
	sudo podman pod stop db
	sudo podman pod rm watchdog
	sudo podman pod rm db

console: ## Open the elixir console
		sudo podman run --rm -it $(APP_NAME) /opt/app/bin/$(APP_NAME) console

env-vars: ## Export envvars for Elixir
		export PG_DB=watchdog_bot PG_USER=postgres PG_PASS=postgres PG_HOST=172.22.4.2
