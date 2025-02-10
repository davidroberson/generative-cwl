# CWL Tools for the m-REGLE project
# source: https://github.com/Google-Health/genomics-research/tree/main/mregle


# CWL tool for generating a demo dataset from the UK Biobank sample
cwlVersion: v1.2
class: CommandLineTool
baseCommand: 
  - python3
  - generate_dataset_from_ukb_demo.py
doc: |
  Generates a demo dataset for M-REGLE. The script accepts:
   • --out_dir : a string naming the directory where the output (e.g. “ecgppg_ml_data.npy” or “ecg_ml_data.npy”) is written.
   • --dataset : a string indicating the dataset type (e.g. “ecgppg” or “ecg12”).
   • --duplicates (optional): an integer specifying how many copies to create (used for demo training data).
  
inputs:
  out_dir:
    type: string
    doc: "Output directory (relative or absolute) where the dataset file(s) will be written."
    inputBinding:
      position: 1
      prefix: "--out_dir"
  dataset:
    type: string
    doc: "Dataset type; for example, ecgppg or ecg12."
    inputBinding:
      position: 2
      prefix: "--dataset"
  duplicates:
    type: int?
    doc: "Optional number of duplicates to generate (e.g. 80 for training demo)."
    inputBinding:
      position: 3
      prefix: "--duplicates"

outputs:
  dataset_dir:
    type: Directory
    doc: "The output directory containing the generated dataset file(s)."
    outputBinding:
      # This glob pattern assumes that the script creates a directory whose name matches the provided out_dir.
      glob: "$(inputs.out_dir)"

  
