rule ANCOM_taxa:
    input:
        table_2k = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_2k.qza",
        taxonomy = "../results/qiime2/asv/taxonomy/" + proj_name + "-taxonomy.qza",
        metadata = config['metadata']
    output:
        uniform_table = "../results/qiime2/asv/taxonomy/" + proj_name + "-uniform_table.qza",
        filtered_uniform_table = "../results/qiime2/asv/taxonomy/" + proj_name + "-filtered_uniform_table.qza",
        cfu_table = "../results/qiime2/asv/taxonomy/" + proj_name + "-cfu_table.qza",
        ancom_uniform_study_group = "../results/qiime2/asv/taxonomy/" + proj_name + "_ancom_uniform_study_group.qzv",
        ancom_uniform_study_day = "../results/qiime2/asv/taxonomy/" + proj_name + "_ancom_uniform_study_day.qzv"
        
    log:
        "logs/" + proj_name + "_ANCOM_taxa.log"
    params:
        mem = '20G',
        jobName = proj_name + "_ANCOM_taxa"
    shell:
        '''
        conda activate qiime2-2019.7

        # collapse to asv to taxon
        qiime taxa collapse \
            --i-table {input.table_2k} \
            --i-taxonomy {input.taxonomy} \
            --o-collapsed-table {output.uniform_table} \
            --p-level 7 &> {log} # means that we group at species level
        
        # filter feature table
        qiime feature-table filter-features \
            --i-table {output.uniform_table} \
            --p-min-frequency {config[min-frequency_all]} \
            --p-min-samples {config[min-samples]} \
            --o-filtered-table {output.filtered_uniform_table} &>> {log}        

        # add a pseudocount to the FeatureTable[Frequency]
        qiime composition add-pseudocount \
            --i-table {output.filtered_uniform_table} \
            --o-composition-table {output.cfu_table} &> {log}
                
        qiime composition ancom \
            --i-table {output.cfu_table} \
            --m-metadata-file {input.metadata} \
            --m-metadata-column study_group \
            --o-visualization {output.ancom_uniform_study_group} &>> {log}

        qiime composition ancom \
            --i-table {output.cfu_table} \
            --m-metadata-file {input.metadata} \
            --m-metadata-column study_day \
            --o-visualization {output.ancom_uniform_study_day} &>> {log}

        conda deactivate
        '''