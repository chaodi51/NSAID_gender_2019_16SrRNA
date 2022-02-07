# Alpha and beta diversity analysis
# https://docs.qiime2.org/2021.2/tutorials/moving-pictures/
prefix = "../results/qiime2/asv/diversity/core-metrics-results/" + proj_name
rule core_metrics:
    input:
        feature_table = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table.qza",
        rooted_tree = "../results/qiime2/asv/phylogeny/" + proj_name + "-rooted_tree.qza",
        metadata = config['metadata'] 
    output:
        rarefied_table = prefix + "-rarefied-table.qza",
        faith_pd_vector = prefix + "-faith-pd-vector.qza",
        observed_otus_vector = prefix + "-observed-otus-vector.qza",
        shannon_vector = prefix + "-shannon-vector.qza",
        evenness_vector = prefix + "-evenness-vector.qza",
        unweighted_unifrac_distance_matrix = prefix + "-unweighted-unifrac-distance-matrix.qza",
        weighted_unifrac_distance_matrix = prefix + "-weighted-unifrac-distance-matrix.qza",
        jaccard_distance_matrix = prefix + "-jaccard-distance-matrix.qza",
        bray_curtis_distance_matrix = prefix + "-bray-curtis-distance-matrix.qza",
        unweighted_unifrac_pcoa_results = prefix + "-unweighted-unifrac-pcoa-results.qza",
        weighted_unifrac_pcoa_results = prefix + "-weighted-unifrac-pcoa-results.qza",
        jaccard_pcoa_results = prefix + "-jaccard-pcoa-results.qza",
        bray_curtis_pcoa_results = prefix + "-bray-curtis-pcoa-results.qza",
        unweighted_unifrac_emperor = prefix + "-unweighted-unifrac-emperor.qzv",
        weighted_unifrac_emperor = prefix + "-weighted-unifrac-emperor.qzv",
        jaccard_emperor = prefix + "-jaccard-emperor.qzv",
        bray_curtis_emperor = prefix + "-bray-curtis-emperor.qzv"

    log:
        "logs/" + proj_name + "_diversity.log"
    params:
        mem = '10G',
        jobName =  proj_name + "_diversity"
    threads: 4
    shell:
        '''
        ##  --p-sampling-depth should be carefully chosen by reviewing the table_summary file -asv-table.qzv
        
        conda activate qiime2-2019.7
        # echo "this tis to test conda..." &> {log}
        qiime diversity core-metrics-phylogenetic \\
            --i-phylogeny {input.rooted_tree} \\
            --i-table {input.feature_table} \\
            --p-sampling-depth {config[sampling_depth]} \\
            --p-n-jobs {threads} \\
            --m-metadata-file {input.metadata} \\
            --o-rarefied-table {output.rarefied_table} \\
            --o-faith-pd-vector {output.faith_pd_vector} \\
            --o-observed-otus-vector {output.observed_otus_vector} \\
            --o-shannon-vector {output.shannon_vector} \\
            --o-evenness-vector {output.evenness_vector} \\
            --o-unweighted-unifrac-distance-matrix {output.unweighted_unifrac_distance_matrix} \\
            --o-weighted-unifrac-distance-matrix {output.weighted_unifrac_distance_matrix} \\
            --o-jaccard-distance-matrix {output.jaccard_distance_matrix} \\
            --o-bray-curtis-distance-matrix {output.bray_curtis_distance_matrix} \\
            --o-unweighted-unifrac-pcoa-results {output.unweighted_unifrac_pcoa_results} \\
            --o-weighted-unifrac-pcoa-results {output.weighted_unifrac_pcoa_results} \\
            --o-jaccard-pcoa-results {output.jaccard_pcoa_results} \\
            --o-bray-curtis-pcoa-results {output.bray_curtis_pcoa_results} \\
            --o-unweighted-unifrac-emperor {output.unweighted_unifrac_emperor} \\
            --o-weighted-unifrac-emperor {output.weighted_unifrac_emperor} \\
            --o-jaccard-emperor {output.jaccard_emperor} \\
            --o-bray-curtis-emperor {output.bray_curtis_emperor} &> {log}

        conda deactivate   
        '''

rule diversity_alpha:
    input:
        faith_pd_vector = prefix + "-faith-pd-vector.qza",
        evenness_vector = prefix + "-evenness-vector.qza",
        metadata = config['metadata']
    output:
        faith_pd_group_significance = prefix + "-faith-pd-group-significance.qzv",
        evenness_group_significance = prefix + "-evenness-group-significance.qzv"
    log:
        "logs/"  + proj_name + "_diversity_alpha.log"
    params:
        mem = '10G',
        jobName = proj_name + "_diversity_alpha" 
    threads: 8
    shell:
        '''
        conda activate qiime2-2019.7
        qiime diversity alpha-group-significance \
            --i-alpha-diversity {input.faith_pd_vector}\
            --m-metadata-file {input.metadata} \
            --o-visualization {output.faith_pd_group_significance} &> {log}


        qiime diversity alpha-group-significance \
            --i-alpha-diversity {input.evenness_vector} \
            --m-metadata-file {input.metadata} \
            --o-visualization {output.evenness_group_significance} &>> {log}  

        conda deactivate
        '''

rule diversity_beta:
    input:
        unweighted_unifrac_distance_matrix = prefix + "-unweighted-unifrac-distance-matrix.qza",
        metadata = config['metadata']
    output:
        unweighted_unifrac_studygroup_significance = prefix + "-unweighted-unifrac-studygroup-significance.qzv",
        unweighted_unifrac_studyday_significance = prefix + "-unweighted-unifrac-studyday-significance.qzv"
    log:
        "logs/" + proj_name + "_diversity_beta.log"
    params:
        mem = '10G',
        jobName = proj_name + "_diversity_beta" 
    threads: 8
    shell:
        '''
        conda activate qiime2-2019.7
        qiime diversity beta-group-significance \
            --i-distance-matrix {input.unweighted_unifrac_distance_matrix} \
            --m-metadata-file {input.metadata} \
            --m-metadata-column study_group \
            --o-visualization {output.unweighted_unifrac_studygroup_significance} \
            --p-pairwise &> {log} 

        qiime diversity beta-group-significance \
            --i-distance-matrix {input.unweighted_unifrac_distance_matrix} \
            --m-metadata-file {input.metadata} \
            --m-metadata-column study_day \
            --o-visualization {output.unweighted_unifrac_studyday_significance} \
            --p-pairwise &>> {log}

        conda deactivate
        '''