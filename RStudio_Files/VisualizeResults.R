library(vegan)

# First, lets look at read counts for each sample
read.count <- rowSums(seqtab.nochim.md5)
View(read.count)

# Create a dataframe of the number of reads for each sample
read.count <- enframe(rowSums(seqtab.nochim.md5))
View(read.count)

read.count <- enframe(rowSums(seqtab.nochim.md5)) %>%
  rename(
    Sample_ID = name,
    reads = value
  )
View(read.count)
# We can plot this out in a bar plot
read.count.plot <- ggplot(read.count, aes(x = Sample_ID, y = reads)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_discrete(labels = read.count$Sample_ID, guide = guide_axis(angle = 90))
read.count.plot

# We can also look at the number of ASVs for each sample, first by creating a
# dataframe of the number of ASVs for each sample
asv.count <- enframe(apply(
  seqtab.nochim.md5,
  1,
  function(row) sum(row != 0)
)) %>%
  rename(
    Sample_ID = name,
    ASVs = value
  )
# and plotting this out in a bar plot
asv.count.plot <- ggplot(asv.count, aes(x = Sample_ID, y = ASVs)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_discrete(labels = asv.count$Sample_ID, guide = guide_axis(angle = 90))
asv.count.plot

# We can also plot number of reads for each sample versus number of ASVs for
# each sample.
# First, we need to join our asv count table with our read count table
read.count.asv.count <-  left_join(
  read.count,
  asv.count,
  by = join_by(Sample_ID)
)
# Then we can plot these two variables
read.count.asv.count.plot <- ggplot(reads.asv.count, aes(x = reads, y = ASVs)) +
  geom_point() +
  scale_x_continuous(labels = scales::comma)
read.count.asv.count.plot


# We can also rarefy the data to get the expected number of ASVs for each
# sample if they had the same number of reads as the smallest sample.
# Firest, we need to determine which sample has the least number of reads.
raremin <- min(rowSums(seqtab.nochim.md5))
# Then we can use this value and the vegan command rarefy to calculate the
# 
asv.count.rarefied <- enframe(rarefy(seqtab.nochim.md5, raremin)) %>%
  rename(
    Sample_ID = name,
    expected_ASVs = value
  )
asv.rarefied.plot <- ggplot(asv.count.rarefied, aes(x = Sample_ID, y = expected_ASVs)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_discrete(labels = asv.count.rarefied$Sample_ID, guide = guide_axis(angle=90))
asv.rarefied.plot


# We can look at some basic diversity measures by sample. We first create both
# Simpson  and Shannon-Weaver diversity indices.
simpson <- diversity(seqtab.nochim.md5, index = "simpson")
shannon <- diversity(seqtab.nochim.md5, index = "shannon")
# par allows you to put two (or more) graphs side-by-side 
par(mfrow = c(1, 2))
# Make a quick histogram of each, and put it on the same page
hist(simpson)
hist(shannon)

# We can make a dataframe of Shannon-Weaver index measures per sample
shannon.sample <- enframe(shannon) %>%
  rename(
    Sample_ID = name,
    shannon = value
  )
# And plot them  
shannon.plot <- ggplot(shannon.sample, aes(x = Sample_ID, y = shannon)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_discrete(labels = shannon.sample$Sample_ID, guide = guide_axis(angle=90))
shannon.plot

# We can do the same for the Simpson index
simpson.sample <- enframe(simpson) %>%
  rename(
    Sample_ID = name,
    simpson = value
  )
simpson.plot <- ggplot(simpson.sample, aes(x = Sample_ID, y = simpson)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_discrete(labels = simpson.sample$Sample_ID, guide = guide_axis(angle=90))
simpson.plot


# We can also look at some basic variables for all these graphs. Say we want to
# look at depth in ASV counts.
# We need metadata, so we have to import your metadata.
meta <- read.delim(
  "dataset1.tsv",
  header = TRUE,
  sep = "\t",
  colClasses = c(depth_ft = "character")
)
# However, you may have some data that looks like a continuous variable that is
# actually a discreete variable (such as filter size or depth). Check to see how
# read.delim interpreted your data
str(meta)
# If you want to change the data type of some columns, you can add the arguement
# "colClasses" to read.delim
meta <- read.delim(
  "dataset1.tsv",
  header = TRUE,
  sep = "\t",
  colClasses = c(depth_ft = "character")
)
# Your metadata may have samples that are not on this run, so you can perform
# a left_join to add the metadata only to the samples that you are analyzing.
read.count.meta <- left_join(
  read.count,
  meta,
  by = join_by(Sample_ID)
)
asv.count.meta <- left_join(
  asv.count,
  meta,
  by = join_by(Sample_ID)
)
asv.count.rarefied <- left_join(
  asv.count.rarefied,
  meta,
  by = join_by(Sample_ID)
)
View(read.count.meta)
# Lets go back to our original read.count and asv.count plots
read.count.plot
read.count.plot <- ggplot(read.count, aes(x = Sample_ID, y = reads, fill = depth_ft)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_discrete(labels = read.count$Sample_ID, guide = guide_axis(angle = 90))
read.count.plot

asv.count.plot
asv.count.plot <- ggplot(asv.count, aes(x = Sample_ID, y = ASVs, fill = depth_ft)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_discrete(labels = asv.count$Sample_ID, guide = guide_axis(angle = 90))
asv.count.plot

asv.rarefiled.plot
asv.rarefied.plot <- ggplot(asv.count.rarefied, aes(x = Sample_ID, y = expected_ASVs, fill = depth_ft)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_discrete(labels = asv.count.rarefied$Sample_ID, guide = guide_axis(angle=90))
asv.rarefied.plot

# We can also look at the plot of reads vs ASVs colored by a variable. First we
# have to add the metadata using the left_join we used earlier
read.count.asv.count.meta <-  left_join(
  read.count.asv.count,
  meta,
  by = join_by(Sample_ID)
)

read.count.asv.count.meta.plot <- ggplot(read.count.asv.count.meta, aes(x = reads, y = ASVs)) +
  geom_point(size = 4, aes(fill = depth_ft, color = depth_ft, shape = fraction)) +
  scale_x_continuous(labels = scales::comma)
read.count.asv.count.meta.plot

# Next we want to look at some rarefaction curves. vegan can give you a
# rarefaction curve on it's own, but your ability to modify it is limited
rarecurve(seqtab.nochim.md5, step = 1000)

# Instead we use the arguement "tidy = TRUE", and rarecurve gives you the
# rarefied curvews in tabular form, so you can make your own figure.
rarecurve.df <- rarecurve(
  seqtab.nochim.md5,
  step = 500,
  tidy = TRUE
) %>%
  rename(
    Sample_ID = Site,
    ASVs = Species,
    reads = Sample
  )
head(rarecurve.df)

# Lets add the metadata to this, so we can look at treatment affects
rarecurve.df.meta <- left_join(
  rarecurve.df,
  meta,
  join_by(Sample_ID)
)
head(rarecurve.df.meta)

# You can look at the different variables and see how many different values
# there are
unique(rarecurve.df.meta$Sample_ID)
unique(rarecurve.df.meta$fraction)
unique(rarecurve.df.meta$depth_ft)
unique(rarecurve.df.meta$retrieval_year)

# Make a line plot of this data, grouping by Sample_ID so each sample will form
# a separate line.
rarecurve.df.meta.plot <- ggplot(rarecurve.df.meta) +
  geom_line(
    aes(
      x = reads,
      y = ASVs,
      color = fraction,
      linetype = depth_ft,
      group = Sample_ID
    ),
    linewidth = 0.75
  ) +
  scale_linetype_manual(values = c("solid", "dashed", "dotted", "dotdash")) 
rarecurve.df.meta.plot 

# Add an upper limit to the x-axis (reads) to see the expected number of ASVs
# found in each sample with read depth equal to the sample with the least
# number of reads (which should equal the values found in asv.count.rarefied).
rarecurve.df.meta.plot <- ggplot(rarecurve.df.meta) +
  geom_line(
    aes(
      x = reads,
      y = ASVs,
      color = fraction,
      linetype = depth_ft,
      group = Sample_ID
    ),
    linewidth = 0.75
  ) +
  scale_linetype_manual(values = c("solid", "dashed", "dotted", "dotdash")) +
  scale_x_continuous(limits = c(0, raremin))
rarecurve.df.meta.plot


# Now lets move to some ways to look at how similar your samples are usingj
# ordination techniques.
# We are going to use NMDS (Non-Metric Multidimensional Scaling).
# First we need to run a NMDS analysis on our sequence-table.
nmds <- metaMDS(seqtab.nochim.md5, k = 2, distance = "bray")
# Look at your stress value, it is important in telling you the "goodness of
# fit" of your ordination. You want this value below 0.2.

# You can use vegan to plot this, but like the rarefaction plot, it is limited
# in what you can do, so I convert this to nmds scores that are plotable. A lot
# of the plots in this section was greatly helped by these websites:
# https://jkzorz.github.io/ and 
# https://eddatascienceees.github.io/tutorial-rayrr13/
nmds.scores <- as_tibble(scores(nmds)$sites, rownames = "Sample_ID")
# Add your metadata to this new table
nmds.scores.meta <- left_join(
  nmds.scores,
  meta,
  join_by(Sample_ID)
)
head(nmds.scores.meta)

# Plot this table, differentiating two of your variables of interest by color
# and symbol shape.
nmds.scores.meta.plot <- ggplot(nmds.scores.meta, aes(x = NMDS1, y = NMDS2)) +
  geom_point(size = 4, aes(fill = depth_ft, color = depth_ft, shape = fraction))
nmds.scores.meta.plot
# I want 
# define hidden vegan function that finds coordinates for drawing a covariance ellipse
veganCovEllipse<-function (cov, center = c(0, 0), scale = 1, npoints = 100)
{
  theta <- (0:npoints) * 2 * pi/npoints
  Circle <- cbind(cos(theta), sin(theta))
  t(center + scale * t(Circle %*% chol(cov)))
}


# We can do some very basic statistics to see if these factors are significantly
# different.
# Well use a ANOSIM (Analysis of Similarities) test for two different variables.
# First, looking at depth
anosim.depth <- anosim(x = seqtab.nochim.md5, grouping = reads.meta$depth_ft, permutations = 9999, distance = "bray")
anosim.depth
# Then, looking at fraction
anosim.fraction <- anosim(x = seqtab.nochim.md5, grouping = reads.meta$fraction, permutations = 9999, distance = "bray")
anosim.fraction