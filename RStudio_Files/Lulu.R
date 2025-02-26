dir.create("ref/rep_seq")
# Sarah code
makeblastdb \
-in ../data/results/EXAMPLE_rep-seqs-dada2.fasta \
-parse_seqids \
-dbtype nucl \
-out ../data/results/lulu/matchlist/EXAMPLE_matchlist

# Tripp Code
makeblastdb(
  "data/results/PROJECTNAME_rep-seq.fas",
  db_name = "ref/rep_seqs/matchlist",
  dbtype = "nucl"
)

# Sarah Code
blastn \
-task blastn \
-db ../data/results/lulu/matchlist/EXAMPLE_matchlist \
-outfmt '6 qseqid sseqid pident' \
-out ../data/results/lulu/EXAMPLE_matchlist.txt \
-qcov_hsp_perc 80 \
-perc_identity 85 \
-query ../data/results/EXAMPLE_rep-seqs-dada2.fasta
# Tripp Code
matchlist <- blast(db = "ref/rep_seqs/matchlist")


lulu_blast <- predict(
  matchlist,
  sequences_fasta,
  outfmt = "6 qseqid sseqid pident",
  BLAST_args = "-perc_identity 85 -qcov_hsp_perc 80"
)