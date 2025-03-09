# Building a custom database from BOLD or NCBI

#Install refdb: it's no longer on CRAN so install the development version instead
remotes::install_github("fkeck/refdb")
install.packages("devtools")
#https://fkeck.github.io/refdb/articles/intro_refdb.html
#don't update anything; might have to also install 'bold' and 'taxize' first to get it to work
devtools::install_github("https://github.com/boldsystems-central/BOLDconnectR")

remotes::install_github(
  "boldsystems-central/BOLDconnectR",
  upgrade = TRUE
)
dir.create("data/results", recursive = TRUE)
dir.create("ref")

library(refdb)
library(tidyverse)
library(BOLDconnectR)
library(phylotools)
# First you need to set you api key. It appears you need this to download any
# BOLD records, regardless of whether they are public or private.

# One of the few things you can do without a key is do a public record search,
# which will give you process_id, sample_id, and what sequences are available.
bah_fish_BOLD <- bold.public.search(
  project_codes = "BAHB"
)
head(bah_fish_BOLD)

# Set your api key.
bold.apikey("E6453E6C-AED7-46F0-A368-37511804C4A5")

# Once you have entered your api key, you can download any public records or
# private records that you have access to. We are going to download some SI
# public of fish from the Bahamas. We use the arguement "get_by" to determine
# which parameter you want to use to fetch, options are: "processid",
# "sampleid", "bin_uri", "dataset_codes", or "project_codes". You then use
# "identifiers" to tell the program what to search for. This can be a single
# item, a vector, a column, or a string. With a string use c("first item",
# "second item").

bah_fish_BOLD <- bold.fetch(
  get_by = "project_codes",
  identifiers = "BAHB"
)
View(bah_fish_BOLD)

# If you want fish from two projects
bah_austral_fish_BOLD <- bold.fetch(
  get_by = "project_codes",
  identifiers = c("BAHB", "AUSTR")
)

# What if we only want COI data from these fish.
bah_austral_fish_COI_BOLD <- bold.fetch(
  get_by = "project_codes",
  identifiers = c("BAHB", "AUSTR"),
  filt_marker = ("COI-5P")
)

# You can even download this and export it locally. Exported data is always
# saved as a tsv file
bah_austral_fish_COI_BOLD <- bold.fetch(
  get_by = "project_codes",
  identifiers = c("BAHB", "AUSTR"),
  filt_marker = ("COI-5P"),
  export = ("data/results/Bah_Austral_Fish_COI_BOLD.tsv")
)

# Lets add some COI sequences of the genus Apogon from NCBI
apodon_ncbi <- refdb_import_NCBI("Apogon COI")
bah_blennies_ncbi <- refdb_import_NCBI("Blenniidae COI Bahamas")
austral_blennies_ncbi <- refdb_import_NCBI("Blenniidae COI Austral")


# Lets see if we can merge these databases
fish_austral_bah_NCBI_BOLD <- refdb_merge(
  bah_austral_fish_COI_BOLD,
  apodon_ncbi,
  bah_blennies_ncbi,
  austral_blennies_ncbi
)


# reddb does not recognize the fields in the BOLD downloaded data, so we will
# have to set them ourselves.
bah_austral_fish_COI_BOLD_merge <- bah_austral_fish_COI_BOLD %>%
  mutate(source = "BOLD", marker = "COI") %>%
  refdb_set_fields(
    .,
    taxonomy = c(
      kingdom = "kingdom",
      phylum = "phylum",
      class = "class",
      order = "order",
      family = "family",
      genus = "genus",
      species = "species"
    ),
    sequence = "nuc",
    id = "processid",
    marker = "marker",
    source = "source"
  )


refdb_get_fields(bah_austral_fish_COI_BOLD_merge)

# Lets try to merge again
fish_austral_bah_BOLD_NCBI <- refdb_merge(
  bah_austral_fish_COI_BOLD_merge,
  apodon_ncbi,
  bah_blennies_ncbi,
  austral_blennies_ncbi
)

fish_austral_bah_NCBI_BOLD <- refdb_merge(
  apodon_ncbi,
  bah_austral_fish_COI_BOLD_merge,
  bah_blennies_ncbi,
  austral_blennies_ncbi
)


reflib <- fish_austral_bah_NCBI_BOLD

# Next we can clean our sequences
# Convert all missing taxonomic info to NA
reflib_na <- refdb_clean_tax_NA(reflib)

# remove extra words from txonomic names
reflib_na_extra <- refdb_clean_tax_remove_extra(reflib_na)

# Remove all gaps from sequences
reflib_na_extra_nogap <- refdb_clean_seq_remove_gaps(reflib_na_extra)

#remove side N's
reflib_na_extra_nogap_noN <- refdb_clean_seq_remove_sideN(reflib_na_extra_nogap)

# Not only does refdb clean sequences, it can filter them out too
# Lets reset so the name isn't quite so long
reflib_clean <- reflib_na_extra_nogap_noN

# First we filter out duplicate sequences. This is the first one that we see an
# obvious change
reflib_clean_nodups <- refdb_filter_seq_duplicates(reflib_clean)

# We can also filter by size. Lets look at a histogram first.
refdb_plot_seqlen_hist(reflib_clean_nodups)

# We will only keep sequences that are longer than 200 bp.
# We will also filter out the really long reads. You probably don't want to do
# this, but I am just including to demonstrate how.
reflib_clean_nodups_trim <- refdb_filter_seq_length(
  reflib_clean_nodups,
  min_len = 200,
  max_len = 1000
)
# Lets look at this size-trimmed dataset
refdb_plot_seqlen_hist(reflib_clean_nodups_trim)

# Lets examine our database in other ways

# First, lets look at counts by order (we could do any taxonomic level). We are
# first going to rename the dataset to "reflib_final" for ease of use
reflib_final <- reflib_clean_nodups_trim
reflib_final %>%
  group_by(order) %>%
  count() %>%
  ggplot(aes(fct_reorder(order, n, .desc = TRUE), n)) +
  geom_col() +
  xlab("Order") +
  ylab("Number of Records") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))

refdb_plot_tax_treemap(reflib_final)
refdb_plot_tax_tree(reflib_final)
#Export the library

refdb_export_dada2(reflib_final, "ref/fish_bah_austral_COI.fas")

refdb_export_dada2(lib_long, "/Users/Saltonstallk/Downloads/Test_lib_dada2.txt")


## Import and convert fasta or table
midori_coi <- phylotools::read.fasta("ref/midori_COI_genus_dada2.fasta")
