NAME=kmpm/haraka365

VERSION=$(shell git describe --tags --always --long --dirty)
TAG=$(shell git describe --tags --abbrev=0)

.PHONY: build
build:
	docker build -t $(NAME):$(TAG) -t $(NAME):latest .

.PHONY: scan
scan:
	docker scan $(NAME):$(TAG)


.PHONY: publish
publish:
	docker publish $(NAME):$(TAG)
	docker publish $(NAME):latest


.PHONY: bash
bash:
	docker run --rm -it $(NAME) bash

.PHONY: run
run:
	docker run --rm -v "haraka365:/app/config" $(NAME) 