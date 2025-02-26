
# 8 ASSIGN TAXONOMY ############################################################
## Load Libraries = ============================================================
# Load all R packages you may need, if necessary

library(dada2)
library(digest)
library(rBLAST)
library(tidyverse)
library(seqinr)

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

taxonomy_rdp <- assignTaxonomy(
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

save(taxonomy_rdp, file = "data/working/tax_rdp.Rdata")
## Examine and Manipulate Taxonomy =============================================
# Look at the taxonomic assignments
View(taxonomy_rdp$tax)
View(taxonomy_rdp$boot)

# You can check to see all the uniqe values exist in each column
unique(taxonomy_rdp$tax[, "Phylum"])
unique(taxonomy_rdp$tax[, "Class"])
unique(taxonomy_rdp$tax[, "Order"])
unique(taxonomy_rdp$tax[, "Family"])
table(taxonomy_rdp$tax[, "Phylum"])
### Combine taxonomy and bootstrap tables --------------------------------------
# You can combine the $tax and $boot table, to see simultaneously the taxonomic
# assignment and the bootstrap support for that assignment.

# Convert taxonomy and bootstrap tables into tibbles (with "ASV" as column 1)
taxonomy_rdp_tax <- as_tibble(
  taxonomy_rdp$tax,
  rownames = "ASV"
)
dim(taxonomy_rdp_tax)

taxonomy_rdp_boot <- as_tibble(
  taxonomy_rdp$boot,
  rownames = "ASV"
)
dim(taxonomy_rdp_boot)

# Join the two tables using an inner-join with dbplyr (it shouldn't matter here
# what kind of join you use since the two tables should have the exact same
# number of rows and row headings (actually, now column 1)). I amend bootstrap
# column names with "_boot" (e.g. the bootstrap column for genus would be
# "Genus_boot")
taxonomy <- inner_join(
  taxonomy_rdp_tax,
  taxonomy_rdp_boot,
  by = "ASV",
  suffix = c("", "_boot")
)
dim(taxonomy)
View(taxonomy)

# Add md5 hash from earlier. The order of ASV's is the same as the sequence-
# table, so there shouldn't be any problem, but you can always redo the md5
# hash conversion here.
taxonomy_md5 <- cbind(
  taxonomy,
  md5 = repseq_nochim_md5_asv$md5
)
View(taxonomy_md5)

# Rearrange columns so that the md5 hash comes first, then the ASV, then each
# classfication level followed by it's respective bootstrap column.
taxonomy_md5 %>%
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
    Species,
    Species_boot
  )
View(taxonomy_md5)

## Assign Taxonomy With BLAST+ =================================================

# We can also assign taxonomy using BLAST. Here we will use the program rBLAST
# to identify our ASVs. rBLAST allows you to connect directly to the NCBI
# server, or use a locally saved refernce database (in BLAST format)
# One of the reasons I'm using rBLAST is that it has a command to make a
# BLAST-formatted database from a fasta file.

# We first need a blast-formatted database. We are going to use the makeblastdb
# function in rBLAST to make this from the dada2-formatted fasta file in our
# ref folder; this is the same database we used above.

# First, add a directory in /ref to hold the database.
dir.create("ref/midori_COI_genus")
# Make the blast database.
makeblastdb(
  "ref/midori_COI_curated_genus_dada2.fasta",
  db_name = "ref/midori_COI_genus/midori_COI_genus",
  dbtype = "nucl"
)

# Next we load this database into R in the correct format for rBLAST
midori_coi_db <- blast(db = "ref/midori_COI_genus/midori_COI_genus")

# We need to have our representative sequences (the sequences we are going to
# blast, Now we have to reformat our representative-sequence table to be a named vector
View(repseq_nochim_md5_asv)
# Make a new vector from the ASV column of the dataframe
sequences <- repseq_nochim_md5_asv$ASV
# Add the md5 column as names
names(sequences) <- repseq_nochim_md5_asv$md5
# Convert vector into a DNAStringSet object
sequences_rep_seq <- readDNAStringSet(sequences)

# You can also get this named vector from the fasta file we downloaded earlier.
sequences_fasta <- readDNAStringSet("data/results/PROJECTNAME_rep-seq.fas")

# They make the same thing.
head(sequences_rep_seq)
head(sequences_fasta)

# Finally, we blast our representative sequences against the database we created
taxonomy_blast <- predict(
  midori_coi_db,
  sequences_fasta,
  outfmt = "6 qseqid sseqid pident",
  BLAST_args = "-perc_identity 85 -max_target_seqs 1 -qcov_hsp_perc 80"
)
View(taxonomy_blast)

# Now lets combine the two taxonomy tables to see how the the two methods
# compare
taxonomy_rdp_blast <- left_join(
  taxonomy_rdp_md5,
  taxonomy_blast,
  join_by(ASV == qseqid)
)


# Export this table as a .tsv file. I name it with Project Name,
# the reference library used, and taxonomy (vs. speciesID).
write.table(
  taxonomy_md5,
  file = "data/results/PROJECTNAME_REFERENCE_taxonomy.tsv",
  quote = FALSE,
  sep = "\t",
  row.names = FALSE
)