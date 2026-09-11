DOCKER_USER=seregaant
IMAGE_NAME=lab

IMAGE := $(DOCKER_USER)/$(IMAGE_NAME)
TAG := $(shell date +%Y%m%d-%H%M%S)

.PHONY: build push release

build:
	docker build -t $(IMAGE):$(TAG) -t $(IMAGE):latest .

push:
	docker push $(IMAGE):$(TAG)
	docker push $(IMAGE):latest

release: build push
	@echo "Pushed $(IMAGE):$(TAG)"
	@echo "Pushed $(IMAGE):latest"