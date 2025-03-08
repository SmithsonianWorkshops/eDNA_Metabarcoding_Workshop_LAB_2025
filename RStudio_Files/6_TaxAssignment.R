# 8 ASSIGN TAXONOMY ############################################################
## Load Libraries = ============================================================
# Load all R packages you may need, if necessary

library(dada2)
library(digest)
library(rBLAST)
library(tidyverse)
library(seqinr)
library(R.utils)

## Download Reference Database =================================================

# Download the reference database we will use later
reference_url <- "https://www.dropbox.com/s/rrzo8ijod0swnb0/midori_COI_genus_dada2.fasta.gz?dl=1"
dest_file <- sub("\\?dl=1$", "", basename(reference_url))
download.file(reference_url, paste0("ref/", dest_file), mode = "wb")
gunzip(paste0("ref/", dest_file), remove = TRUE)

## Assign Taxonomy With DADA2 ==================================================
# Assign taxonomy using the RDP naive Bayesian classifier. tryRC determines
# whether to also include the reverse
# complement of each sequence. outputBootstraps results in a second table with
# bootstrap support values for each taxonomic assignment. minBoot gives the
# minimum bootstrap required to assign taxonomy. Use whatever table you obtained
# for your earlier analyses (e.g. seqtab.nochim). This command can take a long
# time for large reference databases and large numbers of ASVs. Your reference
# file will have a different path and name then here, please make sure to use
# the correct path and name.
# From the dada2 manual: "assignTaxonomy(...) expects a training fasta file (or
# compressed fasta file) in which the taxonomy corresponding to each sequence is
# encoded in the id line in the following fashion (the second sequence is not
# assigned down to level 6)." Note that all levels above the lowest level must
# have a space, even if there is no name for that level (I've added a third
# example to demonstrate).
#>Level1;Level2;Level3;Level4;Level5;Level6;
#ACCTAGAAAGTCGTAGATCGAAGTTGAAGCATCGCCCGATGATCGTCTGAAGCTGTAGCATGAGTCGATTTTCACATTC
#>Level1;Level2;Level3;Level4;Level5;
#CGCTAGAAAGTCGTAGAAGGCTCGGAGGTTTGAAGCATCGCCCGATGGGATCTCGTTGCTGTAGCATGAGTACGGACAT
#>Level1;Level2;;Level4;Level5;Level6
#CGCTAGAAAGTCGTAGAAGGCTCGGAGGTTTGAAGCATCGCCCGATGGGATCTCGTTGCTGTAGCATGAGTACGGACAT

# taxLevels defines what taxonomic rank each of the levels shown in the above
# example represents.

taxoomy <- assignTaxonomy(
  seqtab_nochim,
  "ref/midori_COI_genus_dada2.fasta",
  taxLevels = c(
    "Phylum",
    "Class",
    "Order",
    "Family",
    "Genus",
    "species"
  ),
  tryRC = FALSE,
  minBoot = 50,
  outputBootstraps = TRUE,
  multithread = TRUE,
  verbose = TRUE
)

save(taxonomy, file = "data/working/tax_rdp.Rdata")
## Examine and Manipulate Taxonomy =============================================
# Look at the taxonomic assignments
View(taxonomy$tax)
View(taxonomy$boot)

# You can check to see all the uniqe values exist in each column
unique(taxonomy$tax[, "Phylum"])
unique(taxonomy$tax[, "Class"])
unique(taxonomy$tax[, "Order"])
unique(taxonomy$tax[, "Family"])
table(taxonomy$tax[, "Phylum"])
### Combine taxonomy and bootstrap tables --------------------------------------
# You can combine the $tax and $boot table, to see simultaneously the taxonomic
# assignment and the bootstrap support for that assignment.

