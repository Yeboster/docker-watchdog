.PHONY: help

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

help:
		@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
		@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


build: ## Build the Docker image
		sudo docker-compose build --no-cache \
        --build-arg APP_NAME=$(APP_NAME) \
        --build-arg APP_VSN=$(APP_VSN)

up: ## Run the app in Docker
		sudo docker-compose up -d

down: ## Stop the container
		sudo docker-compose down 

console: ## Open the console
		sudo docker run --rm -it watchdog /opt/app/bin/$(APP_NAME) console

env-vars:
		export PG_DB=watchdog_bot PG_USER=postgres PG_PASS=postgres PG_HOST=postgres
