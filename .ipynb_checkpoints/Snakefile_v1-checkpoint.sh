import pandas as pd
from pathlib import Path
#configfile: "config.yaml"
#workdir: "/n/data1/bch/hemonc/camargo/li/DATA/20211010_3_pulses_cCARLIN_Tigre"


rule all:
    input: 
        "fastqc_before_pear/multiqc_report.html",
        "fastqc_after_pear/multiqc_report.html"
    
rule fastqc_before_pear:
    input:
        fq_R1="raw_fastq/LL605-HSC_S4_L001_R1_001.fastq.gz",
        fq_R2="raw_fastq/LL605-HSC_S4_L001_R2_001.fastq.gz"
    output:
        "fastqc_before_pear/LL605-HSC_S4_L001_R1_001_fastqc.html",
        "fastqc_before_pear/LL605-HSC_S4_L001_R2_001_fastqc.html"
    params:
        workdir=config['data_dir'],
        script_dir=config['script_dir']
    run:
        shell("sh {params.script_dir}/run_fastqc.sh {input.fq_R1} fastqc_before_pear"),
        shell("sh {params.script_dir}/run_fastqc.sh {input.fq_R2} fastqc_before_pear")
        
rule pear:
    input:
        fq_R1="raw_fastq/LL605-HSC_S4_L001_R1_001.fastq.gz",
        fq_R2="raw_fastq/LL605-HSC_S4_L001_R2_001.fastq.gz"
    output:
        "pear_out/LL605-HSC_S4.trimmed.pear.assembled.fastq"
    params:
        workdir=config['data_dir'],
        script_dir=config['script_dir'],
        sample_ID='LL605-HSC_S4',
        is_RNA=config['is_RNA']
    shell:
        "sh {params.script_dir}/run_pear.sh {input.fq_R1} {input.fq_R2} pear_output/{params.sample_ID}.trimmed.pear {params.is_RNA}"
        
        
        
rule fastqc_after_pear:
    input:
        "pear_out/LL605-HSC_S4.trimmed.pear.assembled.fastq"
    output:
        "fastqc_after_pear/LL605-HSC_S4.trimmed.pear.assembled_fastqc.html"
    params:
        workdir=config['data_dir'],
        script_dir=config['script_dir']
    shell:
        "sh {params.script_dir}/run_fastqc.sh {input} fastqc_after_pear"


rule multiqc_before_pear:
    input:
        expand("fastqc_before_pear/{sample}_L001_R1_001_fastqc.html",sample=config["SampleList"])
    output:
        "fastqc_before_pear/multiqc_report.html"
    params:
        workdir=config['data_dir'],
        script_dir=config['script_dir']
    shell:
        "sh {params.script_dir}/run_multiqc.sh fastqc_before_pear"
        
        
rule multiqc_after_pear:
    input:
        expand("fastqc_after_pear/{sample}.trimmed.pear.assembled_fastqc.html",sample=config["SampleList"])
    output:
        "fastqc_after_pear/multiqc_report.html"
    params:
        workdir=config['data_dir'],
        script_dir=config['script_dir']
    shell:
        "sh {params.script_dir}/run_multiqc.sh fastqc_after_pear"
