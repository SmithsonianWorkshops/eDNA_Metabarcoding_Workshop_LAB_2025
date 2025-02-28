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
# Create an object (favorite_gene) that has a value of your favorite gene name

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

# Section: Creating and subsetting vectors

# create some vectors
snps <- c("rs53576", "rs1815739", "rs6152", "rs1799971")
snp_chromosomes <- c("3", "11", "X", "6")
snp_positions <- c(8762685, 66560624, 67545785, 154039662)

# Coercian: from https://datacarpentry.github.io/genomics-r-intro/03-basics-factors-dataframes.html#coercing-values-in-data-frames
# Coercian is where we force R to convert from one data type to another.
# NA is a special value used to represent missing or undefined data.

# As numeric
snp_chromosomes
# This gives a warning
snp_chromosomes_num <- as.numeric(snp_chromosomes)
snp_chromosomes_num

# As character
snp_positions
round(snp_positions / 1000000)
snp_positions_char <- as.character(snp_positions)
snp_positions_char
# This will give an error
round(snp_positions_char / 1000000)

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

# EXCERISE: Using indexing, create a new vector named combined that contains:
# 
# The the 1st value in snp_genes
# The 1st value in snps
# The 1st value in snp_chromosomes
# The 1st value in snp_positions
# 
# What type of data is combined?

# EXERCISE: EXAMINING AND SUBSETTING VECTORS
# 
# Answer the following questions to test your knowledge of vectors
# 
# Which of the following are true of vectors in R?
#   A) All vectors have a mode or a length
# B) All vectors have a mode and a length
# C) Vectors may have different lengths
# D) Items within a vector may be of different modes
# E) You can use the c() to add one or more items to an existing vector
# F) You can use the c() to add a vector to an existing vecto

# Section: Logical subsetting
snp_positions
snp_positions[snp_positions > 100000000]
snp_positions[snp_positions < 100000000]

# What's happening to give that result?
# A logical vector is being produced
snp_positions > 100000000
snp_positions[c(FALSE, FALSE, FALSE, TRUE)]

# Operator   Description
# ----------------------
# <          less than
# <=         less than or equal to
# >          greater than
# >=         greater than or equal to
# ==         exactly equal to
# !=         not equal to
# !x         not x
# a | b      a or b
# a & b      a and b

# EXERCISE: Use logical subsetting on snp_positions to create a logical vector
# of values that are larger than 60000000, and less than 100000000

# Note: dplyr, part of tidyverse, has a between() function, but not base R

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

# There are a suite of is.… logical functions: is.na(), is.logical(), is.character(), is.numeric(), y mas!
is.na(snp_chromosomes_num)

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

# [row, column]: notation for data from data frame
# [, column] or [column]: full column
# [row,]: full row

# Examples
variants[801, 29]
variants[2, ]
variants[1:4, 1]

# Use $ notation to refer to a specific column in the data frame
alt_alleles <- variants$ALT
alt_alleles

#  $ and [] notation to get subsets from a column
specific_alt_allele <- variants$ALT[23]
specific_alt_allele

alt_alleles == "A"

# Subset a data.frame (choosing rows)
alt_a <- variants[variants$ALT == "A",]

# All rows where the ALT is A, C, G, or T.
alt_a_c_g_t <- variants[variants$ALT %in% c("A", "C", "G", "T"), ]

# Column names can be viewed and edited
colnames(alt_a_pos)
colnames(alt_a_pos)[1] <- "CONTIG"
colnames(alt_a_pos)

# Section: Data Wrangling and Analyses with Tidyverse

# This is our first time installing packages :)
install.packages("dplyr") ## installs dplyr package
install.packages("tidyr") ## installs tidyr package
install.packages("ggplot2") ## installs ggplot2 package
install.packages("readr") ## install readr package

# And loading them.
# The warning messages are fine... masked functions
# ...this needs to be redone every time you restart R, even if the objects
# are loaded from an .RData file.
library("dplyr")          ## loads in dplyr package to use
library("tidyr")          ## loads in tidyr package to use
library("ggplot2")          ## loads in ggplot2 package to use
library("readr")          ## load in readr package to use

# Let's clear the objects in our environment. Use the Broom in Environment or:
rm(list=ls())

variants <- read_csv("data/combined_tidy_vcf.csv")
variants
# Note "tibble"

# Viewing variants
head(variants)
tail(variants)
glimpse(variants)
str(variants)

# select() choose columns
select(variants, sample_id, REF, ALT, DP)
select(variants, -CHROM)
select(variants, ends_with("B"))

# EXERCISE HERE?

# filter() to select rows
filter(variants, sample_id == "SRR2584863")

