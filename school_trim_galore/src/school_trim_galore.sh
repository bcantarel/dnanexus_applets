#!/bin/bash
# trim_galore
# Generated by dx-app-wizard.

main() {

    dx download "$fq1" -o seq.R1.fastq.gz
    dx download "$fq2" -o seq.R2.fastq.gz

    docker load -i /docker.trim_galore.tar.gz
    docker run -v ${PWD}:/data docker.io/goalconsortium/trim_galore:1.1.3 bash /seqprg/process_scripts/preproc_fastq/trimgalore.sh -f -p ${sampleid} seq.R1.fastq.gz seq.R2.fastq.gz 

    trim1=$(dx upload ${sampleid}.trim.R1.fastq.gz --brief)
    trim2=$(dx upload ${sampleid}.trim.R2.fastq.gz --brief)
    trimreport=$(dx upload ${sampleid}.trimreport.txt --brief)
    
    dx-jobutil-add-output trim1 "$trim1" --class=file
    dx-jobutil-add-output trim2 "$trim2" --class=file
    dx-jobutil-add-output trimreport "$trimreport" --class=file
}
