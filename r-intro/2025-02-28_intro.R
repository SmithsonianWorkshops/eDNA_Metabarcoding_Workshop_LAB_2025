# This is script I created in my intro to R session.

# Working with files and folders in R
getwd()

# Create a data directory
dir.create("data")

# What's the working dir now?
getwd()

# You can download directly through R
download.file(
  "https://figshare.com/ndownloader/files/14632895",
  "data/combined_tidy_vcf.csv"
)

# Creating objects

first_value <- 1
first_value

favorite_gene <- "ef1a"
favorite_gene

favorite_gene <- "pten"
rm(favorite_gene)
favorite_gene

# We want to use favorite_gene
favorite_gene <- "pten"

mode(favorite_gene)
mode(first_value)

first_value + 1

favorite_gene + 1

# You can't add to character
favorite_number <- "8"
favorite_number + 1

# Exercise looking at objects:
chromosome_name <- "chr02"
od_600_value <- 0.47
chr_position <- "1001701"
spock <- TRUE
pilot <- "Earhart"
star_trek_character <- spock
spock <- FALSE
# What's their mode()?

mode(spock)
# Logicals: TRUE FALSE
mode(od_600_value)

# Vectors
snp_genes <- c("OXTR", "ACTN3", "AR", "OPRM1")
snp_genes

length(snp_genes)
str(snp_genes)

snp_genes <- c(snp_genes, "ef1a")
# not this
snp_genes <- snp_genes + "ef1a"

# Add a number to this vector
snp_genes <- c(snp_genes, 8)
snp_genes

# A vector can only contain one type of value
some_numbers <- c(1, 2, 99)
some_numbers <- c(some_numbers, 223)
some_numbers <- c(some_numbers, "nine")

some_numbers
# Square brackets to refer to a value in an vector
some_numbers[5]
some_numbers[1:3]
some_numbers[-5]
some_numbers <- some_numbers[-5]
some_numbers <- as.numeric(some_numbers)

# What happens if you force a character into a number?
some_numbers <- c(some_numbers, "nine")
some_numbers <- as.numeric(some_numbers)
some_numbers

some_numbers <- c(some_numbers, "nine")
some_numbers == "nine"

# which() to find position/index in a vector
which(some_numbers == "nine")

some_numbers[some_numbers != "nine"]
# Logical test part: gives vector
some_numbers != "nine"
some_numbers[c(TRUE, TRUE, TRUE, TRUE, NA, FALSE)]
# No single right way to do things!

# Renaming an object
pilots <- pilot
rm(pilot)

# Reading in our csv
variants <- read.csv("data/combined_tidy_vcf.csv")

# This data frame (data.frame)
# In examples data frame objects are created withe name "df"

# Get a column as a vector
alt_alleles <- variants$ALT
alt_alleles

# Using bracket noation
# specific row, column
variants[2, 3]
# Full column (don't use)
variants[2]
# Full row
variants[2, ]
# Full column (use this one)
variants[, 2]

# If you know the name not the number you can use that
variants[, "ALT"]

variants$ALT == "A"
# The "," after the logical statement keeps ALL the columns
variants_alt_a <- variants[variants$ALT == "A", ]

# this does have the first row even that it's named "7"
variants_alt_a[1, ]

row.names(variants_alt_a[1, ])

# You can rename a row
# this didn't work :(
row.names(variants_alt_a[1, ]) <- "paul"
row.names(variants_alt_a[1, ])

# All row names
row.names(variants_alt_a)

# First row name
row.names(variants_alt_a)[1]

# Rename first row 
row.names(variants_alt_a)[1] <- "paul"

# Write csv
write.csv(variants_alt_a, file = "data/variants_alt_a.csv")

# Skip row names
write.csv(
  variants_alt_a,
  file = "data/variants_alt_a.csv",
  row.names = FALSE,
  col.names = FALSE
)

# R is forgiving with extra spaces and new lines, but this isn't "good form"


# Afternoon: Tidyverse section
install.packages("readr")
install.packages("dplyr")
install.packages("ggplot2")

