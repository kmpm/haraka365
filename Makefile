NAME=kmpm/haraka365



.PHONY: build
build:
	docker build -t $(NAME):latest .


bash:
	docker run --rm -it $(NAME) bash

run:
	docker run --rm -v "haraka365:/app/config" $(NAME) 