SHELL:=/bin/bash
ABSDIR:=$(shell python -c 'import os; print(os.path.realpath("."))')
REFDIR:=$(shell python -c 'import os; print(os.path.realpath("ref"))')
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
	@wget "$(CONDAURL)" && \
	bash "$(CONDASH)" -b -p conda && \
	rm -f "$(CONDASH)"

conda-install: conda
	conda install -y -c bioconda \
    ensembl-vep=96.0

run: ./nextflow
	./nextflow run main.nf

clean:
	rm -f trace*.txt.*
	rm -f .nextflow.log.*
	rm -f *.html.*
	rm -f .nextflow.log
	rm -f trace*.txt*
	rm -f *.html*

# [ -d work ] && mv work oldwork && rm -rf oldwork &
# [ -d output ] && mv output oldoutput && rm -rf oldoutput &
