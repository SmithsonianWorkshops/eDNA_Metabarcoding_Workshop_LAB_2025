# PHYLOSEQ ###################################################################
# Phyloseq relies on a phyloseq object for its operations. Phyloseq objects
#  consist of 5 components, but not all are required, only ones that are needed
# for the desired operations. The 5 components are: otu_table, sample_data,
# tax_table, phy_tree, and refseq (not sure why the last doesn't get an
# underscore). We will go into more details about the components below, when we
# configure them.

## File Housekeeping ===========================================================
# Load all R packages you may need, if necessary

library(phyloseq)
library(ape)
library(DECIPHER)
library(tidyverse)
## Prepare Components to be Imported Into Phyloseq =============================

### sequence-table -------------------------------------------------------------

# Make phyloseq otu_table from the sequence-table (columns of ASV/OTUs, rows of
# samples). If you want to use a feature-table (columns of samples, rows of
# ASV/OTUs) instead, use "taxa_are_rows = TRUE"
OTU <- otu_table(seqtab_nochim_md5, taxa_are_rows = FALSE)
View(OTU)
### tax_table ------------------------------------------------------------------
# Row headings for the tax_table should match the column headings in the
# otu_table (which in this case are md5 hashes of the ASV's). Also, our current
# "taxonomy" has a taxonomy table and a bootstrap table, but for the tax_table
# we need need a taxonomy-only table.

# Make a new taxonomy-only table, and replace the current rownames (ASVs) with
# md5 hashes, and convert to a matrix (which is the type of table needed by
# phyloseq.
taxonomy_phyloseq <- as_tibble(taxonomy$tax, rownames = "ASV") %>%
  mutate(RowNames = repseq_nochim_md5) %>%
  column_to_rownames(var = "RowNames") %>%
  select(-ASV) %>%
  as.matrix()
View(taxonomy_phyloseq)

# Make phyloseq tax-table from our taxonomy-only table.
TAX <- tax_table(taxonomy_phyloseq)
View(TAX)

### sample_data ----------------------------------------------------------------
# You should have already imported your metadata in VisualizeResults, but if you
# don't have it, here is the code again.
meta <- read.delim(
  "dataset1.tsv",
  header = TRUE,
  sep = "\t",
  colClasses = c(depth_ft = "character")
)

# Filter yuur metadata to only include the samples from your dataset.
# Like tax_table and otu_table, sample_data needs rownames as Sample_ID instead
# of a column. However, unlike the previous commands, sample_data needs a
# dataframe (unlike otu_table and tax_table, which require a matrix), so we need
# to convert our first column to a rowname, but that's it. We can do all this
# in one command.
meta_dataset <- meta %>%
  filter(Sample_ID %in% rownames(seqtab_nochim)) %>%
  column_to_rownames(var = "Sample_ID")
View(meta_dataset)

# Look at the metadata file, make sure everything looks okay.
View(meta_dataset)

# Look at data type of all the columns of the table.
str(meta_dataset)
# Make a phyloseq sample_data file from "metadata"
SAMPLE <- sample_data(meta_dataset)

### refseq ---------------------------------------------------------------------
# The refseq phyloseq-class item must contain sequences of equal length, which
# in most cases means it needs to be aligned first. We will align using
# DECIPHER and rMSA

# We need a DNAString from our representative sequences and md5 hashs. This is
# the format for DECIPHER, rMSA and many other phylogenetic programs in R.
# We should have already made this in the TaxAssignment section. A quick check
# to see is just to look at it.
sequences_dna
# If you don't have it (you get an error), here is the script again.
sequences_dna <- DNAStringSet(setNames(
  repseq_nochim_md5_asv$ASV,
  repseq_nochim_md5_asv$md5
))
View(sequences_dna)
sequences_dna
# Align using DECIPHER. DECIPHER "Performs profile-to-profile alignment of
# multiple unaligned sequences following a guide tree" (from the manual). We do
# not give a preliminary guide tree, so one is automatically created. For each
# iteration, a new guide tree is created based on the previous alignment, and
# the sequences are realigned. For each refinement, portions of the sequences
# are realigned to the original, and the best alignment is kept. useStructures
# probably should be FALSE if you are using COI or another protein-coding
# region. If you are using RNA, then "useStructures=TRUE" may give a better
# alignment. However, since our sequences are in DNA format, you first have
# to convert sequences.dna into an RNAStringSet. Alignments can take a long time
# if you have lots of ASVs. Use more refinements and/or interations to get a
# "better" alignment, but increasing these will take more computing time.

# Make an alignment from your DNA data.
alignment_decipher <- AlignSeqs(
  sequences_dna,
  guideTree = NULL,
  anchor = NA,
  gapOpening = c(-15, -10),
  gapExtension = c(-3, -2),
  terminalGap = c(-15, -10),
  iterations = 3,
  refinements = 4,
  processors = NULL,
  useStructures = FALSE
)
# Look at a brief "summary" of the alignment. This shows the alignment length,
# the first 5 and last 5 ASVs and the first 50 and last 50 bps of the alignment.
alignment_decipher

