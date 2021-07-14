all: python_3.9.6 python_3.8.11 python_3.7.11 python_3.6.14
	docker build .

version=$(word 2,$(subst _, ,$1))
tag = $(word 1,$(subst ., ,$(word 1,$2))).$(word 2,$(subst ., ,$(word 1,$2)))

python_%:
	$(eval VERSION := $(call version,$@))
	$(eval TAG := modern_python:$(call tag,$@,$(VERSION)))
	docker build --tag $(TAG) \
		--build-arg PYENV_VERSION=$(VERSION) \
		--build-arg OPTIMIZE=1 \
		base
	if [ ! -z "$(DOCKER_IMAGE_NAME)" ]; then docker tag $(TAG) $(DOCKER_IMAGE_NAME)/$(TAG); fi
