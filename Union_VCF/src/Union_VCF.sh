#!/bin/bash
# Union_VCF 0.5.9
# Generated by dx-app-wizard.

main() {

    dx download "$fb_vcf" -o ${pair_id}.fb.vcf.gz
    dx download "$platypus_vcf" -o ${pair_id}.platypus.vcf.gz
    dx download "$strelka2_vcf" -o ${pair_id}.strelka2.vcf.gz
    dx download "$mutect_vcf" -o ${pair_id}.mutect.vcf.gz
    dx download "$pindel_vcf" -o ${pair_id}.pindel.vcf.gz
    dx download "$reference" -o dnaref.tar.gz

    tar xvfz dnaref.tar.gz

    if [ -n "$shimmer_vcf" ]
    then
        dx download "$shimmer_vcf" -o ${pair_id}.shimmer.vcf.gz
    fi

    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:0.5.9 /usr/local/bin/union.sh -r dnaref -p ${pair_id}

    union_vcf=$(dx upload ${pair_id}.union.vcf.gz --brief)

    dx-jobutil-add-output union_vcf "$union_vcf" --class=file
}
