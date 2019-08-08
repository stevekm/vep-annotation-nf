params.outputDir = "output"
// params.refDir = "ref" // in nextflow.config instead
params.ref_fa = "${params.refDir}/iGenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa"
params.ref_fai = "${params.refDir}/iGenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa.fai"
params.ref_dict = "${params.refDir}/iGenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.dict"

// ~~~~~ START WORKFLOW ~~~~~ //
log.info "~~~~~~~ VEP Pipeline ~~~~~~~"
log.info "* Project dir:        ${workflow.projectDir}"
log.info "* Launch dir:         ${workflow.launchDir}"
log.info "* Work dir:           ${workflow.workDir.toUriString()}"
log.info "* Profile:            ${workflow.profile ?: '-'}"
log.info "* Script name:        ${workflow.scriptName ?: '-'}"
log.info "* Script ID:          ${workflow.scriptId ?: '-'}"
log.info "* Container engine:   ${workflow.containerEngine?:'-'}"
log.info "* Workflow session:   ${workflow.sessionId}"
log.info "* Nextflow run name:  ${workflow.runName}"
log.info "* Nextflow version:   ${workflow.nextflow.version}, build ${workflow.nextflow.build} (${workflow.nextflow.timestamp})"
log.info "* Launch command:\n${workflow.commandLine}\n"

Channel.fromPath( file(params.ref_fa) )
.into{ ref_fa;
    ref_fa2
}

Channel.fromPath( file(params.ref_fai) )
.into{ ref_fai;
ref_fai2
}

Channel.fromPath( file(params.ref_dict) )
.into{ ref_dict;
    ref_dict2
}

Channel.fromPath("variants/**.vcf").map { item ->
    def sampleID = "${item.getName()}".replaceFirst(/.vcf$/, "")
    return([sampleID, item])
}.set { input_vcfs }

process download_ref {
    // http://useast.ensembl.org/info/docs/tools/vep/script/vep_cache.html#cache
    // ftp://ftp.ensembl.org/pub/release-96/variation/vep/
    // GRCh37 : hg19
    // GRCh38 : hg38
    storeDir "${params.VEP_refDir}"

    output:
    file("homo_sapiens_vep_96_GRCh37") into vep_ref_dir

    script:
    """
    curl -O ftp://ftp.ensembl.org/pub/release-96/variation/indexed_vep_cache/homo_sapiens_vep_96_GRCh37.tar.gz && \
    mkdir -p homo_sapiens_vep_96_GRCh37 && \
    mv homo_sapiens_vep_96_GRCh37.tar.gz homo_sapiens_vep_96_GRCh37/ && \
    (
        cd homo_sapiens_vep_96_GRCh37 && \
        tar xzf homo_sapiens_vep_96_GRCh37.tar.gz
        )
    """
    // gencode	GENCODE 19
    // HGMD-PUBLIC	20174
    // genebuild	2011-04
    // assembly	GRCh37.p13
    // polyphen	2.2.2
    // gnomAD	r2.1
    // ESP	20141103
    // dbSNP	151
    // sift	sift5.2.2
    // ClinVar	201810
    // 1000genomes	phase3
    // regbuild	1.0
    // COSMIC	86
}
vep_ref_dir.map{ item ->
    def assembly = "GRCh37"
    return([item, assembly])
}.set{ vep_ref_dir_assembly }

process vep {
    // http://useast.ensembl.org/info/docs/tools/vep/script/vep_options.html#basic
    tag "${sampleID}"
    publishDir "${params.outputDir}/VEP/raw", mode: 'copy'

    input:
    set val(sampleID), file(vcf), file(ref_dir), val(assembly), file(refFasta), file(refFai), file(refDict) from input_vcfs.combine(vep_ref_dir_assembly)
        .combine(ref_fa)
        .combine(ref_fai)
        .combine(ref_dict)

    output:
    set val(sampleID), file("${output_file}") into vcf_annotated
    file("${output_html}")

    script:
    prefix = "${sampleID}"
    output_file = "${prefix}.vep.vcf"
    output_html = "${vcf}".replaceFirst(/.vcf$/, ".vep.vcf_summary.html")
    """
    vep \
    --offline \
    --cache \
    --dir "${ref_dir}" \
    --assembly "${assembly}" \
    --fasta "${refFasta}" \
    --hgvs \
    --hgvsg \
    --protein \
    --symbol \
    --ccds \
    --canonical \
    --biotype \
    --pubmed \
    -i "${vcf}" \
    --format vcf \
    -o "${output_file}" \
    --vcf
    """
}

process vcf_to_tsv {
    tag "${sampleID}"
    publishDir "${params.outputDir}/VEP/vcf_tsv", mode: 'copy'

    input:
    set val(sampleID), file(vcf), file(refFasta), file(refFai), file(refDict) from vcf_annotated.combine(ref_fa2)
        .combine(ref_fai2)
        .combine(ref_dict2)

    output:
    set val(sampleID), file("${output_file}") into tsv_annotations

    script:
    prefix = "${sampleID}"
    output_file = "${prefix}.vep.tsv"
    """
    gatk VariantsToTable \
    -R "${refFasta}" \
    --variant "${vcf}" \
    -F CHROM \
    -F POS \
    -F ID \
    -F REF \
    -F ALT \
    -F QUAL \
    -F FILTER \
    -F CSQ \
    --output "${output_file}"

    ##INFO=<ID=CSQ,Number=.,Type=String,Description="Consequence annotations from Ensembl VEP. Format: Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND|FLAGS|SYMBOL_SOURCE|HGNC_ID">
    """
}

process split_VEP_fields {
    tag "${sampleID}"
    publishDir "${params.outputDir}/VEP/tsv", mode: 'copy'

    input:
    set val(sampleID), file(tsv) from tsv_annotations

    output:
    file("${output_file}")

    script:
    prefix = "${sampleID}"
    output_file = "${prefix}.vep.reformat.tsv"
    """
    split-VEP-field.py -i "${tsv}" -o "${output_file}"
    """
}
