SHELL:=/bin/bash
ABSDIR:=$(shell python -c 'import os; print(os.path.realpath("../variants"))')
DOCKERREPO:=stevekm
VAR:=vep-96.0
DOCKERTAG:=$(DOCKERREPO):$(VAR)
docker-build:
	docker build -t "$(DOCKERTAG)" .

docker-test:
	docker run -v "$(ABSDIR)":/staging --rm -ti "$(DOCKERTAG)" bash
