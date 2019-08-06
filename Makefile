SHELL:=/bin/bash
ABSDIR:=$(shell python -c 'import os; print(os.path.realpath("."))')
REFDIR:=$(shell python -c 'import os; print(os.path.realpath("ref"))')
export NXF_VER:=19.01.0
./nextflow:
	curl -fsSL get.nextflow.io | bash
install: ./nextflow

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
