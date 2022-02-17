NAME=kmpm/haraka365

VERSION=$(shell git describe --tags --always --long --dirty)
TAG=$(shell git describe --tags --abbrev=0)

.PHONY: build
build:
	docker build -t $(NAME):latest -t $(NAME):$(TAG) -t .


bash:
	docker run --rm -it $(NAME) bash

run:

	docker run --rm -v "haraka365:/app/config" $(NAME) 