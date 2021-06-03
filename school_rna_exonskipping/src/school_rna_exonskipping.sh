#!/bin/bash
# geneabund
# Generated by dx-app-wizard.

main() {

    dx download "$bam" -o ${sampleid}.bam
    dx download "$reference" -o ref.tar.gz

    mkdir rnaref
    docker load -i /docker.profiling_qc.tar.gz
    docker load -i /docker.rna_gene_abundance.tar.gz
    
    docker run -v ${PWD}:/data docker.io/goalconsortium/profiling_qc:1.1.3 tar -I pigz -xvf ref.tar.gz --no-same-owner --strip-components=1 -C rnaref

    docker run -v ${PWD}:/data docker.io/goalconsortium/rna_gene_abundance:1.1.3 bash /seqprg/process_scripts/genect_rnaseq/exonskipping.sh -g rnaref/gencode.gtf -p ${sampleid} -b ${sampleid}.bam -r rnaref

    tar cfz ${sampleid}.exonskip.tar.gz ${sampleid}.exonskip.answer.txt ${sampleid}.juncannot.txt 
    outfile=$(dx upload ${sampleid}.exonskip.tar.gz --brief)
    dx-jobutil-add-output outfile "$outfile" --class=file
}
