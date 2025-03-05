## Open RStudio ================================================================
### Istall and Load R Libraries ------------------------------------------------
# These are the libraries that will be used for this pipeline. Not all will be
# used for each persons particular project, but it does not hurt to have them
# all installed, loaded, and ready to be used when needed.
# Install  BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
# Install Dada2. You may get an error telling you to install a different version
# of Dada2. Change "3.17" to whatever version RStudio tells you.
BiocManager::install("dada2")
# Install the rest of the libraries needed through BiocManager.
BiocManager::install("phyloseq")
BiocManager::install("DECIPHER")
BiocManager::install("rBLAST")
BiocManager::install("ShortRead")

# Install and other libraries you may need (or install through
# "Install Packages" window). Libraries will only need to be installed once.
# If you get a message saying some packages have more recent versions available,
# and asking if you want to update them, chose "1: ALL".
install.packages("digest")
install.packages("tidyverse")
install.packages("seqinr")
install.packages("ape")
install.packages("vegan")
install.packages("patchwork")
install.packages("remotes")
remotes::install_github("ropensci/bold")
remotes::install_github("ropensci/taxize")
remotes::install_github("fkeck/refdb")
remotes::install_github("tobiasgf/lulu")

## File Housekeeping ===========================================================

# Create all the subdirectories we will use
# Define the directory names
dir_names <- c(
  "data/raw",
  "data/working/trimmed_sequences",
  "data/results",
  "ref"
)
# Create the directories using sapply
sapply(dir_names, dir.create, recursive = TRUE)

# Find all the read files you downloaded (in the download folder), save their
# paths, and confirm. Change USERNAME to your computer username, and DATASET to
# the name of your downloaded reads directory.
downloads <- "/Users/USERNAME/Downloads/DATASET"
# Find all the files in the downloaded reads folder that end with .fastq.gz.
raw_reads <- list.files(downloads, pattern = ".fastq.gz", recursive = TRUE)
head(raw_reads)

# Copy the read files to the "data/raw" directory, and confirm that they are
# there.
file.copy(paste0(downloads, "/", raw_reads), "data/raw", recursive = TRUE)
head(list.files("data/raw"))
