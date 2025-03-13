# Lulu #########################################################################

# Lulu filters ASVs or OTUs to remove sequences that are likely to be errors.
# This script was lightly edited from that written by Sarah Tweedt
# tweedts@si.edu
library(lulu)

## Make Lulu matchlist =========================================================
# Lulu needs a matchlist, which is basically all the ASVs blasted against
# itself.

# First create a directory to hold the blast database
dir.create("ref/repseq_db")

# Next, make a blast-formatted reference database from your ASVs. Here we are
# using our representative sequences fasta that we exported earlier.
makeblastdb(
  "data/results/PROJECTNAME_rep-seq.fas",
  db_name = "ref/repseq_db/repseq_db",
  dbtype = "nucl"
)
list.files("ref/repseq_db/")

# We convert this into a blast database object which can be used to blast
# unknown sequences. The input is the named database we created in makeblastdb
refseqdb <- blast(db = "ref/repseq_db/repseq_db")

# Next, we make a DNAStringSet object from our representative sequences.
# If we've finished the taxonomy section, we should already have this. We will
# use this object as our sequences to blast against the database we just made.
sequences_dna <- DNAStringSet(setNames(
  repseq_nochim_md5_asv$ASV,
  repseq_nochim_md5_asv$md5
))

# Here we blast the DNAStringSet representative sequences against the
# representative sequence blast database. "outfmt" determines the blast output.
# "-perc_identity 85" means it keeps any sequence that shares an 85% or more
# similarity to the queried sequence. "-qcov_hsp_per 80" means that the coverage
# must be equal or greather than 80%. This output is the Lulu matchlist, which
# we will use to run Lulu
lulu_blast <- predict(
  refseqdb,
  sequences_dna,
  outfmt = "6 qseqid sseqid pident",
  BLAST_args = "-perc_identity 85 -qcov_hsp_perc 80"
)

# However, this output gives us a lot of extra columns that are not wanted.
# Lulu requires just three columns, qseqid (queried sequence), sseqid (resultant
# sequence), and pident (% identity or similarity).
lulu_matchlist <- lulu_blast %>%
  select(qseqid, sseqid, pident)


## Run Lulu Analysis ===========================================================
# We need our feature-table, but need to have ASV as rownames instead of a
# named column (columns can only be counts).
seqtab_nochim_transpose_md5_lulu <- seqtab_nochim_transpose_md5 %>%
  column_to_rownames(var = "ASV")

# Curate the feature table using lulu. This gives a curated table and various
# information and statistics in an object list.
curated_result <- lulu(
  seqtab_nochim_transpose_md5_lulu,
  lulu_matchlist,
  minimum_match = 84,
  minimum_relative_cooccurence = 0.95,
  minimum_ratio_type = "min",
  minimum_ratio = 1
)


# Get the feature table out of this object.
feattab_lulu <- curated_result$curated_table
View(feattab_lulu)
# Get the representative sequences from the feature table and add md5 hash
# (which) we have to make anew.
repseq_lulu <- feattab_lulu$ASV

repseq_lulu_md5 <- c()
for (i in seq_along(repseq_lulu)) {
  repseq_lulu_md5[i] <- digest(
    repseq_lulu[i],
    serialize = FALSE,
    algo = "md5"
  )
}

# How long did this take to run? We can check that:

print(curated_asv$runtime)

# Check how many ASVs/OTUs lulu has counted as "valid"

valids <- curated_asv$curated_count
print(valids)

# Check how many ASVs/OTUs lulu regarded as errors and discarded:

errors <- curated_asv$discarded_count
print(errors)

# Of course, the number of valid ASVs plus error ASVs should equal the total
#  number of ASVs you started with:

total <- sum(valids, errors)
print(total)


# So you can do some simple math to figure out proportion of ASVs lulu has
# marked as erroneous and/or valid:

prop_error <- errors / total
print(prop_error)

prop_valid <- valids / total
print(prop_valid)

save(
  refseqdb,
  lulu_blast,
  lulu_matchlist,
  seqtab_nochim_transpose_md5_lulu,
  curated_asv,
  feattab_lulu,
  file = "data/working/lulu.RData"
)
