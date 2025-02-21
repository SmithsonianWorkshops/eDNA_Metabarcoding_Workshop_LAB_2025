library(vegan)
simpson <- diversity(seqtab.nochim.md5, index = "simpson")
shannon <- diversity(seqtab.nochim.md5, index = "shannon")
# par allows you to put two (or more) graphs side-by-side 
par(mfrow = c(1, 2))
hist(simpson)
hist(shannon)


rarecurve(seqtab.nochim.md5, col = "blue")



reads <- rowSums(seqtab.nochim.md5)
raremin <- min(rowSums(seqtab.nochim.md5))
sRare <- rarefy(seqtab.nochim.md5, raremin)
View(sRare)

dim(seqtab.nochim.md5)
# I want to look at read distributions among the samples
reads.rows <- rowSums(seqtab.nochim.md5)
View(reads.rows)
reads.rows.df <- data.frame(rowSums(seqtab.nochim.md5)) %>%
  cbind(rownames(.), data.frame(., row.names=NULL)) %>%
reads.rows.df <- enframe(rowSums(seqtab.nochim.md5))

col <- c("Sample_ID","reads")
colnames(reads.rows.df) <- col

View(reads.rows.df)

drop.meta <- read.delim(
  "DROP_ARMS_metadata_2015_2019.tsv",
  header = TRUE,
  sep = "\t",
  colClasses = c(depth_ft = "character")
)

reads.rows.meta <- left_join(
  reads.rows.df,
  drop.meta,
  by = join_by(Sample_ID)
)

ggplot(reads.rows.df,
       aes(x = rownames(reads.rows.df), y = reads)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_discrete(labels = reads.rows.df$Sample_ID, guide = guide_axis(angle=90))

reads.minimum <- min(rowSums(seqtab.nochim.md5))





rarecurve.df <- rarecurve(
  seqtab.nochim.md5,
  samples = reads.minimum,
  step = 500,
  tidy = TRUE
)
head(rarecurve.df)

rarecurve.df.meta <- left_join(
  rarecurve.df,
  drop.meta,
  join_by(Site == Sample_ID)
)
head(rarecurve.df.meta)

unique(rarecurve.df.meta$Site)
unique(rarecurve.df.meta$fraction)
unique(rarecurve.df.meta$depth_ft)
unique(rarecurve.df.meta$retrieval_year)

rarecurve.df.meta.plot <- ggplot(rarecurve.df.meta) +
  geom_line(
    aes(
      x = Sample,
      y = Species,
      color = fraction,
      linetype = depth_ft
    ),
    linewidth = 0.75
  ) +
  scale_linetype_manual(values = c("solid", "dashed", "dotted", "dotdash"))
rarecurve.df.meta.plot
