# Introduction to R and RStudio

For this workshop we'll be be using material from Data Carpentry's Intro to R and RStudio for Genomics <https://datacarpentry.github.io/genomics-r-intro/>

Approximate schedule for the day:

- AM (9am-12pm)
  - R and RStudio introductions
  - R Basics (I)
  - Break!
  - Intro to VCF files (short)
  - R Basics (II)
  - Bioconductor (short)
- LUNCH! (12pm-1pm)
- PM (1pm-4pm)
  - Intro to Tidyverse (short)
  - Data Wrangling and Analyses with Tidyverse (dplyr)
  - Break!
  - Data Visualization with ggplot2

We'll be modifying the content covered so it more closely aligns with the R methods used in the eDNA/Metabarcoding analysis that we'll be doing in the main part of the workshop.

## Introducing R and RStudio IDE

<https://datacarpentry.github.io/genomics-r-intro/00-introduction.html>

### What is R

- Why learn R?
- R vs. RStudio
- Origins of R
- Tidyverse revolution (ggplot2, dplyr, Hadley Wickham)

- Objective of this workshop
  - prep for workshop
  - Enough to be start using and exploring R and its tools... focus on concepts and tools.
  - Ask better questions

### RStudio Server

**We will not be using RStudio Server**. Instead, start up RStudio on your computer.

### Creating a new project

- On Macs, please create the new project, "dc_genomics_r" in your home folder. In Browse, go to "/Users/USERNAME". This is likely the default option.

![New project window on Mac](../images/mac-create-new-project.png)

- On Windows, click on Browse and navigate to `C:\Users\USERNAME`. The default option in Windows is you Documents folder, even though it shows a `~`.

![New project window on Windows](../images/windows-create-new-project.png)

Why? We've seen issues with saving to folders that have spaces in their names and those that are sync'd to Dropbox or OneDrive.

### Overview and customization of the RStudio layout

- Initially you'll see three panes.
  - Reveal the Sources pane with the multi-window icon in the "Console" pane.
  - Or go to File>New File>R Script ()
  - Or show the pane with View>Move Focus to Source (control+1)

![Reveal Sourced Pane](../images/show-source-pane.png)

- Save this new file as `intro.R`
  - Exact name not important but:
  - Ends in `.R` (yes, captial R), no spaces, alphanumeric &  `_` `-` only (`.` for extension).

- Difference between the "Console" and the "Terminal"
  - **"Console"** is for interacting with R.
  - **"Terminal"** is for working with your computer (same as Mac Terminal or Windows Command Prompt)

- Files pane will be used a lot in the workshop
  - Navigating
  - Reveal in the Finder/Windows explorer

### Getting to work with R: navigating directories

- Changes your directory in the Files Pane does not change your working directory.
- Stay in your project directory, don't go to `/home/dcuser/R_data`

## R Basics

### Vectors

- Coercion: <https://datacarpentry.github.io/genomics-r-intro/03-basics-factors-dataframes.html#coercing-values-in-data-frames>
  - as.character()
  - as.numeric()
- NA after Coercion

### Named vectors

- New content, this will be used in the analysis week

## R Basics continued - factors and data frames

- Use `read.csv()` to read in the snp data
- Use `$` notation to subset a column as a vector
- Use `[]` notation to subset a specific value
- Subsetting data.frames using base R will only be covered briefly.
  - subset() function
- We will NOT be covering base R plotting and factors.

## Using packages from Bioconductor

- We'll only briefly touch on this
- <https://bioconductor.org>
- Several important packages used in the eDNA analysis week are from bioconductor
  - dada2, msa, DECIPHER, rBLAST

## Data Wrangling and Analyses with Tidyverse

- <https://www.tidyverse.org>
- Concept of "tidy" data
- Improvements on how base R handles data etc.
- Suite of packages, install them all or individual ones.
  - readr: reading/writing data files
  - dplyr: subsetting, manipulating data in data.frames
  - ggplot2: data visualization
  - tidyr: manipulating 'shape' of data.frames

### group_by() and summarize() functions

- Start with group_by() then add summarize() and then summarrize(n())
  - Now show simplified tally() and count()

## Data Visualization with ggplot2

- Grammar of Graphics!
- <https://ggplot2.tidyverse.org/articles/ggplot2.html>

### Loading the dataset

- Use read_csv(), use local copy of csv
- 