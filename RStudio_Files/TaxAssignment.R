# 8 ASSIGN TAXONOMY ############################################################

## Load Libraries = ============================================================
# Load all R packages you may need, if necessary

library(dada2)
library(digest)
library(rblast)
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
#ACCTAGAAAGTCGTAGATCGAAGTTGAAGCATCGCCCGATGATCGTCTGAAGCTGTAGCATGAGTCGATTTTCACATTCAGGGATACCATAGGATAC
#>Level1;Level2;Level3;Level4;Level5;
#CGCTAGAAAGTCGTAGAAGGCTCGGAGGTTTGAAGCATCGCCCGATGGGATCTCGTTGCTGTAGCATGAGTACGGACATTCAGGGATCATAGGATAC"
#>Level1;Level2;;Level4;Level5;Level6
#CGCTAGAAAGTCGTAGAAGGCTCGGAGGTTTGAAGCATCGCCCGATGGGATCTCGTTGCTGTAGCATGAGTACGGACATTCAGGGATCATAGGATAC"

# taxLevels defines what taxonomic rank each of the levels shown in the above
# example represents.

taxonomy <- assignTaxonomy(
  seqtab.nochim,
  "/Users/USERNAME/Dropbox (Smithsonian)/Metabarcoding/Reference_Libraries/REFERENCE.fasta",
  taxLevels = c("Kingdom", "Phylum", "Class", "Order", "Family","Subfamily", "Genus", "species"),
  tryRC = FALSE,
  minBoot = 50,
  outputBootstraps = TRUE,
  multithread = TRUE,
  verbose = TRUE
)

## Examine and Manipulate Taxonomy =============================================
# Look at the taxonomic assignments
View(taxonomy$tax)
View(taxonomy$boot)

# You can check to see all the uniqe values exist in each column
unique(taxonomy$tax[,"Phylum"])
unique(taxonomy$tax[,"Class"])
unique(taxonomy$tax[,"Order"])
unique(taxonomy$tax[,"Family"])

### Combine taxonomy and bootstrap tables --------------------------------------
# You can combine the $tax and $boot table, to see simultaneously the taxonomic
# assignment and the bootstrap support for that assignment.

# Convert taxonomy and bootstrap tables into tibbles (with "ASV" as column 1)
taxonomy.tax.tb <- as_tibble(
  taxonomy$tax, 
  rownames = "ASV"
) 
dim(taxonomy.tax.tb)

taxonomy.boot.tb <- as_tibble(
  taxonomy$boot,
  rownames = "ASV"
) 
dim (taxonomy.boot.tb)

# Join the two tables using an inner-join with dbplyr (it shouldn't matter here
# what kind of join you use since the two tables should have the exact same
# number of rows and row headings (actually, now column 1)). I amend bootstrap
# column names with "_boot" (e.g. the bootstrap column for genus would be
# "Genus_boot")
taxonomy.tb <- inner_join(
  taxonomy.tax.tb,
  taxonomy.boot.tb,
  by = "ASV",
  suffix = c("","_boot")
)
dim(taxonomy.tb)
View(taxonomy.tb)

# Add md5 hash from earlier. The order of ASV's is the same as the sequence-
# table, so there shouldn't be any problem, but you can always redo the md5
# hash conversion here.
taxonomy.tb.md5 <- cbind(
  taxonomy.tb,
  feature = repseq.md5
)
View(taxonomy.tb.md5)

# Rearrange columns so that the md5 hash comes first, then the ASV, then each
# classfication level followed by it's respective bootstrap column.
taxonomy.tb.md5 <- taxonomy.tb.md5[ , c(16,1,2,9,3,10,4,11,5,12,6,13,7,14,8,15)]
View(taxonomy.tb.md5)

# Export this table as a .tsv file. I name it with Project Name,
# the reference library used, and taxonomy (vs. speciesID).
write.table(
  taxonomy.tb.md5, 
  file="data/results/PROJECTNAME_REFERENCE_taxonomy.tsv",
  quote = FALSE,
  sep="\t",
  row.names = FALSE
)

## Assign Taxonomy With BLAST+ =================================================

# We can also assign taxonomy using BLAST. Here we will use the program rBLAST
# to identify our ASVs.
# rBLAST allows you to connect directly to the NCBI server, or use a locally
# saved refernce database (in BLAST format)
# One of the reasons I'm using rBLAST is that it has a command to make a
# BLAST-formatted database from a fasta file. 

# 
