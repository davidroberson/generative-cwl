# Ordinal GWAS Julia App

This app is a simple command-line tool, written in Julia, that performs an **ordinal genome-wide association study (GWAS)** using [`OrdinalGWAS.jl`](https://github.com/OpenMendel/OrdinalGWAS.jl). Its primary purpose is to test for associations between genetic variants and an **ordinal phenotype** (e.g., disease severity categories).

## 1. Key Features

- **Supports Ordinal Phenotypes**: Uses an ordinal logistic model (cumulative logit / proportional odds).
- **PLINK Format**: Reads genotype data from PLINK `.bed`, `.bim`, and `.fam` files (via [`SnpArrays.jl`](https://github.com/OpenMendel/SnpArrays.jl)).
- **Convenient Covariate Handling**: Accepts an optional covariate file, so you can control for confounding variables (e.g., age, sex, principal components).
- **CSV Output**: Writes the GWAS results to a single `.csv` file for easy downstream analysis.

## 2. Installation and Dependencies

### Julia and Package Requirements

1. [Julia](https://julialang.org/downloads/) (version 1.6+ recommended).
2. The following Julia packages need to be installed in your environment:
   - **OrdinalGWAS.jl**
   - **SnpArrays.jl**
   - **CSV.jl**
   - **DataFrames.jl**

You can install them from the Julia REPL:

```julia
using Pkg
Pkg.add(["OrdinalGWAS", "SnpArrays", "CSV", "DataFrames"])
```

### Scripts

- **`ordinal_gwas.jl`**: The main script that orchestrates reading inputs, performing the ordinal GWAS, and writing results.

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

# Create a simple .fam file with minimal required columns: FID, IID, father, mother, sex, phenotype
open("test.fam", "w") do f
    for i in 1:n_indiv
        println(f, "FID$i IID$i 0 0 1 -9")
    end
end

# Create a simple .bim file with minimal columns: chrom, snp, genDist, bpPos, allele1, allele2
open("test.bim", "w") do f
    for m in 1:n_markers
        println(f, "1 rs$m 0 $m A C")
    end
end
```

This yields `test.bed`, `test.bim`, `test.fam` for 100 individuals × 10 markers.

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

- **Installation Issues**: Check that your Julia environment has the necessary packages. You can also consider a Docker/Singularity container with these dependencies pre-installed.
- **Column Names**: If your phenotype or covariate files use column names other than `"phenotype"`, `"sample_id"`, etc., update the script to match your actual file structure.
- **Memory Constraints**: With very large genotype files, you may need more RAM. For ~10,000 individuals and ~1 million variants, typical modern workstations should suffice, but monitor memory usage.
- **Convergence**: Ordinal logistic models can fail to converge if a category is extremely rare (e.g., no samples in one category). Ensure your phenotype distribution is suitable for ordinal modeling.

---

**Contact & More Information**  
- **OrdinalGWAS.jl**: [Github Page](https://github.com/OpenMendel/OrdinalGWAS.jl)  
- **SnpArrays.jl**: [Github Page](https://github.com/OpenMendel/SnpArrays.jl)

Feel free to open an issue or contact the developers if you encounter difficulties.

Happy GWAS-ing!
