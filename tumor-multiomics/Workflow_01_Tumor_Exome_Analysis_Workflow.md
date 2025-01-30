# Tumor Exome Analysis Workflow Documentation

## Overview
This document describes a Common Workflow Language (CWL) implementation of a tumor exome analysis pipeline using specific tools from our tool library. The workflow processes tumor exome sequencing data, from raw FASTQ files to annotated variants, implementing best practices for somatic variant discovery.

## Workflow Diagram

```mermaid
graph TD
    A[Input: Paired-End Tumor FASTQ] --> QC1[Quality Control<br/>/fastqc_tool<br/>Forward Reads]
    A --> QC2[Quality Control<br/>/fastqc_tool<br/>Reverse Reads]
    A --> B[Read Alignment<br/>/bwa_mem_tool]
    R[Reference Genome] --> B
    QC1 --> M[QC Report Generation<br/>/multiqc_tool]
    QC2 --> M
    B --> C[Duplicate Marking<br/>/gatk_markduplicates_tool]
    C --> D[Base Recalibration<br/>/gatk_baserecalibrator_tool]
    K[Known Variants] --> D
    D --> E[Apply Recalibration<br/>/gatk_applybqsr_tool]
    E --> F[Variant Calling<br/>/gatk_mutect2_tool]
    F --> G[Variant Filtration<br/>/gatk_filtermutectcalls_tool]
    G --> H[Variant Annotation<br/>/snpeff_tool]
    H --> I[Output: Annotated VCF]
    M --> N[Output: QC Report]
    
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style R fill:#bbf,stroke:#333,stroke-width:2px
    style K fill:#bbf,stroke:#333,stroke-width:2px
    style I fill:#bfb,stroke:#333,stroke-width:2px
    style N fill:#bfb,stroke:#333,stroke-width:2px
    style QC1 fill:#e6e6fa,stroke:#333,stroke-width:2px
    style QC2 fill:#e6e6fa,stroke:#333,stroke-width:2px
    style B fill:#e6e6fa,stroke:#333,stroke-width:2px
    style C fill:#e6e6fa,stroke:#333,stroke-width:2px
    style D fill:#e6e6fa,stroke:#333,stroke-width:2px
    style E fill:#e6e6fa,stroke:#333,stroke-width:2px
    style F fill:#e6e6fa,stroke:#333,stroke-width:2px
    style G fill:#e6e6fa,stroke:#333,stroke-width:2px
    style H fill:#e6e6fa,stroke:#333,stroke-width:2px
    style M fill:#e6e6fa,stroke:#333,stroke-width:2px
```

### Diagram Legend
- Pink boxes: Initial inputs (FASTQ files)
- Blue boxes: Reference data (Reference genome, Known variants)
- Green boxes: Final outputs (Annotated VCF, QC reports)
- Lavender boxes: Processing steps (with specific tool IDs)

## Workflow Steps Description

1. **Quality Control**
   - Tool: `fastqc_tool` from qc_tools.cwl
   - Container: biocontainers/fastqc:0.11.9
   - Resources: 4GB RAM, 1 core
   - Purpose: Assesses the quality of raw sequencing data

2. **QC Report Generation**
   - Tool: `multiqc_tool` from qc_tools.cwl
   - Container: biocontainers/multiqc:1.12
   - Resources: 4GB RAM, 1 core
   - Purpose: Aggregates QC metrics into a single report

3. **Read Alignment**
   - Tool: `bwa_mem_tool` from alignment_tools.cwl
   - Container: biocontainers/bwa:0.7.17
   - Resources: 16GB RAM, 8 cores
   - Purpose: Aligns raw reads to the reference genome

4. **Mark Duplicates**
   - Tool: `gatk_markduplicates_tool` from variant_analysis_tools.cwl
   - Container: broadinstitute/gatk:4.3.0.0
   - Resources: 32GB RAM, 1 core
   - Purpose: Identifies and marks PCR duplicates

