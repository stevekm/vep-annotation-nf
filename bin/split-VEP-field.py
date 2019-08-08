#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Splits the 'CSQ' column in a .tsv formatted table
CSQ: Consequence annotation column output by VEP
meant to be used with VEP .vcf output, converted to .tsv with GATK VariantsToTable

##INFO=<ID=CSQ,Number=.,Type=String,Description="Consequence annotations from Ensembl VEP. Format: Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND|FLAGS|SYMBOL_SOURCE|HGNC_ID">

##INFO=<ID=CSQ,Number=.,Type=String,Description="Consequence annotations from Ensembl VEP. Format: Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND|FLAGS|SYMBOL_SOURCE|HGNC_ID|CANONICAL|CCDS|ENSP|HGVS_OFFSET|HGVSg|CLIN_SIG|SOMATIC|PHENO|PUBMED">
"""
import csv
import sys
import argparse

def get_CSQ_cols(csq_key_txt):
    """
    reads in the list of CSQ columns from text file
    """
    cols = []
    with open(csq_key_txt) as f:
        for line in f:
            cols.append(line.strip())
    return(cols)

def main(**kwargs):
    """
    Main control function for the script
    """
    input_file = kwargs.pop('input_file', None)
    output_file = kwargs.pop('output_file', None)
    csq_key = kwargs.pop('csq_key')

    CSQ_cols = get_CSQ_cols(csq_key)

    if input_file:
        fin = open(input_file)
    else:
        fin = sys.stdin

    if output_file:
        fout = open(output_file, "w")
    else:
        fout = sys.stdout

    reader = csv.DictReader(fin, delimiter = '\t')
    old_fieldnames = reader.fieldnames
    new_fieldnames = [ n for n in old_fieldnames if n != 'CSQ' ]

    for colname in CSQ_cols:
        new_fieldnames.append(colname)

    writer = csv.DictWriter(fout, delimiter = '\t', fieldnames = new_fieldnames)
    writer.writeheader()

    for row in reader:
        parts = row['CSQ'].split('|')
        for i, colname in enumerate(CSQ_cols):
            row[colname] = parts[i]

        row.pop('CSQ')

        writer.writerow(row)

    fout.close()
    fin.close()


def parse():
    """
    Parses script args
    """
    parser = argparse.ArgumentParser(description='Splits the CSQ column in a .tsv formatted table from VEP output')
    parser.add_argument("-i", default = None, dest = 'input_file', help="Input file")
    parser.add_argument("-o", default = None, dest = 'output_file', help="Output file")
    parser.add_argument("-k", default = None, dest = 'csq_key', required = True, help="VEP CSQ Consequence column key; text file with columns listed")
    args = parser.parse_args()

    main(**vars(args))



if __name__ == '__main__':
    parse()
