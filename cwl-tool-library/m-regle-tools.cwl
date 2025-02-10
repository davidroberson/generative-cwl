# CWL Tools for the m-REGLE project
# source: https://github.com/Google-Health/genomics-research/tree/main/mregle

#generate_dataset_from_ukb
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

#generate_mregle_embeddings
# CWL tool for generating joint embeddings with the trained VAE model
cwlVersion: v1.2
class: CommandLineTool
baseCommand:
  - python3
  - generate_mregle_embeddings.py
doc: |
  Generates joint representations (embeddings) for a given dataset.
  Required parameters:
   • --output_dir : directory where the embeddings file will be written.
   • --dataset : dataset type (e.g. ecgppg or ecg12).
  
inputs:
  output_dir:
    type: string
    doc: "Output directory (relative or absolute) where the embeddings will be stored."
    inputBinding:
      position: 1
      prefix: "--output_dir"
  dataset:
    type: string
    doc: "Dataset type; for example, ecgppg or ecg12."
    inputBinding:
      position: 2
      prefix: "--dataset"

outputs:
  embeddings_dir:
    type: Directory
    doc: "The output directory containing the generated embeddings file."
    outputBinding:
      glob: "$(inputs.output_dir)"

# train_mregle
# CWL tool for training a M-REGLE model
cwlVersion: v1.2
class: CommandLineTool
baseCommand:
  - python3
  - train.py
doc: |
  Trains a M-REGLE VAE model. The script requires:
   • --logging_dir : a directory to which model checkpoints and logs will be written.
   • --data_setting : dataset setting string (e.g. ecgppg or ecg12).
   • --train_data_path : path to the training dataset file (a NumPy .npy file).
   • --validation_data_path : path to the validation dataset file (a NumPy .npy file).
   • --latent_dim : integer latent dimensionality (e.g. 12 or 96).
  Additional optional hyperparameters (e.g. random_seed, learning_rate, batch_size, num_epochs) may be provided.
  
inputs:
  logging_dir:
    type: string
    doc: "Directory to write log files and model checkpoints."
    inputBinding:
      position: 1
      prefix: "--logging_dir"
  data_setting:
    type: string
    doc: "Data setting; for example, ecgppg or ecg12."
    inputBinding:
      position: 2
      prefix: "--data_setting"
  train_data_path:
    type: File
    doc: "Training dataset file (e.g. demo_train/ecgppg_ml_data.npy)."
    inputBinding:
      position: 3
      prefix: "--train_data_path"
  validation_data_path:
    type: File
    doc: "Validation dataset file (e.g. demo_val/ecgppg_ml_data.npy)."
    inputBinding:
      position: 4
      prefix: "--validation_data_path"
  latent_dim:
    type: int
    doc: "Latent dimension for the VAE (e.g. 12 for ecgppg, 96 for ecg12)."
    inputBinding:
      position: 5
      prefix: "--latent_dim"
  random_seed:
    type: int?
    doc: "Optional random seed."
    inputBinding:
      position: 6
      prefix: "--random_seed"
  learning_rate:
    type: float?
    doc: "Optional learning rate."
    inputBinding:
      position: 7
      prefix: "--learning_rate"
  batch_size:
    type: int?
    doc: "Optional batch size."
    inputBinding:
      position: 8
      prefix: "--batch_size"
  num_epochs:
    type: int?
    doc: "Optional number of epochs."
    inputBinding:
      position: 9
      prefix: "--num_epochs"

outputs:
  log_dir:
    type: Directory
    doc: "The logging directory with model checkpoints and logs."
    outputBinding:
      glob: "$(inputs.logging_dir)"

#Dockerfile
#Dockerfile that works for all tools in this collection

