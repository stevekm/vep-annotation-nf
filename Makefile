SHELL:=/bin/bash
ABSDIR:=$(shell python -c 'import os; print(os.path.realpath("."))')
REFDIR:=$(shell python -c 'import os; print(os.path.realpath("ref"))')
HOSTNAME:=$(shell hostname)
UNAME:=$(shell uname)
export NXF_VER:=19.01.0
./nextflow:
	curl -fsSL get.nextflow.io | bash
install: ./nextflow

PATH:=$(CURDIR)/conda/bin:$(PATH)
unexport PYTHONPATH
unexport PYTHONHOME

ifeq ($(UNAME), Darwin)
CONDASH:=Miniconda3-4.5.4-MacOSX-x86_64.sh
endif

ifeq ($(UNAME), Linux)
CONDASH:=Miniconda3-4.5.4-Linux-x86_64.sh
endif

CONDAURL:=https://repo.continuum.io/miniconda/$(CONDASH)

conda:
	@echo ">>> Setting up conda..."
	wget "$(CONDAURL)" && \
	bash "$(CONDASH)" -b -p conda && \
	rm -f "$(CONDASH)"

conda-install: conda
	conda install -y -c bioconda \
    ensembl-vep=96.0 \
	gatk4=4.0.5.1

EP:=
run: ./nextflow
	if grep -q 'bigpurple' <<<'$(HOSTNAME)'; then ./nextflow run main.nf -resume -profile bigpurple ; \
	else ./nextflow run main.nf -resume $(EP) ; \
	fi


clean:
	rm -f trace*.txt.*
	rm -f .nextflow.log.*
	rm -f *.html.*
	rm -f .nextflow.log
	rm -f trace*.txt*
	rm -f *.html*

# for debugging
bash:
	bash