5. **Base Recalibration**
   - Tool: `gatk_baserecalibrator_tool` from variant_analysis_tools.cwl
   - Container: broadinstitute/gatk:4.3.0.0
   - Resources: 32GB RAM, 1 core
   - Purpose: Generates base quality score recalibration table

6. **Apply Recalibration**
   - Tool: `gatk_applybqsr_tool` from variant_analysis_tools.cwl
   - Container: broadinstitute/gatk:4.3.0.0
   - Resources: 16GB RAM, 2 cores
   - Purpose: Applies base quality score recalibration

7. **Variant Calling**
   - Tool: `gatk_mutect2_tool` from variant_analysis_tools.cwl
   - Container: broadinstitute/gatk:4.3.0.0
   - Resources: 32GB RAM, 4 cores
   - Purpose: Calls somatic variants

8. **Variant Filtration**
   - Tool: `gatk_filtermutectcalls_tool` from variant_analysis_tools.cwl
   - Container: broadinstitute/gatk:4.3.0.0
   - Resources: 16GB RAM, 2 cores
   - Purpose: Filters low-quality variant calls

9. **Variant Annotation**
   - Tool: `snpeff_tool` from variant_analysis_tools.cwl
   - Container: biocontainers/snpeff:5.0
   - Resources: 16GB RAM, 4 cores
   - Purpose: Annotates variants with functional predictions

## CWL Implementation

```yaml
#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: Workflow
label: Tumor Exome Analysis Pipeline

inputs:
  tumor_fastq_1: File
  tumor_fastq_2: File
  reference_genome: File
  known_variants: File
  dbsnp: File

outputs:
  filtered_vcf:
    type: File
    outputSource: variant_annotation/annotated_vcf
  alignment_stats:
    type: File
    outputSource: alignment/aligned_sam
  multiqc_report:
    type: File
    outputSource: multiqc/report

steps:
  quality_control_1:
    run: ../cwl-tool-library/qc_tools.cwl#fastqc_tool
    in:
      fastq_file: tumor_fastq_1
      threads: { default: 1 }
    out: [html_file, zip_file]

  quality_control_2:
    run: ../cwl-tool-library/qc_tools.cwl#fastqc_tool
    in:
      fastq_file: tumor_fastq_2
      threads: { default: 1 }
    out: [html_file, zip_file]

  multiqc:
    run: ../cwl-tool-library/qc_tools.cwl#multiqc_tool
    in:
      input_dir:
        type: Directory
        source: [quality_control_1/html_file, quality_control_2/html_file]
    out: [report]

  alignment:
    run: ../cwl-tool-library/alignment_tools.cwl#bwa_mem_tool
    in:
      reference: reference_genome
      reads1: tumor_fastq_1
      reads2: tumor_fastq_2
      threads: { default: 8 }
    out: [aligned_sam]

  mark_duplicates:
    run: ../cwl-tool-library/variant_analysis_tools.cwl#gatk_markduplicates_tool
    in:
      input_bam: alignment/aligned_sam
      output_name: { default: "marked_duplicates.bam" }
      metrics_file: { default: "duplicate_metrics.txt" }
    out: [dedup_bam, metrics]

  base_recalibration:
    run: ../cwl-tool-library/variant_analysis_tools.cwl#gatk_baserecalibrator_tool
    in:
      input_bam: mark_duplicates/dedup_bam
      reference: reference_genome
      known_sites: known_variants
    out: [recal_table]

  apply_bqsr:
    run: ../cwl-tool-library/variant_analysis_tools.cwl#gatk_applybqsr_tool
    in:
      input_bam: mark_duplicates/dedup_bam
      reference: reference_genome
      recal_table: base_recalibration/recal_table
      output_name: { default: "recalibrated.bam" }
    out: [recalibrated_bam]

  mutect2:
    run: ../cwl-tool-library/variant_analysis_tools.cwl#gatk_mutect2_tool
    in:
      input_bam: apply_bqsr/recalibrated_bam
      reference: reference_genome
      tumor_sample: { default: "TUMOR" }
      output_name: { default: "somatic_variants.vcf" }
    out: [vcf, stats, f1r2]

  filter_mutect:
    run: ../cwl-tool-library/variant_analysis_tools.cwl#gatk_filtermutectcalls_tool
    in:
      input_vcf: mutect2/vcf
      reference: reference_genome
      output_name: { default: "filtered_somatic_variants.vcf" }
    out: [filtered_vcf, filtering_stats]

  variant_annotation:
    run: ../cwl-tool-library/variant_analysis_tools.cwl#snpeff_tool
    in:
      input_vcf: filter_mutect/filtered_vcf
      genome_version: "hg38"  # or appropriate reference version
    out: [annotated_vcf, stats]
```

