# Variant Analysis Tools Collection
# File: variant_tools.cwl

# GATK MarkDuplicates Tool
cwlVersion: v1.2
class: CommandLineTool
id: gatk_markduplicates_tool
label: Mark duplicate reads in BAM files
baseCommand: [gatk, MarkDuplicates]
requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.3.0.0
  ResourceRequirement:
    ramMin: 32000
    coresMin: 1

inputs:
  input_bam:
    type: File
    inputBinding:
      prefix: -I
  output_name:
    type: string
    inputBinding:
      prefix: -O
  metrics_file:
    type: string
    inputBinding:
      prefix: -M

outputs:
  dedup_bam:
    type: File
    outputBinding:
      glob: $(inputs.output_name)
  metrics:
    type: File
    outputBinding:
      glob: $(inputs.metrics_file)

---
# GATK BaseRecalibrator Tool
cwlVersion: v1.2
class: CommandLineTool
id: gatk_baserecalibrator_tool
label: Detect systematic errors in base quality scores
baseCommand: [gatk, BaseRecalibrator]
requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.3.0.0
  ResourceRequirement:
    ramMin: 32000
    coresMin: 1

inputs:
  input_bam:
    type: File
    inputBinding:
      prefix: -I
  reference:
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      prefix: -R
  known_sites:
    type: File[]
    inputBinding:
      prefix: --known-sites
  output_name:
    type: string
    inputBinding:
      prefix: -O

outputs:
  recal_table:
    type: File
    outputBinding:
      glob: $(inputs.output_name)

---
# GATK MuTect2 Tool
cwlVersion: v1.2
class: CommandLineTool
id: gatk_mutect2_tool
label: Call somatic SNVs and indels via local assembly
baseCommand: [gatk, Mutect2]
requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.3.0.0
  ResourceRequirement:
    ramMin: 32000
    coresMin: 4

inputs:
  reference:
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      prefix: -R
  tumor_bam:
    type: File
    secondaryFiles:
      - ^.bai
    inputBinding:
      prefix: -I
  normal_bam:
    type: File?
    secondaryFiles:
      - ^.bai
    inputBinding:
      prefix: -I
  interval_list:
    type: File?
    inputBinding:
      prefix: -L
  germline_resource:
    type: File?
    inputBinding:
      prefix: --germline-resource
  panel_of_normals:
    type: File?
    inputBinding:
      prefix: --panel-of-normals
  output_vcf:
    type: string
    inputBinding:
      prefix: -O

outputs:
  vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)
  stats:
    type: File
    outputBinding:
      glob: "*.stats"

---
# GATK FilterMutectCalls Tool
cwlVersion: v1.2
class: CommandLineTool
id: gatk_filtermutectcalls_tool
label: Filter somatic SNVs and indels called by Mutect2
baseCommand: [gatk, FilterMutectCalls]
requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.3.0.0
  ResourceRequirement:
    ramMin: 16000
    coresMin: 2

inputs:
  vcf:
    type: File
    inputBinding:
      prefix: -V
  reference:
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      prefix: -R
  output_vcf:
    type: string
    inputBinding:
      prefix: -O
  contamination_table:
    type: File?
    inputBinding:
      prefix: --contamination-table
  orientation_bias_artifact_priors:
    type: File?
    inputBinding:
      prefix: --orientation-bias-artifact-priors

outputs:
  filtered_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)
  filtering_stats:
    type: File
    outputBinding:
      glob: "*.filteringStats.tsv"

---
# GATK ApplyBQSR Tool
cwlVersion: v1.2
class: CommandLineTool
id: gatk_applybqsr_tool
label: Apply base quality score recalibration
baseCommand: [gatk, ApplyBQSR]
requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.3.0.0
  ResourceRequirement:
    ramMin: 16000
    coresMin: 2

inputs:
  input_bam:
    type: File
    secondaryFiles:
      - ^.bai
    inputBinding:
      prefix: -I
  reference:
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      prefix: -R
  recal_table:
    type: File
    inputBinding:
      prefix: --bqsr-recal-file
  output_bam:
    type: string
    inputBinding:
      prefix: -O

outputs:
  recalibrated_bam:
    type: File
    outputBinding:
      glob: $(inputs.output_bam)
    secondaryFiles:
      - ^.bai

---
# GATK HaplotypeCaller Tool
cwlVersion: v1.2
class: CommandLineTool
id: gatk_haplotypecaller_tool
label: Call germline SNPs and indels via local re-assembly
baseCommand: [gatk, HaplotypeCaller]
requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.3.0.0
  ResourceRequirement:
    ramMin: 32000
    coresMin: 4

inputs:
  input_bam:
    type: File
    secondaryFiles:
      - ^.bai
    inputBinding:
      prefix: -I
  reference:
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      prefix: -R
  interval_list:
    type: File?
    inputBinding:
      prefix: -L
  output_filename:
    type: string
    inputBinding:
      prefix: -O
  emit_ref_confidence:
    type: string?
    inputBinding:
      prefix: -ERC
  dbsnp:
    type: File?
    secondaryFiles:
      - .idx
    inputBinding:
      prefix: --dbsnp

outputs:
  output_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    secondaryFiles:
      - .idx
  bamout:
    type: File?
    outputBinding:
      glob: "*.realigned.bam"

---
# SnpEff Tool
cwlVersion: v1.2
class: CommandLineTool
id: snpeff_tool
label: Genetic variant annotation and effect prediction
baseCommand: snpEff
requirements:
  DockerRequirement:
    dockerPull: biocontainers/snpeff:5.0
  ResourceRequirement:
    ramMin: 16000
    coresMin: 4

inputs:
  input_vcf:
    type: File
    inputBinding:
      position: 2
  genome_version:
    type: string
    inputBinding:
      position: 1
  config:
    type: File?
    inputBinding:
      prefix: -config

outputs:
  annotated_vcf:
    type: File
    outputBinding:
      glob: "snpEff_*.vcf"
  stats:
    type: File
    outputBinding:
      glob: "snpEff_summary.html"
