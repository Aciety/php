NAME = aciety/php
VERSION = debug

.PHONY: all

all: build

build:
	docker pull php:7.0-fpm
	docker build -t $(NAME):$(VERSION) --rm .

