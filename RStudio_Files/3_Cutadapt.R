# CUTADAPT #####################################################################

## File Housekeeping ===========================================================

# Load necessary libraries
library(tidyverse)


# Make a list of all the files in your "data/raw" folder.
reads_to_trim <- list.files("data/raw")
head(reads_to_trim)
# Separate files by read direction (R1,R2), and save each list as an object
reads_to_trim_F <- reads_to_trim[str_detect(reads_to_trim, "R1_001.fastq.gz")]
reads_to_trim_R <- reads_to_trim[str_detect(reads_to_trim, "R2_001.fastq.gz")]

# Separate the elements of "reads.to.trim.F" by underscore, and save the first
# element as "sample.names".
sample_names <- sapply(strsplit(basename(reads.to_trim_F), "_"), `[`, 1)
head(sample_names)

# Define the path to your primer definition fasta file if you have more than
# one potential primer to trim.

# Again, for the path to the primer files, replace "PRIMERF" or "PRIMERR" with
# the name of the forward and reverse primer file, respectively.

# THE PATHS SHOWN BELOW ARE EXAMPLES ONLY. PLEASE CHANGE PATH TO YOUR PRIMER FILES.
path_to_Fprimers <- "eDNA_Metabarcoding_Workshop_LAB_2025-main/primers/COImlIntF.fas"
path_to_Rprimers <- "eDNA_Metabarcoding_Workshop_LAB_2025-main/primers/jgCOIR.fas"

## Run Cutadapt ================================================================

# The following for loop runs cutadapt on paired samples, one pair at a time.

for (i in seq_along(sample.names)) {
  system2(
    cutadapt, args = c(
      "-e 0.2 --discard-untrimmed --minimum-length 30 --cores=0",
      "-g", paste0("file:",path_to_Fprimers),
      "-G", paste0("file:",path_to_Rprimers),
      "-o", paste0(
        "data/working/trimmed_sequences/",
        sample.names[i],
        "_trimmed_R1.fastq.gz"
      ),
      "-p", paste0(
        "data/working/trimmed_sequences/",
        sample.names[i],
        "_trimmed_R2.fastq.gz"
      ),
      paste0(
        "data/raw/",
        reads_to_trim_F[i]
      ),
      paste0(
        "data/raw/",
        reads_to_trim_R[i]
      )
      )
    )
}

# We are including our default parameters for cutadapt. You can change these
# parameters if you have prefer others.

# -e 0.2 allows an error rate of 0.2 (20% of primer basepairs can me wrong)

# --minimum-length 30 removes all reads that are not at least 30 bp. However,
# as currently implemented in cutadapt, this does not always work correctly,
# and sometimes it removes the sequence of the reads, but not the name, leaving
# empty reads. We deal with this later in the pipeline.

# --cores=0 tells cutadapt how many cores to use whiles trimming. 0 sets cutadapt
# to automatically detect the number of cores.

# -g and -G are the paths to the 5' primers with spacers

# -o is the output for trimmed R1 reads
# -p is the output for the trimmed paired R2 reads

# The final line contains the two paired input files
