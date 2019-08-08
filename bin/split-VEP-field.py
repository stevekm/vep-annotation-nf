#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Splits the 'CSQ' column in a .tsv formatted table
CSQ: Consequence annotation column output by VEP
meant to be used with VEP .vcf output, converted to .tsv with GATK VariantsToTable

##INFO=<ID=CSQ,Number=.,Type=String,Description="Consequence annotations from Ensembl VEP. Format: Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND|FLAGS|SYMBOL_SOURCE|HGNC_ID">
"""
import csv
import sys
import argparse


def main(**kwargs):
    """
    Main control function for the script
    """
    input_file = kwargs.pop('input_file', None)
    output_file = kwargs.pop('output_file', None)

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

    new_fieldnames.append('Allele')
    new_fieldnames.append('Consequence')
    new_fieldnames.append('IMPACT')
    new_fieldnames.append('SYMBOL')
    new_fieldnames.append('Gene')
    new_fieldnames.append('Feature_type')
    new_fieldnames.append('Feature')
    new_fieldnames.append('BIOTYPE')
    new_fieldnames.append('EXON')
    new_fieldnames.append('INTRON')
    new_fieldnames.append('HGVSc')
    new_fieldnames.append('HGVSp')
    new_fieldnames.append('cDNA_position')
    new_fieldnames.append('CDS_position')
    new_fieldnames.append('Protein_position')
    new_fieldnames.append('Amino_acids')
    new_fieldnames.append('Existing_variation')
    new_fieldnames.append('DISTANCE')
    new_fieldnames.append('STRAND')
    new_fieldnames.append('FLAGS')
    new_fieldnames.append('SYMBOL_SOURCE')
    new_fieldnames.append('HGNC_ID')

    writer = csv.DictWriter(fout, delimiter = '\t', fieldnames = new_fieldnames)
    writer.writeheader()

    for row in reader:
        parts = row['CSQ'].split('|')
        row['Allele'] = parts[0]
        row['Consequence'] = parts[1]
        row['IMPACT'] = parts[2]
        row['SYMBOL'] = parts[3]
        row['Gene'] = parts[4]
        row['Feature_type'] = parts[5]
        row['Feature'] = parts[6]
        row['BIOTYPE'] = parts[7]
        row['EXON'] = parts[8]
        row['INTRON'] = parts[9]
        row['HGVSc'] = parts[10]
        row['HGVSp'] = parts[11]
        row['cDNA_position'] = parts[12]
        row['CDS_position'] = parts[13]
        row['Protein_position'] = parts[14]
        row['Amino_acids'] = parts[15]
        row['Existing_variation'] = parts[16]
        row['DISTANCE'] = parts[17]
        row['STRAND'] = parts[18]
        row['FLAGS'] = parts[19]
        row['SYMBOL_SOURCE'] = parts[20]
        row['HGNC_ID'] = parts[21]

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
    args = parser.parse_args()

    main(**vars(args))



if __name__ == '__main__':
    parse()