# Load the packages with library()
library(readr)
library(dplyr)
library(ggplot2)

# Read in csv with read_csv()
variants <- read_csv("data/combined_tidy_vcf.csv")
variants

# Looking at the data table
View(variants)
glimpse(variants)
head(variants)

# dplyr functions for selecting rows and columns

# select() choose columns
select(variants, c(CHROM, POS, ALT))
limited_columns <- select(variants, c(CHROM, POS, ALT))

# columns to keep
cols_to_keep <- c("CHROM", "POS", "ALT")
rm(limited_columns)
limited_columns <- select(variants, cols_to_keep)

select(variants, starts_with("B"))

# choosing which rows to keep filter()
filter(variants, ALT == "A")

# More than one factor
# Or operator is |
filter(variants, ALT == "A" | ALT == "C" )

# Add to this to filter all rows with a single A, C, G, or T in ALT
filter(variants, ALT == "A" | ALT == "C"| ALT == "G"| ALT == "T")

# How many rows are returned?
# 707

# REF is A and ALT is T
# and operator is &
filter(variants, REF == "A" & ALT == "T")

# Using parentheses and logical columns in filter
filter(variants, (REF == "A" & ALT == "T") | INDEL == TRUE )
filter(variants, (REF == "A" & ALT == "T") | INDEL )

# For INDEL is FALSE
# Or negating the logical with ! (not)
filter(variants, (REF == "A" & ALT == "T") | INDEL == FALSE )
filter(variants, (REF == "A" & ALT == "T") | !INDEL )

# Combining dplyr operations
# Pipes %>% ctrl-shift-m

filter(variants, REF == "A" & ALT == "T") %>%
  select(c(CHROM, POS, ALT))

# Exercise: Starting with the variants data frame, use pipes to subset the data
# to include only observations from SRR2584863 sample, where the filtered depth
# (DP) is at least 10. Showing only rows of columns REF, ALT, and POS

filter(variants, sample_id == "SRR2584863" & (DP == 10 | DP > 10)) %>%  
  select(c(REF, POS, ALT))

# Don't quote 10, otherwise it's doing some unexpected comparison.
filter(variants, sample_id == "SRR2584863" & (DP == "10" | DP > "10")) %>%  
  select(c(REF, POS, ALT))

variants %>%
  select(c(REF, POS, ALT)) %>% 
  filter(sample_id == "SRR2584863" & (DP == 10 | DP > 10))

# >= means greater than or equal to

sample_63 <- variants %>%
  select(c(REF, POS, ALT, sample_id, DP)) %>% 
  filter(sample_id == "SRR2584863" & (DP == 10 | DP > 10))

# mutate() add new columns using existing data
variants %>% 
  mutate(POS_1000 = POS / 1000) %>% 
  View()

