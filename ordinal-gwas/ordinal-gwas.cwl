cwlVersion: v1.2
class: CommandLineTool

label: "OrdinalGWAS Julia Tool Example"

requirements:
  - class: ShellCommandRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: "ordinal_gwas.jl"
        entry: |
          #!/usr/bin/env julia
          ################################################################
          # ordinal_gwas.jl
          # A simple Julia script demonstrating how to run OrdinalGWAS.jl 
          # on genotype + ordinal phenotype + optional covariate data.
          ################################################################

          using OrdinalGWAS
          using CSV
          using DataFrames
          using SnpArrays

          # -- Parse command-line arguments --
          genotype_file = nothing
          phenotype_file = nothing
          covariate_file = nothing
          output_prefix  = "gwas_results"

          # A simple manual parse of ARGS (which contain all command-line arguments).
          # Example:  julia ordinal_gwas.jl --genotype data.bed --phenotype pheno.csv ...
          for i in 1:length(ARGS)
              if ARGS[i] == "--genotype"
                  genotype_file = ARGS[i+1]
              elseif ARGS[i] == "--phenotype"
                  phenotype_file = ARGS[i+1]
              elseif ARGS[i] == "--covariates"
                  covariate_file = ARGS[i+1]
              elseif ARGS[i] == "--output-prefix"
                  output_prefix = ARGS[i+1]
              end
          end

          if isnothing(genotype_file) || isnothing(phenotype_file)
              println("ERROR: Must provide genotype and phenotype files.")
              println("Usage example:")
              println("  julia ordinal_gwas.jl --genotype data.bed --phenotype pheno.csv [--covariates cov.csv] [--output-prefix out]")
              exit(1)
          end

          println("Genotype file:   ", genotype_file)
          println("Phenotype file:  ", phenotype_file)
          println("Covariate file:  ", covariate_file)
          println("Output prefix:   ", output_prefix)

          ################################################################
          # Load genotype data
          ################################################################
          # This will read the data.bed (and matching .bim/.fam) via SnpArrays
          geno = SnpArray(genotype_file)

          ################################################################
          # Load phenotype data
          ################################################################
          # Adjust 'phenotype' column name as needed for your data
          pheno_df = CSV.read(phenotype_file, DataFrame)
          if !("phenotype" in names(pheno_df))
              println("ERROR: The phenotype column 'phenotype' not found in phenotype file.")
              exit(1)
          end
          y = pheno_df[:, "phenotype"]

          ################################################################
          # Load covariates (if file provided)
          ################################################################
          covmat = nothing
          if !isnothing(covariate_file)
              cov_df = CSV.read(covariate_file, DataFrame)
              # By default, assume all columns except something like 'sample_id' are covariates.
              # Adjust to match your actual covariate columns.
              cov_cols = setdiff(names(cov_df), ["sample_id"])
              covmat = Matrix(cov_df[:, cov_cols])
          end

          ################################################################
          # Run ordinal GWAS
          ################################################################
          results = ordinal_gwas(geno, y, covariates = covmat)

          ################################################################
          # Write results to CSV
          ################################################################
          out_csv = "$(output_prefix).csv"
          CSV.write(out_csv, results)
          println("GWAS completed. Results written to ", out_csv)
          
  # Optionally mark our script as executable
      - entry: 
          class: CreateFileRequirement

baseCommand:
  - "julia"
  - "ordinal_gwas.jl"

inputs:
  genotype_file:
    type: File
    label: "Genotype File (PLINK .bed/.bim/.fam, etc.)"
    inputBinding:
      prefix: "--genotype"
      separate: true

  phenotype_file:
    type: File
    label: "Ordinal Phenotype File (CSV)"
    inputBinding:
      prefix: "--phenotype"
      separate: true

  covariate_file:
    type: File?
    label: "Optional Covariates File (CSV)"
    inputBinding:
      prefix: "--covariates"
      separate: true

  output_prefix:
    type: string
    default: "gwas_results"
    label: "Output Prefix"
    inputBinding:
      prefix: "--output-prefix"
      separate: true

outputs:
  gwas_output:
    type: File
    label: "GWAS Results CSV"
    outputBinding:
      glob: "*.csv"
