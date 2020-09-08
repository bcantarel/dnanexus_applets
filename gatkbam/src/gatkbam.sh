#!/bin/bash
# GATK 
# Generated by dx-app-wizard.

main() {

    dx download "$bam" -o ${sampleid}.bam
    dx download "$bai" -o ${sampleid}.bam.bai
    dx download "$reference" -o ref.tar.gz

    mkdir dnaref
    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:1.0.4 tar -I pigz -xvf ref.tar.gz --strip-components=1 -C dnaref


    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:1.0.4 bash /seqprg/process_scripts/variants/gatkrunner.sh -a gatkbam -b ${sampleid}.bam -r dnaref -p ${sampleid}

    gatkbam=$(dx upload ${sampleid}.final.bam --brief)
    gatkbai=$(dx upload ${sampleid}.final.bam.bai --brief)

    dx-jobutil-add-output gatkbam "$gatkbam" --class=file
    dx-jobutil-add-output gatkbai "$gatkbai" --class=file
}
