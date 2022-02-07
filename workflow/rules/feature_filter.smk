rule feature_filter:
    input:
        table = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table.qza",
        metadata = config['metadata']
    output:
        table_2k = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_2k.qza",
        table_2k_abund = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_2k_abund.qza",
        table_2k_abund_viz = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_2k_abund.qzv"
    log:
        "logs/" + proj_name + "_feature_filter.log"
    params:
        mem = '20G',
        jobName = proj_name + "_feature_filter"
    shell:
        '''
        conda activate qiime2-2019.7

        qiime feature-table filter-samples \
            --i-table {input.table} \
            --p-min-frequency {config[min-frequency_sample]} \
            --o-filtered-table {output.table_2k} &> {log}
            
        qiime feature-table filter-features \
            --i-table {output.table_2k} \
            --p-min-frequency {config[min-frequency_all]} \
            --p-min-samples {config[min-samples]} \
            --o-filtered-table {output.table_2k_abund} &>> {log}

        qiime feature-table summarize \
            --i-table {output.table_2k_abund} \
            --o-visualization {output.table_2k_abund_viz} \
            --m-sample-metadata-file {input.metadata} --verbose &>> {log}    

        conda deactivate
        '''

rule sample_filter:
    input:
        table = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table.qza",
        metadata = config['metadata']
    output:
        table_Celecoxib = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_Celecoxib.qza",
        table_Celecoxib_viz = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_Celecoxib.qzv",
        table_Naproxen = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_Naproxen.qza",
        table_Naproxen_viz = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_Naproxen.qzv",
    log:
        "logs/" + proj_name + "_sample_filter.log"
    params:
        mem = '20G',
        jobName = proj_name + "_sample_filter"
    shell:
        '''
        conda activate qiime2-2019.7

        qiime feature-table filter-samples \
            --i-table {input.table} \
            --m-metadata-file {input.metadata} \
            --p-where "[study_group] IN ('Celecoxib', 'Control')" \
            --o-filtered-table {output.table_Celecoxib} &> {log}

        qiime feature-table filter-samples \
            --i-table {input.table} \
            --m-metadata-file {input.metadata} \
            --p-where "[study_group] IN ('Naproxen', 'Control')" \
            --o-filtered-table {output.table_Naproxen} &>> {log}   

        qiime feature-table summarize \
            --i-table {output.table_Naproxen} \
            --o-visualization {output.table_Naproxen_viz} \
            --m-sample-metadata-file {input.metadata} --verbose &>> {log}   

        qiime feature-table summarize \
            --i-table {output.table_Celecoxib} \
            --o-visualization {output.table_Celecoxib_viz} \
            --m-sample-metadata-file {input.metadata} --verbose &>> {log}   
        
        conda deactivate
        '''    