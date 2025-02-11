# gvcf_to_vds.py
  
```python
import hail as hl
import logging
import os
import sys
import argparse
import shutil

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def get_chromosome_intervals(chromosomes, interval_size, reference_genome):
    """Generate fixed-size intervals for specified chromosomes."""
    chrom_lengths = {
        "chr1": 248956422,
        "chr2": 242193529,
        "chr3": 198295559,
        "chr4": 190214555,
        "chr5": 181538259,
        "chr6": 170805979,
        "chr7": 159345973,
        "chr8": 145138636,
        "chr9": 138394717,
        "chr10": 133797422,
        "chr11": 135086622,
        "chr12": 133275309,
        "chr13": 114364328,
        "chr14": 107043718,
        "chr15": 101991189,
        "chr16": 90338345,
        "chr17": 83257441,
        "chr18": 80373285,
        "chr19": 58617616,
        "chr20": 64444167,
        "chr21": 46709983,
        "chr22": 50818468,
        "chrX": 156040895,
        "chrY": 57227415
    }

    intervals = []
    for chromosome in chromosomes:
        if chromosome in chrom_lengths:
            chrom_length = chrom_lengths[chromosome]
            for start in range(1, chrom_length + 1, interval_size):
                end = min(start + interval_size - 1, chrom_length)
                intervals.append(
                    hl.utils.Interval(
                        hl.genetics.Locus(chromosome, start, reference_genome),
                        hl.genetics.Locus(chromosome, end, reference_genome),
                        includes_start=True,
                        includes_end=True
                    )
                )
    return intervals

def process_chromosomes(gvcf_paths, output_base_path, spark_conf, chromosomes, interval_size, target_records, reference_genome="GRCh38"):
    """Process each chromosome separately while reusing the Hail initialization."""
    hl.init(
        quiet=True,
        backend='spark',
        default_reference=reference_genome,
        spark_conf=spark_conf
    )

    try:
        for chromosome in chromosomes:
            output_path = f"{output_base_path}_{chromosome}.vds"
            logging.info(f"Processing chromosome {chromosome} into {output_path}")

            # Get intervals for the current chromosome
            intervals = get_chromosome_intervals([chromosome], interval_size, reference_genome)

            combiner = hl.vds.new_combiner(
                output_path=output_path,
                temp_path="./temp",
                reference_genome=reference_genome,
                gvcf_paths=gvcf_paths,
                intervals=intervals,
                target_records=target_records
            )
            combiner.run()

            # Archive the VDS for the current chromosome
            shutil.make_archive(output_path, 'tar', output_path)
            logging.info(f"Chromosome {chromosome} VDS archived to {output_path}.tar")

        logging.info("All chromosomes processed successfully.")
    except Exception as e:
        logging.error(f"Error processing chromosomes: {e}", exc_info=True)
        sys.exit(1)
    finally:
        hl.stop()  # Ensure Hail shuts down properly

def parse_args():
    parser = argparse.ArgumentParser(description="Combine GVCF files and create chromosome-specific VDS tar files.")
    parser.add_argument("--gvcf-paths", nargs="*", required=True, help="Paths to GVCF files.")
    parser.add_argument("--output", required=True, help="Base path for the output VDS files.")
    parser.add_argument("--chromosomes", nargs="*", required=True, help="Chromosomes to include in the merging process.")
    parser.add_argument("--interval-size", type=int, required=True, help="Interval size in base pairs (e.g., 10Mb or 20Mb).")
    parser.add_argument("--target-records", type=int, default=500_000_000, help="Target number of records per task.")
    parser.add_argument("--num-cores", type=int, default=35, help="Number of CPU cores.")
    parser.add_argument("--driver-ram", type=int, default=30, help="Driver memory in GB.")
    parser.add_argument("--executor-ram", type=int, default=30, help="Executor memory in GB.")
    return parser.parse_args()

def main():
    args = parse_args()
    spark_conf = {
        'spark.driver.memory': f'{args.driver_ram}g',
        'spark.executor.memory': f'{args.executor_ram}g',
        'spark.cores.max': str(args.num_cores),
        'spark.master': f'local[{args.num_cores}]',
        'spark.driver.extraJavaOptions': '--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED',
        'spark.executor.extraJavaOptions': '--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED'
    }

    # Process GVCFs by cycling through chromosomes
    process_chromosomes(
        gvcf_paths=args.gvcf_paths,
        output_base_path=args.output,
        spark_conf=spark_conf,
        chromosomes=args.chromosomes,
        interval_size=args.interval_size,
        target_records=args.target_records
    )

if __name__ == "__main__":
    main()
```



