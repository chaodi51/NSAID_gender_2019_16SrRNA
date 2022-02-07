rule dada2_denoise:
    input:
        primerRM = "../results/qiime2/" + proj_name + "-PE-demux-noprimer.qza"
    output:
        table = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table.qza",
        rep = "../results/qiime2/asv/dada2/" + proj_name + "-rep-seqs.qza",
        stats = "../results/qiime2/asv/dada2/" + proj_name + "-stats-dada2.qza"
    log:
        "logs/" + proj_name + "_dada2_denoise.log"
    params:
        mem = '20G',
        jobName = proj_name + "_dada2_denoise"
    threads: 8
    shell:
        '''
        ## truncate at base where median Q score >30
        conda activate qiime2-2019.7
        qiime dada2 denoise-paired \
            --i-demultiplexed-seqs {input.primerRM} \
            --p-trunc-len-f {config[truncation_len-f]} \
            --p-trunc-len-r {config[truncation_len-r]} \
            --p-trim-left-f 0 \
            --p-trim-left-r 0 \
            --p-n-reads-learn {config[training]} \
            --p-n-threads {threads} \
            --p-chimera-method {config[chimera]} \
            --o-table {output.table} \
            --o-representative-sequences {output.rep} \
            --o-denoising-stats {output.stats} --verbose &> {log}
        conda deactivate    
        '''


rule dada2_stats:
    input:
        table = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table.qza",
        rep = "../results/qiime2/asv/dada2/" + proj_name + "-rep-seqs.qza",
        stats = "../results/qiime2/asv/dada2/" + proj_name + "-stats-dada2.qza",
        metadata = config['metadata']
    output:
        table_viz = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table.qzv",
        rep_viz = "../results/qiime2/asv/dada2/" + proj_name + "-rep-seqs.qzv",
        stats_viz = "../results/qiime2/asv/dada2/" + proj_name + "-stats-dada2.qzv"
    log:
        "logs/" + proj_name + "_dada2_stats.log"
    params:
        mem = '20G',
        jobName = proj_name + "_dada2_stats",
        outdir = "../results/qiime2/asv/dada2/" + proj_name 
    shell:
        '''
        conda activate qiime2-2019.7
        qiime metadata tabulate \
            --m-input-file {input.stats} \
            --o-visualization {output.stats_viz} --verbose &> {log}

        qiime feature-table summarize \
            --i-table {input.table} \
            --o-visualization {output.table_viz} \
            --m-sample-metadata-file {input.metadata} --verbose &>> {log}
  
        qiime feature-table tabulate-seqs \
            --i-data {input.rep} \
            --o-visualization {output.rep_viz} --verbose &>> {log}

        qiime tools export \
            --input-path {input.table} \
            --output-path {params.outdir}/asv-table &>> {log}

        qiime tools export \
            --input-path {input.stats} \
            --output-path {params.outdir}/stats-dada2 &>> {log}
        conda deactivate
        '''

