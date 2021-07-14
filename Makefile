all: python_3.9.6 python_3.8.11 python_3.7.11 python_3.6.14
	docker build .

python_%:
	docker build --build-arg PYENV_VERSION=$(word 2,$(subst _, ,$@)) --build-arg OPTIMIZE=1 base
