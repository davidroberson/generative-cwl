# Quality Control Tools Collection
# File: qc_tools.cwl

# FastQC Tool
cwlVersion: v1.2
class: CommandLineTool
id: fastqc_tool
label: Quality control checks on raw sequence data
baseCommand: fastqc
requirements:
  DockerRequirement:
    dockerPull: biocontainers/fastqc:0.11.9
  ResourceRequirement:
    ramMin: 4000
    coresMin: 1

inputs:
  fastq_file:
    type: File
    inputBinding:
      position: 1
  threads:
    type: int?
    default: 1
    inputBinding:
      prefix: --threads
  outdir:
    type: string?
    default: "."
    inputBinding:
      prefix: -o

outputs:
  html_file:
    type: File
    outputBinding:
      glob: "*.html"
  zip_file:
    type: File
    outputBinding:
      glob: "*.zip"

---
# MultiQC Tool
cwlVersion: v1.2
class: CommandLineTool
id: multiqc_tool
label: Aggregate analysis reports
baseCommand: multiqc
requirements:
  DockerRequirement:
    dockerPull: biocontainers/multiqc:1.12
  ResourceRequirement:
    ramMin: 4000
    coresMin: 1

inputs:
  input_files:
    type: File[]
    inputBinding:
      position: 1
    doc: "List of input files to analyze"
  output_dir:
    type: string
    default: "multiqc_output"
    inputBinding:
      prefix: -o
  filename:
    type: string?
    inputBinding:
      prefix: -n

outputs:
  report:
    type: File
    outputBinding:
      glob: "$(inputs.output_dir)/multiqc_report.html"
  data:
    type: Directory
    outputBinding:
      glob: "$(inputs.output_dir)/multiqc_data"
