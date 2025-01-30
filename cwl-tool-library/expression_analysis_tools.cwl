# Expression Analysis Tools Collection
# File: expression_tools.cwl

# featureCounts Tool
cwlVersion: v1.2
class: CommandLineTool
id: featurecounts_tool
label: Count reads mapping to genomic features
baseCommand: featureCounts
requirements:
  DockerRequirement:
    dockerPull: biocontainers/subread:2.0.1
  ResourceRequirement:
    ramMin: 16000
    coresMin: 8

inputs:
  input_bam:
    type: File
    inputBinding:
      position: 1
  annotation_file:
    type: File
    inputBinding:
      prefix: -a
  output_name:
    type: string
    inputBinding:
      prefix: -o
  threads:
    type: int?
    default: 8
    inputBinding:
      prefix: -T

outputs:
  counts:
    type: File
    outputBinding:
      glob: $(inputs.output_name)
  summary:
    type: File
    outputBinding:
      glob: "$(inputs.output_name).summary"

---
# DESeq2 Tool
cwlVersion: v1.2
class: CommandLineTool
id: deseq2_tool
label: Differential expression analysis
baseCommand: Rscript
requirements:
  DockerRequirement:
    dockerPull: bioconductor/bioconductor_docker:3.16
  ResourceRequirement:
    ramMin: 32000
    coresMin: 1

inputs:
  counts_matrix:
    type: File
    inputBinding:
      position: 1
  sample_info:
    type: File
    inputBinding:
      position: 2
  script:
    type: File
    inputBinding:
      position: 0
  output_prefix:
    type: string
    inputBinding:
      position: 3

outputs:
  results:
    type: File
    outputBinding:
      glob: "*results.csv"
  plots:
    type: File[]
    outputBinding:
      glob: "*plot.pdf"

---
# MOFA+ Tool
cwlVersion: v1.2
class: CommandLineTool
id: mofa_plus_tool
label: Multi-Omics Factor Analysis
baseCommand: Rscript
requirements:
  DockerRequirement:
    dockerPull: biocontainers/mofa:1.0.1
  ResourceRequirement:
    ramMin: 64000
    coresMin: 16

inputs:
  data_matrices:
    type: File[]
    inputBinding:
      position: 1
  script:
    type: File
    inputBinding:
      position: 0
  output_prefix:
    type: string
    inputBinding:
      position: 2

outputs:
  model:
    type: File
    outputBinding:
      glob: "*_model.hdf5"
  plots:
    type: File[]
    outputBinding:
      glob: "*plot.pdf"