## Resource Requirements Summary

### Computational Resources by Step
1. **Quality Control (FastQC)** - Per FASTQ file:
   - RAM: 4GB
   - CPU: 1 core
   - Storage: ~1GB
   - Time estimate: 15-30 minutes

2. **QC Report Generation (MultiQC)**
   - RAM: 4GB
   - CPU: 1 core
   - Storage: <1GB
   - Time estimate: 5-10 minutes

3. **Alignment (BWA-MEM)**
   - RAM: 16GB
   - CPU: 8 cores
   - Storage: ~50GB
   - Time estimate: 2-4 hours

4. **Mark Duplicates (GATK)**
   - RAM: 32GB
   - CPU: 1 core
   - Storage: ~50GB
   - Time estimate: 1-2 hours

5. **Base Recalibration (GATK BaseRecalibrator)**
   - RAM: 32GB
   - CPU: 1 core
   - Storage: ~10GB
   - Time estimate: 1-2 hours

6. **Apply BQSR (GATK ApplyBQSR)**
   - RAM: 16GB
   - CPU: 2 cores
   - Storage: ~50GB
   - Time estimate: 1-2 hours

7. **Variant Calling (GATK Mutect2)**
   - RAM: 32GB
   - CPU: 4 cores
   - Storage: ~20GB
   - Time estimate: 4-8 hours

8. **Variant Filtration (GATK FilterMutectCalls)**
   - RAM: 16GB
   - CPU: 2 cores
   - Storage: ~10GB
   - Time estimate: 30-60 minutes

9. **Variant Annotation (SnpEff)**
   - RAM: 16GB
   - CPU: 4 cores
   - Storage: ~20GB
   - Time estimate: 30-60 minutes

### Total Resource Requirements
- Peak RAM: 32GB
- Optimal CPU: 8+ cores
- Total Storage: ~200GB per sample
- Total Runtime: 12-24 hours per sample

## Error Handling and Monitoring

### Key Monitoring Points
1. FastQC output metrics
   - Sequence quality scores
   - GC content
   - Duplication rates
   - Adapter content

2. BWA alignment statistics
   - Mapping rate
   - Insert size distribution
   - Coverage uniformity

3. GATK metrics
   - Duplication rate
   - Base quality score distribution
   - Variant quality metrics

### Common Error Points and Solutions
1. **Insufficient Memory**
   - Symptom: Java heap space errors
   - Solution: Increase RAM allocation in tool resource requirements

2. **Storage Issues**
   - Symptom: No space left on device
   - Solution: Monitor storage usage, implement cleanup steps

3. **Reference Mismatches**
   - Symptom: Reference index missing
   - Solution: Verify reference genome indices are properly generated

## Quality Control Thresholds

### FastQC Metrics
- Base quality: >Q20 for 80% of bases
- Sequence duplication: <20%
- Adapter content: <5%

### Alignment Metrics
- Mapping rate: >95%
- Duplication rate: <30%
- Mean coverage: >100x

### Variant Calling Metrics
- Ti/Tv ratio: ~2.0-2.1 for WES
- Het/Hom ratio: ~1.5-2.0
- Transition/Transversion ratio: ~3.0