# Join the two tables using an inner-join with dplyr (it shouldn't matter here
# what kind of join you use since the two tables should have the exact same
# number of rows and row headings (actually, now column 1)). I amend bootstrap
# column names with "_boot" (e.g. the bootstrap column for genus would be
# "Genus_boot"). I also add the md5 hash, and rearrange the columnns
taxonomy_rdp <- inner_join(
  as_tibble(taxonomy$tax, rownames = "ASV"),
  as_tibble(taxonomy$boot, rownames = "ASV"),
  by = "ASV",
  suffix = c("", "_boot")
) %>%
  mutate(md5 = repseq_nochim_md5_asv$md5) %>%
  select(
    md5,
    ASV,
    Phylum,
    Phylum_boot,
    Class,
    Class_boot,
    Order,
    Order_boot,
    Family,
    Family_boot,
    Genus,
    Genus_boot,
    species,
    species_boot
  )
dim(taxonomy)
View(taxonomy)

save(
  taxonomy,
  taxonomy_rdp,
  file = "data/working/tax_rdp.RData"
)

## Assign Taxonomy With BLAST+ =================================================

# We can also assign taxonomy using BLAST. Here we will use the program rBLAST
# to identify our ASVs. rBLAST allows you to connect directly to the NCBI
# server, or use a locally saved refernce database (in BLAST format)
# One of the reasons I'm using rBLAST is that it has a command to make a
# BLAST-formatted database from a fasta file.

# Back on the first day we downloaded BLAST+ executables into your project
# directory. We need to make sure that's still available.

# Load path_with_blast object saved on day 1
load("data/working/0_cutadapt_blast.RData")

# Update the system's PATH variable to include BLAST
# NOTE: this only lasts for the current R session and will need to reset
Sys.setenv(PATH = path_with_blast)

# Test that BLAST is installed
system2("blastn", args = "-version")
# You should get:
# blastn: 2.16.0+
# Package: blast 2.16.0, build Jun 25 2024 08:57:24
#
# If not, re-run the section to install BLAST from 2_Install_Cutadapt_BLAST.R

# We also need a blast-formatted database. We are going to use the makeblastdb
# function in rBLAST to make this from the dada2-formatted fasta file in our
# ref folder; this is the same database we used above.

# First, add a directory in /ref to hold the database.
dir.create("ref/midori_COI_genus")
# Make the blast database.
makeblastdb(
  "ref/midori_COI_genus_dada2.fasta",
  db_name = "ref/midori_COI_genus/midori_COI_genus",
  dbtype = "nucl"
)

# Next we load this database into R in the correct format for rBLAST
midori_coi_db <- blast(db = "ref/midori_COI_genus/midori_COI_genus")

# We need to have our representative sequences (the sequences we are going to
# blast, Now we have to reformat our representative-sequence table to be a named vector
View(repseq_nochim_md5_asv)

# Make a DNAStringSet object from our representative sequences
sequences_dna <- DNAStringSet(setNames(
  repseq_nochim_md5_asv$ASV,
  repseq_nochim_md5_asv$md5
))
View(sequences_dna)

# You can also get this from the fasta file we downloaded earlier.
sequences_fasta <- readDNAStringSet("data/results/PROJECTNAME_rep-seq.fas")

# They make the same thing.
head(sequences_dna)
head(sequences_fasta)

# Finally, we blast our representative sequences against the database we created
taxonomy_blast <- predict(
  midori_coi_db,
  sequences_dna,
  outfmt = "6 qseqid sseqid pident",
  BLAST_args = "-perc_identity 85 -max_target_seqs 1 -qcov_hsp_perc 80"
)
View(taxonomy_blast)

# Now lets combine the two taxonomy tables to see how the the two methods
# compare
taxonomy_rdp_blast <- left_join(
  taxonomy_rdp,
  taxonomy_blast,
  join_by(ASV == qseqid)
)


# Export this table as a .tsv file. I name it with Project Name,
# the reference library used, and taxonomy (vs. speciesID).
write.table(
  taxonomy,
  file = "data/results/PROJECTNAME_REFERENCE_taxonomy.tsv",
  quote = FALSE,
  sep = "\t",
  row.names = FALSE
)

save(
  midori_coi_db,
  sequences_dna,
  taxonomy_blast,
  taxonomy_rdp_blast,
  file = "tax_rdp_blast.RData"
)
