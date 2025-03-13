#15August22
# 5 IMPORT AND COMBINE SEQUENCE- AND FEATURE-TABLES ############################
# Here we import and combine trimming/denoising results from multiple runs into
# a single project table for downstream analyses.  The specific procedure used
# depends upon the format of the information being imported and combined.

## File Housekeeping ===========================================================
# Load all R packages you may need, if necessary
library(tidyverse)
library(dada2)
library(data.table)

list.files("data/results")

## Import Different File Types =================================================

### Import dada2 Sequence-Table and representative sequences--------------------
# The Sequence-Table (columns of ASVs and rows of sample names) is the format
# that many downstream programs use, so this does not need to be converted, and
# data imported in other formats will be converted into a sequence-table before
# merging.

# Import md5 your sequence-table, preserving the first row as column header and
# the first column as row header. All tables are saved as tab-delimited text
# files, change "sep = '\t'" to your specific separator. We import as a matrix,
# as required by DADA2
seqtab_md5_PROJECT_MISEQRUN <- as.matrix(
  read.delim(
    "PROJECT_MISEQRUN_sequence-table.tsv",
    header = TRUE,
    sep = "\t",
    row.names = 1
  )
)

# Look at your newly imported MISEQRUN sequence-table for PROJECT.
View(seqtab_md5_PROJECT_MISEQRUN)

# Import the representative-sequence .fasta.
repseq_md5_PROJECT_MISEQRUN <- getSequences(
  "PROJECT_MISEQRUN_rep-seqs-dada2.fasta"
)

### Import Qiime2 feature-table and representative sequences -------------------
# Qiime2 outputs a feature-table (columns of ASV md5 hashes) and representative
# sequence fasta files (which are ASVs with md5 hashes for names). The data from
# these will be merged into a single sequence-table.

# Import the feature-table. When we use biom convert command in Qiime2 to
# convert the .biom table into a .tsv table, it includes an extra row with
# "# Constructed from biom file". "skip = 1" skips this row when reading in this
# table. I add md5 to the name to denote that this table has uses the md5 hash
# instead of ASV.
feattab_md5_PROJECT_MISEQRUN <- read.delim(
  "PROJECT_MISEQRUN2_table-dada2.tsv",
  header = TRUE,
  sep = "\t",
  skip = 1
)

# Import the representative-sequence .fasta output by Qiime2
repseq_md5_PROJECT_MISEQRUN <- getSequences(
  "PROJECT_MISEQRUN_rep-seqs-dada2.fasta"
)

### Import Qiime2 .biom data and representative sequences ----------------------

# Install and load the biomformat library
BiocManager::install("biomformat")
library(biomformat)

# Import the .biom file
feattab_md5_PROJECT_MISEQRUN_biom <- read_biom(
  "PROJECT_MISEQRUN_table-dada2.biom"
)
# Convert the biom-formatted object into a feature-table in matrix format
feattab_md5_PROJECT_MISEQRUN <- as(
  biom_data(feattab_md5_PROJECT_MISEQRUN_biom),
  "matrix"
)

# Import the representative-sequence .fasta.
repseq_md5_PROJECT_MISEQRUN <- getSequences(
  "PROJECT_MISEQRUN_rep-seqs-dada2.fasta"
)

### Import sequence-list table -------------------------------------------------
# Sometimes we save our data in this format (columns of sample names, ASVs, read
# counts, and md5 hashes (optional) for each ASV/sample combination). This
# contains all the information we may need for downstream analyses, it is a tidy
# table (each column a variable), and it is easier to concatenate than either
# the feature-table or sequence-table when done outside of R.

# Import a sequence-list-table.
seqlisttab_md5_PROJECT_MISEQRUN <- read.delim(
  "PROJECT_MISEQRUN_SeqList_Tall.tsv",
  header = TRUE,
  sep = "\t"
)

# !!!!!OPTIONAL!!!!!
# If your sequence-list-table has a column of md5 hashes, you may want to remove
# them if your other sequence-tables do not contain them.

# Remove md5 hash column. In my case this column is called "md5". Change the
# name to match your column heading
seqlisttab_PROJECT_MISEQRUN <- subset(
  seqlisttab_PROJECT_MISEQRUN,
  select = -md5
)
# !!!!!OPTIONAL!!!!!

## Convert Tables ==============================================================

### Feature-Table to Sequence-Table --------------------------------------------
# Transpose a feature-table into a sequence table, and convert the first
# column/row into headings.

# Transpose this feature-table into a sequence table in matrix format, and
# convert the first columns/rows into headings.
seqtab_md5_PROJECT_MISEQRUN <- transpose(
  feattab_md5_PROJECT_MISEQRUN,
  keep.names = "Sample",
  make.names = 1
) %>%
  column_to_rownames(var = "Sample")

# Finally, convert the data.frame into a matrix, as required by DADA2
seqtab_PROJECT_MISEQRUN <- as.matrix(seqtab_PROJECT_MISEQRUN)

# Look at your newly MISEQRUN sequence-table for PROJECT.
View(seqtab_PROJECT_MISEQRUN)

### Sequence-List_Table to Feature-Table ---------------------------------------

# Convert your tall (and tidy) table into a wide table, in form like a
# feature-table.  This uses a tidyr command, so it also makes this table into a
# tibble. We will convert to a matrix later
feattab_md5_PROJECT_MISEQRUN <- pivot_wider(
  seqlisttab_md5_PROJECT_MISEQRUN,
  names_from = sample,
  values_from = count,
  values_fill = 0
)

### Sequence-List_Table to Sequence-Table ---------------------------------------

# Convert your tall (and tidy) table into a wide table, in form like a
# feature-table.  This uses a tidyr command, so it also makes this table into a
# tibble. We will convert to a matrix later
feattab_md5_PROJECT_MISEQRUN <- pivot_wider(
  seqlisttab_md5_PROJECT_MISEQRUN,
  names_from = sample,
  values_from = count,
  values_fill = 0
)

## Merge Sequence-Tables =======================================================
# Here we merge the various tables we imported and converted previously. We use
# 'repeats = "sum"' to add together counts when duplicate sample names and ASV's
# are merged. If you don't want them summed, use 'repeats = "error"', and change
# the name of identical samples. While we are merging sequence-tables with ASVs
# as column headings (because these are needed for downstream analyses), this
# also works if you have replaced ASVs with md5 hashes as column headings.

seqtab_md5_PROJECT <- mergeSequenceTables(
  seqtab_md5_PROJECT_MISEQRUN,
  seqtab_md5_PROJECT_MISEQRUN,
  repeats = "sum",
  orderBy = "abundance"
)