# You can also look at the entire alignment in your browser.
BrowseSeqs(alignment_decipher)

# Create a reference sequence (refseq) object from the alignment. This contains
# the ASV sequences, using the md5 hashes as names.
REFSEQ <- DNAStringSet(alignment_decipher, use.names = TRUE)
# Look at the refseq object, just to make sure it worked
head(REFSEQ)

# Alignm using the mattf program in rMSA. This is much faster than DECIPHER,
# although the alignments don't look quite as good.
alignment_mafft <- mafft(sequences_dna)
# Create a reference sequence (refseq) object from the alignment. This contains
# the ASV sequences, using the md5 hashes as names.
REFSEQ <- DNAStringSet(alignment_mafft, use.names = TRUE)
# Look at the refseq object, just to make sure it worked
head(REFSEQ)

### phy_tree -------------------------------------------------------------------
# We can create a phylogenetic (or at least, a phenetic) tree using the
# alignment we just created using the program ape.

# For ape, the aligned sequences must be in binary format (DNAbin, which reduces
# the size of large datasets), so we first convert the DNAstring alignment.
alignment_dnabin <- as.DNAbin(alignment_decipher)

# Create pairwise distance matrix in ape. There are many different models to use.
# Here we are using the Tamura Nei 93 distance measure. Turning the resulting
# distances into a matrix (using as.matrix = TRUE) results in a table of
# pairwise distances.
pairwise_tn93 <- dist.dna(
  alignment_dnabin,
  model = "tn93",
  as.matrix = TRUE
)
# NOTE: If your sequences are highly divergent, pairwise distance will not be
# calculatable by dist.dna, and you must use another method. I rarely have
# a distance matrix that does not contain any NaN's (the result for pairs
# without a distance). ape has a alternative tree-building command for each
# method that is meant to deal with a some NaNs. However, if there are too many
# NaNs, tree-building will not work well. In this case, we can obtain
# maximum-likelihood distances using the program phangorn, which seems to be
# able to obtain distances even from highly divergent sequences.

# Check the number of NaNs in dist.dna, and the proportion of all distance. I
# don't know how many NaNs are too many, but if there are more than a few, I
# would prefer to be safe and use ml distances.
length(is.nan(pairwise_tn93))
length(pairwise_tn93) / length(is.nan(pairwise_tn93))

# Make an improved neighbor-joining tree out of our pairwise distance matrix.
# ape has other tree-building phenetic methods to use as well, such as nj or
# upgm. If there are any NaNs in your data, use "bionjs", otherwise use "bionj".
# If you used a different distance model (ml, K80, F84, etc) replace "tn93"
# with the model used.
tree_tn93_bionj <- bionjs(pairwise_tn93)

# Look at the tree. Of course, if there are a lot of ASV's, the tree is pretty
# much indecipherable, even with lots of editing using ggplot2. We will look at
# the tree in greater detail from the phyloseq object, below.
plot(tree_tn93_bionj)

# Create a phyloseq tree object from our neihbor-joining tree.
TREE <- phy_tree(tree_tn93_bionj)

### phyloseq object ------------------------------------------------------------
# We use the components created above to create a phyloseq object. For the
# otu_table, we need to tell phyloseq the orientation of the table (Samples as
# rows vs. ASV's, here labelled "taxa", as rows). Remember, the default output
# of dada2 is taxa as rows. You can use our transposed table (feature-table),
# and make "taxa_are_rows = TRUE", but it didn't work as well for me, so I
# suggest you stick with the default format.

physeq <- phyloseq(
  OTU,
  TAX,
  SAMPLE,
  REFSEQ,
  TREE
)

# There are lots of parameters of the phyloseq object you can look at. Part of
# the reason for looking at these is to make sure the values are what you
# expect.
ntaxa(physeq)
nsamples(physeq)
sample_names(physeq)
sample_variables(physeq)
otu_table(physeq)[1:5, 1:5]
tax_table(physeq)[1:5, 1:5]
phy_tree(physeq)
taxa_names(physeq)[1:20]

# We can also look at the tree in greater detail, including adding labels that
# show factor variables for each branch. "color", "shape", and "size" are all
# terminal branch labels that can show variable values.  "base.spacing" and
# "min.abundance" are for making these labels easier to see when there are a
# lot.
plot_tree(
  physeq,
  ladderize = "left",
  color = "filter_size",
  shape = "tank",
  size = "abundance",
  base.spacing = 0.03,
  min.abundance = 2,
  label.tips = "Class"
)


plot_richness(
  physeq,
  x = "filter_size",
  measures = c("Shannon", "Fisher"),
  color = "filter_size"
)
ord_euclidean <- ordinate(physeq, "MDS", "euclidean")
plot_ordination(physeq, ord.euclidean, type = "samples", color = "tank")
plot_ordination(physeq, ord.euclidean, type = "samples", color = "filter_size")
