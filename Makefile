APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

build: ## Build the Docker image
    sudo docker-compose build --no-cache \
        --build-arg APP_NAME=$(APP_NAME) \
        --build-arg APP_VSN=$(APP_VSN)

run: ## Run the app in Docker
    sudo docker-compose up -d
