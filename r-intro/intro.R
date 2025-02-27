# This is my script from the R intro
# Comments start with a #

# For best practice and style comments shouldn't extend past 80 characters, the vertical gray line...
#
# Don't reflow this

# Get the current working directory
getwd()

# Get help for a command
?getwd

# Create a subdirectory
dir.create("data")

# Click on the "data" folder in "Files" pane
# What's the working directory now?
getwd()

# Navigate back to your project folder in "Files" pane

# Download the data file we'll be using later via the GUI
# Open link:

# Move from Downloads to data directory

# Can you do this from R directly?

download.file(
  "https://figshare.com/ndownloader/files/14632895",
  "data/combined_tidy_vcf.csv"
)

# View a file in RStudio

#
# Section: Using functions in R, without needing to master them
#
# EXERCISE: WHAT DO THESE FUNCTIONS DO?

dir()
sessionInfo()
date()
Sys.time()
date()

# Playing with the round() function

round(3.14)

round(3.14, digits = 1)
args(round)
?round
??round
??"rounding a number"

# EXERCISE: SEARCHING FOR R FUNCTIONS
#
# Chi-Squared test
# Student t-test
# linear model

# 
# Section: R Basics
#

# Assignment operator: <-
# Shortcut is alt+- (win) or option+- (mac)

first_value <- 1
first_value
# Note that it's in the 'Environment' pane

# EXERCISE: CREATE SOME OBJECTS IN R

# Create an object that has the value of number of pairs of human chromosomes
# Create an object that has a value of your favorite gene name
# Create an object that has this URL as its value: “ftp://ftp.ensemblgenomes.org/pub/bacteria/release-39/fasta/bacteria_5_collection/escherichia_coli_b_str_rel606/”
# Create an object that has the value of the number of chromosomes in a diploid human cell

human_chromosomes <- 23
favorite_gene <- "ef1a"

# Reassigning value to an object
favorite_gene <- "pten"

# Deleting an object
rm(favorite_gene)
# favorite_gene

favorite_gene <- "pten"
# You can use the Broom in the "Environment" panel to clear all objects

# Let's quit and re-open R...
# Save workplace?

# Now let's continue to mode() which is the type of data in an object
mode(favorite_gene)

# EXERCISE: CREATE OBJECTS AND CHECK THEIR MODES

# They use single quotes here, the style guide is to use double quotes ::shrug::
chromosome_name <- 'chr02'
od_600_value <- 0.47
chr_position <- '1001701'
spock <- TRUE
# pilot <- Earhart


mode(chromosome_name)
mode(od_600_value)
mode(chr_position)
mode(spock)
# mode(pilot)

# From copilot:
# class():  the type of object (e.g., data frame, matrix, list).
# mode():   the type of data inside the object (e.g., numeric, character, logical).
# typeof(): the internal storage mode of the object (e.g., integer, double, character).

typeof(od_600_value)

# mathematical operation are pretty standard
(1 + (5 ** 0.5)) / 2

# You can use objects with these
od_600_value * 2

# Section: Vectors

# Create the SNP gene name vector
snp_genes <- c("OXTR", "ACTN3", "AR", "OPRM1")
snp_genes

# A vector can only contain one type of value
mode(snp_genes)

snp_genes <- c("OXTR", "ACTN3", "AR", "OPRM1", 1)
snp_genes

# Return to our original vector
snp_genes <- c("OXTR", "ACTN3", "AR", "OPRM1")


# length() is the number of values in a vector
length(snp_genes)

# str() gives a brief summary of the vector (same as what's in "Env." pane)
str(snp_genes)

# create some vectors
snps <- c("rs53576", "rs1815739", "rs6152", "rs1799971")
snp_chromosomes <- c("3", "11", "X", "6")
snp_positions <- c(8762685, 66560624, 67545785, 154039662)

# TODO: cover NA here, as.numeric and as.charater... also is.na()

# [] notation to specify a value # in the vector
snps[3]

# Get a range of values
snps[1:3]

# Get several non-consecutive values
snps[c(1, 3, 2)]

# Add to a vector: reassign the value to itself
snp_genes <- c(snp_genes, "CYP1A1", "APOA5")
length(snp_genes)
snp_genes

# Remove a value with a negative index number
snp_genes <- snp_genes[-6]
snp_genes

# Reassign the value to a specific value in the matrix
snp_genes[6] <- "APOA5"
snp_genes

# Section: Logical subsetting
snp_positions
snp_positions[snp_positions > 100000000]
snp_positions[snp_positions < 100000000]

# What's happening to give that result?
# A logical vector is being produced
snp_positions > 100000000
snp_positions[c(FALSE, FALSE, FALSE, TRUE)]

# %in% is a special operator you can use with vector
"APOA5" %in% snp_genes
"ef1a" %in% snp_genes
c("APOA5", "ef1a") %in% snp_genes

# Named vectors: Vectors elements can be named. These act like labels that help
# you identify and access specific elements easily.
names(snp_positions)

# We'll use the snp names of the snps vector to label snp_positions
names(snp_positions) <- snps
snp_positions
snp_positions["rs1815739"]

# Section: data frames
variants <- read.csv("data/combined_tidy_vcf.csv")
variants
tail(variants)
View(variants)
dim(variants)

# Get summary stats
summary(variants)
str(variants)

mode(variants)
class(variants)

# Use $ notation to refer to a specific column in the data frame
alt_alleles <- variants$ALT
alt_alleles

#  $ and [] notation to get subsets from a column
specific_alt_allele <- variants$ALT[23]
specific_alt_allele

alt_alleles == "A"

# Subset a data.frame (choosing rows)
alt_a <- subset(variants, ALT == "A" )

# Using or, |
alt_a_c_g_t <- subset(variants, ALT == "A" | ALT == "T" | ALT == "G" | ALT == "C")

# Using and, &
alt_ca_indel <- subset(variants, ALT == "CA" & INDEL == TRUE )

# TODO: good spot for an exercise

# Subset a data.frame, rows and columns
alt_a_pos <- subset(variants, ALT == "A", select = c(CHROM, POS))
View(alt_a_pos)

# Column names can be viewed and edited
colnames(alt_a_pos)
colnames(alt_a_pos)[1] <- "CONTIG"
colnames(alt_a_pos)

# TODO: Output using write.table() and write.csv()?