# vds_to_vcf.py


```python
#!/usr/bin/env python3
"""
VDS to VCF Conversion Tool using Hail
Version: 1.0.6

Revision History:
v1.0.0 - Initial version with basic VDS to VCF conversion functionality
v1.0.1 - Added resource monitoring and improved error handling
v1.0.2 - Enhanced progress logging
v1.0.3 - Added support for handling multi-allelic variants
v1.0.4 - Fixed VCF export parameters
v1.0.5 - Added gvcf_info field flattening
v1.0.6 - Fixed source context for field annotations and cast DS field to float64

Author: Based on work by Dave Roberson
Date: 2025-01-14
"""

import hail as hl
import os
import logging
import argparse
import tarfile
import shutil
import psutil
import threading
import time

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def monitor_resources():
    """
    Monitor and log system resource usage periodically
    """
    while True:
        cpu_percent = psutil.cpu_percent(interval=1, percpu=True)
        memory = psutil.virtual_memory()
        
        logging.info(f"\nResource Monitor:")
        logging.info(f"CPU Usage per core: {cpu_percent}")
        logging.info(f"Average CPU Usage: {sum(cpu_percent)/len(cpu_percent):.1f}%")
        logging.info(f"Memory Usage: {memory.percent}% (Used: {memory.used/1024/1024/1024:.1f}GB, Available: {memory.available/1024/1024/1024:.1f}GB)")
        
        time.sleep(300)  # Log every 5 minutes

def extract_vds_tar(tar_path):
    """
    Extract tarred VDS file and return the path to extracted directory
    """
    logging.info(f"Extracting VDS from tar file: {tar_path}")
    extract_dir = os.path.basename(tar_path)[:-4]  # Remove .tar extension
    
    # Create directory if it doesn't exist
    os.makedirs(extract_dir, exist_ok=True)
    
    # Extract the tar file
    with tarfile.open(tar_path, "r") as tar:
        logging.info(f"Contents of {tar_path}:")
        for member in tar.getmembers():
            logging.info(f"  {member.name}")
        tar.extractall(extract_dir)
    
    return extract_dir

def init_hail_with_spark(spark_cores, spark_memory):
    """
    Initialize Hail with Spark local backend configuration
    """
    spark_conf = {
        'spark.driver.memory': f'{spark_memory}g',
        'spark.driver.maxResultSize': f'{spark_memory}g',
        'spark.local.dir': './spark_temp',
        'spark.master': f'local[{spark_cores}]',
        'spark.executor.heartbeatInterval': '1000000',
        'spark.network.timeout': '1000000',
        'spark.storage.level': 'MEMORY_AND_DISK',
        'spark.driver.extraJavaOptions': '-XX:+UseG1GC',
        'spark.executor.extraJavaOptions': '-XX:+UseG1GC',
        'spark.sql.shuffle.partitions': '200',
        'spark.sql.files.maxPartitionBytes': '512mb',
        'spark.memory.fraction': '0.9',
        'spark.memory.storageFraction': '0.3',
        'spark.rdd.compress': 'true',
        'spark.default.parallelism': str(spark_cores * 2)
    }
    
    # Initialize Hail
    hl.init(spark_conf=spark_conf, tmp_dir='./hail_temp', default_reference='GRCh38')
    logging.info("Hail initialized with Spark configuration")

def convert_vds_to_vcf(vds_path, output_vcf):
    """
    Convert VDS to VCF format with progress logging
    """
    logging.info(f"Reading VDS from {vds_path}")
    # Load VDS
    vds = hl.vds.read_vds(vds_path)
    
    logging.info("Converting VDS to dense MatrixTable")
    # Convert VDS to dense MatrixTable
    mt = hl.vds.to_dense_mt(vds)
    
    # Log the schema
    logging.info("MatrixTable schema after conversion:")
    logging.info(f"Row fields: {mt.row.dtype}")
    logging.info(f"Column fields: {mt.col.dtype}")
    logging.info(f"Entry fields: {mt.entry.dtype}")
    
    # Rename LGT to GT if necessary
    if 'LGT' in mt.entry:
        mt = mt.rename({'LGT': 'GT'})
        logging.info("Renamed LGT field to GT")

    # Flatten gvcf_info struct into separate fields
    logging.info("Flattening gvcf_info struct fields")
    if 'gvcf_info' in mt.entry:
        mt = mt.select_entries(
            GT=mt.GT,
            DP=mt.DP,
            GQ=mt.GQ,
            MIN_DP=mt.MIN_DP,
            LA=mt.LA,
            LAD=mt.LAD,
            LPGT=mt.LPGT,
            LPL=mt.LPL,
            RGQ=mt.RGQ,
            BaseQRankSum=mt.gvcf_info.BaseQRankSum,
            # Cast DS to float64 to comply with VCF format
            DS=hl.float64(mt.gvcf_info.DS),
            ExcessHet=mt.gvcf_info.ExcessHet,
            InbreedingCoeff=mt.gvcf_info.InbreedingCoeff,
            MLEAC=mt.gvcf_info.MLEAC,
            MLEAF=mt.gvcf_info.MLEAF,
            MQRankSum=mt.gvcf_info.MQRankSum,
            RAW_MQandDP=mt.gvcf_info.RAW_MQandDP,
            ReadPosRankSum=mt.gvcf_info.ReadPosRankSum,
            PID=mt.PID,
            PS=mt.PS,
            SB=mt.SB
        )
        logging.info("gvcf_info struct flattened into individual fields")
    
    # Handle multi-allelic variants
    logging.info("Processing multi-allelic variants")
    mt = hl.split_multi(mt)
    logging.info("Multi-allelic variants split")
    
    # Export to VCF
    logging.info(f"Exporting to VCF: {output_vcf}")
    hl.export_vcf(mt, output_vcf, tabix=True)
    
    return output_vcf

def parse_args():
    parser = argparse.ArgumentParser(description="Convert VDS files to VCF format using Hail.")
    parser.add_argument("--tarred-vds-file", required=True, help="Path to input VDS tar file")
    parser.add_argument("--output-vcf", required=True, help="Path to output VCF file")
    parser.add_argument("--num-cores", type=int, default=8, help="Number of CPU cores")
    parser.add_argument("--driver-memory", type=int, default=100, help="Driver memory in GB")
    return parser.parse_args()

def main():
    args = parse_args()
    
    # Start resource monitoring in a background thread
    monitor_thread = threading.Thread(target=monitor_resources, daemon=True)
    monitor_thread.start()
    
    # Create temporary directories
    os.makedirs('./spark_temp', exist_ok=True)
    os.makedirs('./hail_temp', exist_ok=True)
    
    try:
        # Extract VDS from tar file
        vds_path = extract_vds_tar(args.tarred_vds_file)
        
        # Initialize Hail
        init_hail_with_spark(args.num_cores, args.driver_memory)
        
        # Perform conversion
        logging.info("Starting VDS to VCF conversion...")
        output_path = convert_vds_to_vcf(vds_path, args.output_vcf)
        
        logging.info(f"Conversion completed successfully! Output file: {output_path}")
        
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")
        raise
    finally:
        hl.stop()
        # Clean up extracted VDS directory
        if os.path.exists(vds_path):
            shutil.rmtree(vds_path)

if __name__ == "__main__":
    main()

```
