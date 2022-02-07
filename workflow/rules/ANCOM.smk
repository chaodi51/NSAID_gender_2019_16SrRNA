rule ANCOM:
    input:
        table_2k_abund = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_2k_abund.qza",
        metadata = config['metadata']
    output:
        table_2k_abund_comp = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_2k_abund_comp.qza",
        ancom_study_group = "../results/qiime2/asv/dada2/" + proj_name + "_ancom_study_group.qzv",
        ancom_study_day = "../results/qiime2/asv/dada2/" + proj_name + "_ancom_study_day.qzv"
        
    log:
        "logs/" + proj_name + "_ANCOM.log"
    params:
        mem = '20G',
        jobName = proj_name + "_ANCOM"
    shell:
        '''
        conda activate qiime2-2019.7

        # add a pseudocount to the FeatureTable[Frequency]
        qiime composition add-pseudocount \
            --i-table {input.table_2k_abund} \
            --o-composition-table {output.table_2k_abund_comp} &> {log}
                
        qiime composition ancom \
            --i-table {output.table_2k_abund_comp} \
            --m-metadata-file {input.metadata} \
            --m-metadata-column study_group \
            --o-visualization {output.ancom_study_group} &>> {log}

        qiime composition ancom \
            --i-table {output.table_2k_abund_comp} \
            --m-metadata-file {input.metadata} \
            --m-metadata-column study_day \
            --o-visualization {output.ancom_study_day} &>> {log}

        conda deactivate
        '''
