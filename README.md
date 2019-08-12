# vep-annotation-nf

variant annotation workflow with VEP

# Installation

Clone this repo:

```
git clone https://github.com/stevekm/vep-annotation-nf.git
cd vep-annotation-nf
```

## Nextflow

Install `nextflow` in the current directory with the command in the Makefile.

```
make install
```

## VEP: Docker

To install VEP using Docker, run the Makefile command in the `container` directory.

```
cd container
make docker-build
```

## VEP: conda

To install VEP using `conda` (for NYULMC Big Purple HPC), instead run the `conda-install` recipe from the Makefile in the parent repo directory.

```
make conda-install
```

## Reference Files

VEP reference files will be downloaded automatically by the pipeline. However the hg19 genome fasta, fasta.fai, and fasta.dict files must also be obtained (not included). On NYULMC Big Purple, all required files are already cached and no download should be needed. On other systems, the command line arguments specifying the genome fasta files should be provided separately when running, or place the files `genome.fa`, `genome.fa.fai`, and `genome.dict` inside the included `ref` directory.

# Run

The Makefile includes shortcuts to help run the pipeline easier on NYULMC Big Purple HPC.

```
make run
```

The command can also be used to run on other systems, it will simply invoke the command:

```
./nextflow run main.nf -resume
```

Nextflow `params` values can be passed on the command line:

```
./nextflow run main.nf -resume --ref_fa /path/to/genome.fa --ref_fai /path/to/genome.fa.fai --ref_dict /path/to/genome.dict
```

# Output

Output files will be collected in the `output` directory.

# Software

Tested on RHEL 7, macOS 10.12

- Nextflow (Java 8+)

- `bash`

- GNU `make`
