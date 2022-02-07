rule phylogeny:
    input:
        rep = "../results/qiime2/asv/dada2/" + proj_name + "-rep-seqs.qza"
    output:
        alignment = "../results/qiime2/asv/phylogeny/" + proj_name + "-aligned-rep-seqs.qza",
        masked_alignment = "../results/qiime2/asv/phylogeny/" + proj_name + "-masked_aligned-rep-seqs.qza",
        unrooted_tree = "../results/qiime2/asv/phylogeny/" + proj_name + "-unrooted_tree.qza",
        rooted_tree = "../results/qiime2/asv/phylogeny/" + proj_name + "-rooted_tree.qza",
    log:
        "logs/" + proj_name + "_phylogeny.log"
    params:
        mem = '20G',
        jobName = proj_name + "_phylogeny" 
    threads: 8

    shell:
        '''
        conda activate qiime2-2019.7
        qiime phylogeny align-to-tree-mafft-fasttree \
            --p-n-threads {threads} \
            --i-sequences {input.rep} \
            --o-alignment {output.alignment} \
            --o-masked-alignment {output.masked_alignment} \
            --o-tree {output.unrooted_tree} \
            --o-rooted-tree {output.rooted_tree} \
            --verbose &> {log}

        conda deactivate   
        '''