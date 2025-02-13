# Ordinal GWAS Julia App

This app is a simple command-line tool, written in Julia, that performs an **ordinal genome-wide association study (GWAS)** using [`OrdinalGWAS.jl`](https://github.com/OpenMendel/OrdinalGWAS.jl). Its primary purpose is to test for associations between genetic variants and an **ordinal phenotype** (e.g., disease severity categories).

## 1. Key Features

- **Supports Ordinal Phenotypes**: Uses an ordinal logistic model (cumulative logit / proportional odds).
- **PLINK Format**: Reads genotype data from PLINK `.bed`, `.bim`, and `.fam` files (via [`SnpArrays.jl`](https://github.com/OpenMendel/SnpArrays.jl)).
- **Convenient Covariate Handling**: Accepts an optional covariate file, so you can control for confounding variables (e.g., age, sex, principal components).
- **CSV Output**: Writes the GWAS results to a single `.csv` file for easy downstream analysis.

## 2. Installation and Dependencies

You can run this Ordinal GWAS tool by building and running a **Docker image** that already contains all required dependencies. Below is a Dockerfile (obtained from the OrdinalGWAS GitHub repository) based on **CentOS 7**, which installs Julia, the necessary system libraries, and the relevant Julia packages (`SnpArrays.jl`, `OrdinalMultinomialModels.jl`, and `OrdinalGWAS.jl`).

```dockerfile
FROM centos:7

WORKDIR /root

RUN yum update -y && yum install -y epel-release && yum clean all

RUN yum update -y && yum install -y \
    cmake \
    curl-devel \
    expat-devel \
    gcc \
    gcc-c++ \
    gcc-gfortran \
    gettext-devel \
    git \
    make \
    openssl \
    openssl098e \
    openssl-devel \
    patch \
    svn \
    wget \
    which \
    && yum clean all

ENV PATH /usr/local/sbin:/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/lib64

# Julia
ENV JULIA_VER_MAJ 1.1
ENV JULIA_VER_MIN .0
ENV JULIA_VER $JULIA_VER_MAJ$JULIA_VER_MIN

RUN wget https://julialang-s3.julialang.org/bin/linux/x64/$JULIA_VER_MAJ/julia-$JULIA_VER-linux-x86_64.tar.gz \
    && mkdir /usr/local/julia \
    && tar xf julia-$JULIA_VER-linux-x86_64.tar.gz --directory /usr/local/julia --strip-components=1 \
    && ln -s /usr/local/julia/bin/julia /usr/local/bin/julia \
    && rm -f julia-$JULIA_VER-linux-x86_64.tar.gz

ENV JULIA_PKGDIR /usr/local/julia/share/julia/site

RUN julia -e 'using Pkg; \
    Pkg.add([ \
    PackageSpec(url="https://github.com/OpenMendel/SnpArrays.jl"), \
    PackageSpec(url="https://github.com/OpenMendel/OrdinalMultinomialModels.jl"), \
    PackageSpec(url="https://github.com/OpenMendel/OrdinalGWAS.jl") \
    ]); \
    Pkg.test("OrdinalGWAS");'
```

### Building and Using the Docker Image

1. **Save** the above contents to a file named `Dockerfile`.
2. **Build** the image:
   ```bash
   docker build -t ordinalgwas-centos7 .
   ```
3. **Run** the container interactively or in batch mode, mounting your data directory if needed:
   ```bash
   docker run -it --rm \
       -v /path/to/mydata:/data \
       ordinalgwas-centos7 bash
   ```
   Inside the container, you can use `julia` (with pre-installed OrdinalGWAS) or run your scripts that rely on `OrdinalGWAS.jl`.

## 3. Usage

Assume you have the following files:
- `data.bed`, `data.bim`, `data.fam`: Your genotype dataset in PLINK binary format.
- `phenotype.csv`: A CSV file with a column named **`phenotype`** for the ordinal trait.
- `covariates.csv` *(optional)*: Additional columns (e.g., `cov1`, `cov2`, …) for confounders.

### Command-Line Invocation

```bash
julia ordinal_gwas.jl \
  --genotype data.bed \
  --phenotype phenotype.csv \
  --covariates covariates.csv \
  --output-prefix my_gwas_results
```

**Required Arguments**  
- `--genotype`: Path to `.bed` file (with matching `.bim` and `.fam`).  
- `--phenotype`: Path to CSV containing your ordinal outcome in a column named `phenotype`.

**Optional Arguments**  
- `--covariates`: Path to CSV with columns for covariates.  
- `--output-prefix`: Prefix for the results output file. Defaults to `gwas_results`.

After running, the script writes a CSV file named `my_gwas_results.csv` with association statistics for each variant.

## 4. Script Overview

`ordinal_gwas.jl` does the following:

1. **Parses** command-line arguments for genotype, phenotype, covariates, and output prefix.
2. **Loads** the genotype data from `.bed` (and `.bim/.fam`) using `SnpArray`.
3. **Reads** the phenotype file via `CSV.read` into a `DataFrame`. The column `phenotype` is used as the ordinal trait.
4. **Optionally reads** the covariates file into a `Matrix`.
5. **Runs** the ordinal GWAS using `ordinal_gwas(geno, y, covariates = covmat)`.
6. **Writes** the results to a CSV named `<prefix>.csv`.

## 5. Testing with Synthetic Data

You can test this script **without** real genotype data by creating a small synthetic dataset. Below is an example workflow for generating minimal synthetic genotype and phenotype/covariate files.

### 5.1 Generating Synthetic PLINK Data (Example)

If you already have tools that generate `.bed/.bim/.fam` files, you can adapt them. For illustration, we'll outline a quick approach in Julia to create artificial `.bed/.bim/.fam` data using [`SnpArrays.jl`](https://github.com/OpenMendel/SnpArrays.jl). This is optional and for demonstration purposes only.

```julia
using SnpArrays
using Random

# Set random seed for reproducibility
Random.seed!(1234)

# Number of individuals and markers
n_indiv = 100
n_markers = 10

# Create a random Genotype matrix: Each entry is 0,1,2
geno_mat = rand(0:2, n_indiv, n_markers)

# Build an in-memory SnpArray
geno_snp = SnpArray{UInt8}(geno_mat)

# Write the .bed file
write_bed("test.bed", geno_snp)

# Create a simple .fam file
open("test.fam", "w") do f
    for i in 1:n_indiv
        println(f, "FID$i IID$i 0 0 1 -9")
    end
end

# Create a simple .bim file
open("test.bim", "w") do f
    for m in 1:n_markers
        println(f, "1 rs$m 0 $m A C")
    end
end
```

### 5.2 Generating a Synthetic Phenotype File

Create a CSV file with an **ordinal** phenotype. We simulate categories (1, 2, 3) for each individual:

```julia
using CSV, DataFrames

pheno_df = DataFrame(
    sample_id = ["IID$i" for i in 1:n_indiv],
    phenotype = rand(1:3, n_indiv)
)
CSV.write("test_phenotype.csv", pheno_df)
```

### 5.3 Generating a Synthetic Covariates File

(Optional) If you want to include covariates, for example, an age-like continuous variable and a binary sex variable:

```julia
cov_df = DataFrame(
    sample_id = ["IID$i" for i in 1:n_indiv],
    age = rand(20:80, n_indiv),
    sex = rand(0:1, n_indiv)
)
CSV.write("test_covariates.csv", cov_df)
```

### 5.4 Running the Ordinal GWAS with Synthetic Data

Assuming you have `ordinal_gwas.jl` in the same directory, run:

```bash
julia ordinal_gwas.jl \
  --genotype test.bed \
  --phenotype test_phenotype.csv \
  --covariates test_covariates.csv \
  --output-prefix synthetic_test
```

This should produce a file named `synthetic_test.csv` with association results. Since the data are random, you should not expect meaningful p-values, but it verifies that the workflow functions end-to-end.

## 6. Troubleshooting and Tips

- **Docker Build Errors**: If the Docker build fails, ensure you have network access and that the CentOS repositories are available.  
- **Column Names**: If your phenotype or covariate files use different column names, update the script accordingly.  
- **Memory Constraints**: Large genotype or sample sizes require sufficient memory.  
- **Convergence**: Ordinal logistic models can fail to converge if a category is extremely rare.

## 7. Example CWL File

Below is a **CWL v1.2** `CommandLineTool` specification that runs our Julia script (`ordinal_gwas.jl`). The script itself is placed into the working directory using the `InitialWorkDirRequirement`, so you only need to supply input file paths and an output prefix.

```yaml
cwlVersion: v1.2
class: CommandLineTool

requirements:
  - class: ShellCommandRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: "ordinal_gwas.jl"
        entry: |
          #!/usr/bin/env julia
          ################################################################
          # ordinal_gwas.jl
          # A simple Julia script for OrdinalGWAS.jl
          ################################################################

          using OrdinalGWAS
          using SnpArrays
          using CSV
          using DataFrames

          genotype_file = nothing
          phenotype_file = nothing
          covariate_file = nothing
          output_prefix  = "gwas_results"

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
              exit(1)
          end

          println("Genotype file:   ", genotype_file)
          println("Phenotype file:  ", phenotype_file)
          println("Covariate file:  ", covariate_file)
          println("Output prefix:   ", output_prefix)

          # Load genotype data
          geno = SnpArray(genotype_file)

          # Load phenotype
          pheno_df = CSV.read(phenotype_file, DataFrame)
          if !("phenotype" in names(pheno_df))
              println("ERROR: The phenotype column 'phenotype' not found.")
              exit(1)
          end
          y = pheno_df[:, "phenotype"]

          # Covariates
          covmat = nothing
          if !isnothing(covariate_file)
              cov_df = CSV.read(covariate_file, DataFrame)
              cov_cols = setdiff(names(cov_df), ["sample_id"])
              covmat = Matrix(cov_df[:, cov_cols])
          end

          # Run ordinal GWAS
          results = ordinal_gwas(geno, y, covariates = covmat)

          # Write to CSV
          out_csv = string(output_prefix, ".csv")
          CSV.write(out_csv, results)
          println("GWAS completed. Results written to ", out_csv)

baseCommand:
  - "julia"
  - "ordinal_gwas.jl"

inputs:
  genotype_file:
    type: File
    inputBinding:
      prefix: "--genotype"
      separate: true

  phenotype_file:
    type: File
    inputBinding:
      prefix: "--phenotype"
      separate: true

  covariate_file:
    type: File?
    inputBinding:
      prefix: "--covariates"
      separate: true

  output_prefix:
    type: string
    default: "gwas_results"
    inputBinding:
      prefix: "--output-prefix"
      separate: true

outputs:
  gwas_output:
    type: File
    outputBinding:
      glob: "*.csv"
```

To run this **CWL tool**, simply execute:

```bash
cwltool ordinal-gwas-tool.cwl \
  --genotype_file data.bed \
  --phenotype_file phenotype.csv \
  --covariate_file covariates.csv \
  --output_prefix my_gwas_results
```

Where:
- `data.bed`/`.bim`/`.fam` contain your genotype data.
- `phenotype.csv` has the ordinal outcome column (`phenotype`).
- `covariates.csv` (optional) has additional columns you wish to include as regressors.
- `my_gwas_results` is the prefix for the output CSV.

---

**Contact & More Information**  
- **OrdinalGWAS.jl**: [Github Page](https://github.com/OpenMendel/OrdinalGWAS.jl)  
- **SnpArrays.jl**: [Github Page](https://github.com/OpenMendel/SnpArrays.jl)

Feel free to open an issue or contact the developers if you encounter difficulties.

Happy GWAS-ing!