# Asking copilot for help
# In R with tidyverse I have this data table:
# > str(variants)
# spc_tbl_ [801 × 29] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
# $ sample_id    : chr [1:801] "SRR2584863" "SRR2584863" "SRR2584863" "SRR2584863" ...
# $ CHROM        : chr [1:801] "CP000819.1" "CP000819.1" "CP000819.1" "CP000819.1" ...
# $ POS          : num [1:801] 9972 263235 281923 433359 473901 ...
# $ ID           : logi [1:801] NA NA NA NA NA NA ...
# $ REF          : chr [1:801] "T" "G" "G" "CTTTTTTT" ...
# $ ALT          : chr [1:801] "G" "T" "T" "CTTTTTTTT" ...
# $ QUAL         : num [1:801] 91 85 217 64 228 210 178 225 56 167 ...
# $ FILTER       : logi [1:801] NA NA NA NA NA NA ...
# $ INDEL        : logi [1:801] FALSE FALSE FALSE TRUE TRUE FALSE ...
# $ IDV          : num [1:801] NA NA NA 12 9 NA NA NA 2 7 ...
# $ IMF          : num [1:801] NA NA NA 1 0.9 ...
# $ DP           : num [1:801] 4 6 10 12 10 10 8 11 3 7 ...
# $ VDB          : num [1:801] 0.0257 0.0961 0.7741 0.4777 0.6595 ...
# $ RPB          : num [1:801] NA 1 NA NA NA NA NA NA NA NA ...
# $ MQB          : num [1:801] NA 1 NA NA NA NA NA NA NA NA ...
# $ BQB          : num [1:801] NA 1 NA NA NA NA NA NA NA NA ...
# $ MQSB         : num [1:801] NA NA 0.975 1 0.916 ...
# $ SGB          : num [1:801] -0.556 -0.591 -0.662 -0.676 -0.662 ...
# $ MQ0F         : num [1:801] 0 0.167 0 0 0 ...
# $ ICB          : logi [1:801] NA NA NA NA NA NA ...
# $ HOB          : logi [1:801] NA NA NA NA NA NA ...
# $ AC           : num [1:801] 1 1 1 1 1 1 1 1 1 1 ...
# $ AN           : num [1:801] 1 1 1 1 1 1 1 1 1 1 ...
# $ DP4          : chr [1:801] "0,0,0,4" "0,1,0,5" "0,0,4,5" "0,1,3,8" ...
# $ MQ           : num [1:801] 60 33 60 60 60 60 60 60 60 60 ...
# $ Indiv        : chr [1:801] "/home/dcuser/dc_workshop/results/bam/SRR2584863.aligned.sorted.bam" "/home/dcuser/dc_workshop/results/bam/SRR2584863.aligned.sorted.bam" "/home/dcuser/dc_workshop/results/bam/SRR2584863.aligned.sorted.bam" "/home/dcuser/dc_workshop/results/bam/SRR2584863.aligned.sorted.bam" ...
# $ gt_PL        : num [1:801] 1210 1120 2470 910 2550 ...
# $ gt_GT        : num [1:801] 1 1 1 1 1 1 1 1 1 1 ...
# $ gt_GT_alleles: chr [1:801] "G" "T" "T" "CTTTTTTTT" ...
# 
# 
# How can I get the mean DP for each sample_id and the count of samples?
result <- variants %>%
  group_by(sample_id) %>%
  summarise(mean_DP = mean(DP, na.rm = TRUE), count = n())

# Plotting with ggplot2

ggplot(variants)

# Add aesthetics
ggplot(variants, aes(x = POS, y = DP))

# Add geom
ggplot(variants, aes(x = POS, y = DP)) +
  geom_point()

geom_point()

# Switch to geom_line
ggplot(variants, aes(x = POS, y = DP)) +
  geom_line()

# modifying the points
ggplot(variants, aes(x = POS, y = DP)) +
  geom_point(alpha = 0.5)

# Changing color by sample_id
ggplot(variants, aes(x = POS, y = DP, color = sample_id )) +
  geom_point(alpha = 0.5)

# Assign scatter plot to an object
variants_scatter <- ggplot(variants, aes(x = POS, y = DP, color = sample_id)) +
  geom_point(alpha = 0.5)

# Add labels to our existing object
variants_scatter + labs(title = "Depth over the chromosome",
                        x = "Position on chrmosome",
                        y = "Sequencing depth")

# Add a new theme
variants_scatter +
  labs(title = "Depth over the chromosome",
       x = "Position on chrmosome",
       y = "Sequencing depth") +
  theme_bw()

# save last plot as a pdf
ggsave("depth_coverage.pdf",
       width = 6,
       height = 4)

# save a object as a png
ggsave("scatter.png",
       plot = variants_scatter,
       width = 6,
       height = 4,
       dpi = 300)

# ?? to search help
??theme

# Barplot with geom_bar()
ggplot(variants, aes(x = INDEL, fill = sample_id)) +
  geom_bar()


# facet by sample_id: three bar plots
ggplot(variants, aes(x = INDEL, fill = sample_id)) +
  geom_bar() +
  facet_grid(sample_id ~ ., scales = "free")

# Density curve
ggplot(variants, aes(x = DP)) +
  geom_density()
