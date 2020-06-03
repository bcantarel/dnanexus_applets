#!/bin/bash
# CNV_ITDSeek 0.5.9
# Generated by dx-app-wizard.

main() {

    dx download "$Raw_BAM" -o ${pair_id}.bam
    dx download "$Raw_BAI" -o ${pair_id}.bam.bai
    dx download "$reference" -o dnaref.tar.gz

    tar xvfz dnaref.tar.gz

    if [[ ! -z "${panel}" ]];
    then
        dx download "$panel" -o panel.tar.gz
        mkdir -p panel
        tar xvfz panel.tar.gz -C panel/

        docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:0.5.9 bash /usr/local/bin/cnvkit.sh -r dnaref -b ${pair_id}.bam -p ${pair_id} -d panel

        tar -czvf ${pair_id}.cnvansplot.tar.gz ${pair_id}.answerplot*
        tar -czvf ${pair_id}.cnvtxt.tar.gz ${pair_id}.*txt

        cns=$(dx upload ${pair_id}.call.cns --brief)
        cnsori=$(dx upload ${pair_id}.cns --brief)
        cnr=$(dx upload ${pair_id}.cnr --brief)
        cnvansplot=$(dx upload ${pair_id}.cnvansplot.tar.gz --brief)
        cnvtxt=$(dx upload ${pair_id}.cnvtxt.tar.gz --brief)
        cnvpdf=$(dx upload ${pair_id}.cnv*pdf --brief)

        dx-jobutil-add-output cns "$cns" --class=file
        dx-jobutil-add-output cnsori "$cnsori" --class=file
        dx-jobutil-add-output cnr "$cnr" --class=file
        dx-jobutil-add-output cnvansplot "$cnvansplot" --class=file
        dx-jobutil-add-output cnvtxt "$cnvtxt" --class=file
        dx-jobutil-add-output cnvpdf "$cnvpdf" --class=file
    fi

    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:0.5.9 bash /usr/local/bin/svcalling.sh -b ${pair_id}.bam -r dnaref -p ${pair_id} -l dnaref/itd_genes.bed -a itdseek -f

    itdseekvcf=$(dx upload ${pair_id}.itdseek_tandemdup.vcf.gz --brief)

    dx-jobutil-add-output itdseekvcf "$itdseekvcf" --class=file
}
