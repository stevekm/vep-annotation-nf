SHELL:=/bin/bash
ABSDIR:=$(shell python -c 'import os; print(os.path.realpath("../variants"))')
DOCKERTAG:=stevekm:vep-96.0
docker-build:
	docker build -t "$(DOCKERTAG)" .

docker-test:
	docker run -v "$(ABSDIR)":/staging --rm -ti "$(DOCKERTAG)" bash
