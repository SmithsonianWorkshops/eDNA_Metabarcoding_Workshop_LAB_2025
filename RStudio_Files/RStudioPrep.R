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
# Install Phyloseq
BiocManager::install("phyloseq")
# Install DECIPHER
BiocManager::install("DECIPHER")

# Install and other libraries you may need (or install through
# "Install Packages" window). Libraries will only need to be installed once.
install.packages("digest")
install.packages("tidyverse")
install.packages("seqinr")
install.packages("ape")

# Load all the libraries that will be needed for this pipeline. These will have
# to be reloaded every time you restart RStudio
library(dada2)
library(digest)
library(tidyverse)
library(seqinr)
library(ape)


## File Housekeeping ===========================================================

# Create all the subdirectories we will use
# Define the directory names
dir_names <- c(
  "data/raw",
  "data/working/trimmed_sequences",
  "data/results"
)
# Create the directories using sapply
sapply(dir_names, dir.create, recursive = TRUE)