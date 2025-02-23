## Open RStudio ================================================================
### Istall and Load R Libraries ------------------------------------------------
# These are the libraries that will be used for this pipeline. Not all will be
# used for each persons particular project, but it does not hurt to have them
# all installed, loaded, and ready to be used when needed.
# Install  BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE)){
  install.packages("BiocManager")
}
# Install Dada2. You may get an error telling you to install a different version
# of Dada2. Change "3.17" to whatever version RStudio tells you.
BiocManager::install("dada2", version = "3.19")
# Install the rest of the libraries needed through BiocManager.
BiocManager::install("phyloseq")
BiocManager::install("msa")
BiocManager::install("DECIPHER")
BiocManager::install("rBLAST")

# Install and other libraries you may need (or install through
# "Install Packages" window). Libraries will only need to be installed once.
install.packages("digest")
install.packages("tidyverse")
install.packages("seqinr")
install.packages("ape")
install.packages("vegan")
install.packages("patchwork")
remotes::install_github("fkeck/refdb")

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