# rows for which the reference genome has T or G
filter(variants, REF %in% c("T", "G"))
filter(variants, INDEL)
filter(variants, !is.na(IDV))
filter(variants, QUAL >= 100)
filter(variants, sample_id == "SRR2584863", QUAL >= 100)
filter(variants, sample_id == "SRR2584863", (MQ >= 50 | QUAL >= 100))

# EXERCISE HERE?

# Pipes!!
# Output from one function is the input of the next one
# So much cleaner than nested functions
# %>% ctrl+shift+m
# m for Magritte https://www.google.com/search?q=magritte+tidyverse

variants %>%
  filter(sample_id == "SRR2584863") %>%
  select(REF, ALT, DP)

# You can also add in %>% View()
SRR2584863_variants <- variants %>%
  filter(sample_id == "SRR2584863") %>%
  select(REF, ALT, DP)

SRR2584863_variants %>% slice(1:6)

# EXERCISE: PIPE AND FILTER

# Mutate: add new columns based on existing columns
variants %>% 
  mutate(POLPROB = 1- (10 ^ -(QUAL / 10))) %>% 
  View()

# EXERCISE: TBD

# group_by() and summarize()

variants %>%
  group_by(sample_id)

variants %>%
  group_by(sample_id) %>% 
  summarize()

variants %>%
  group_by(sample_id) %>% 
  summarize(n())

variants %>%
  group_by(sample_id) %>% 
  summarize(count = n())

variants %>%
  group_by(sample_id) %>% 
  tally()

variants %>%
  count(sample_id)

# TODO: Group by two columns
variants %>%
  group_by(sample_id, CHROM) %>%
  summarize(mean_DP = mean(DP))

# EXERCISE: How many mutations are INDELs?

# Other summary stats using summarize()
variants %>%
  group_by(sample_id) %>%
  summarize(
    mean_DP = mean(DP),
    median_DP = median(DP),
    min_DP = min(DP),
    max_DP = max(DP))

# Reshaping data frames
# group_by() and summarize() has the columns as the summary values, how can
# you "rotate" the table so the rows the summary values? ...pivot_wider()

variants %>%
  group_by(sample_id, CHROM) %>%
  summarize(mean_DP = mean(DP))

variants %>%
  group_by(sample_id, CHROM) %>%
  summarize(mean_DP = mean(DP)) %>% 
  pivot_wider(names_from = sample_id, values_from = mean_DP)

variants %>%
  group_by(sample_id, INDEL) %>%
  summarize(mean_DP = mean(DP)) %>% 
  pivot_wider(names_from = sample_id, values_from = mean_DP)


# Section: Data Visualization with ggplot2
# working iteratively...

# Start with the data (data frame to plot)
ggplot(variants)

# Add the mapping (columns to plot)
ggplot(variants, aes(x = POS, y = DP))

# Add the geoms (graphical representations)
# Introducing how ggplot uses the + operator
ggplot(variants, aes(x = POS, y = DP)) +
  geom_point()

coverage_plot <- ggplot(variants, aes(x = POS, y = DP))
coverage_plot + geom_point()

ggplot(data = variants, aes(x = POS, y = DP)) +
  geom_point(alpha = 0.5)

ggplot(data = variants, aes(x = POS, y = DP)) +
  geom_point(alpha = 0.5, color = "blue")

ggplot(data = variants, aes(x = POS, y = DP, color = sample_id)) +
  geom_point(alpha = 0.5)

ggplot(data = variants, aes(x = POS, y = DP, color = sample_id)) +
  geom_point(alpha = 0.5) +
  labs(x = "Base Pair Position",
       y = "Read Depth (DP)")

ggplot(data = variants, aes(x = POS, y = DP, color = sample_id)) +
  geom_point(alpha = 0.5) +
  labs(x = "Base Pair Position",
       y = "Read Depth (DP)",
       title = "Read Depth vs. Position")

ggsave ("depth.pdf", width = 6, height = 4)

# EXERCISE
# Use what you just learned to create a scatter plot of mapping quality (MQ)
# over position (POS) with the samples showing in different colors. Make sure to
# give your plot relevant axis labels.

# Faceting
# facet_grid(~ sample_id)
# facet_grid(sample_id ~ .)

# Theme
# theme_bw() +
#  theme(panel.grid = element_blank())

# Barplot
ggplot(data = variants, aes(x = INDEL, fill = sample_id)) +
  geom_bar() +
  facet_grid(sample_id ~ .)

# Density
ggplot(data = variants, aes(x = DP)) +
  geom_density()

# Other tidyverse topics
# dplyr: Joins
# readr and base R: outputting data