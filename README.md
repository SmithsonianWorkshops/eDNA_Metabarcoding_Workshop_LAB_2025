# eDNA/Metabarcoding Workshop LAB 2025

In this workshop we will learn how to analyze illumina reads from eDNA or other mixed DNA sources

* [Computer Preparation](#computer-preparation)
  * [Install and Update R and RStudio](#install-and-update-r-and-rstudio)
  * [Get Raw Reads](#get-raw-reads)
* [RStudio](#rstudio)
  * [Create a New Project](#create-a-new-project)
  * [RStudio Preparation](#rstudio-preparation)
  * [Install Cutadapt and Blast](#install-cutadapt-and-blast)
  * [Cutadapt](#cutadapt)
  * [DADA2](#dada2)
  * [Visualize Results](#visualize-results)
  * [Assign Taxonomy](#assign-taxonomy)
  * [Create a custom database](#create-a-custom-database)
  * [phyloseq](#phyloseq)

This protocol is for paired-end demultiplexed miseq sequences that have sufficient overlap to merge R1 and R2, and are going to be run on your computer, not on Hydra. It is broken up into sections, each section has an `.R` document that can be opened in RStudio (or VSCode with the [R extension](https://code.visualstudio.com/docs/languages/r)).

However, before running RStudio, you must make sure the necessary programs are installed, and the illumina demultiplexed sequences have been downloaded.

## Computer Preparation

### Install and Update R and RStudio

If you do not have R and/or RStudio installed on your computer, go to [Installing R and RStudio](r-install.md) to install either or both.

### Get Raw Reads

The raw Illumina reads that you will be analyzing are in the Teams Channel for this workshop. You have each recieved an email letting you know which dataset you will be using. Download this data into your computer's Downloads directory.

## RStudio

The rest of this workshop will be run in RStudio

### Create a New Project

* Open RStudio and create a new project.
* When you do this it will ask if you want to create it from an "Existing Directory" or a "New Directory". Choose **"New Directory"**.
  * For Mac users the default location is `/Users/username`; this is where you want to create this new project.
  * For Windows users, the default is in your documents folder. For many, this is backed up to OneDrive automatically, which may cause problems down the road with RStudio, so you want to browse to `/Users/username` and made a new project there.
* Name the project **eDNA_workshop_dataset_X**, replace `X` with the dataset nubmer that you'll be working on.
  * Making a new project from a new directory in RStudio will automatically create a project folder and a project file (.Rproject) in that folder.

### RStudio Preparation

First, we are goiong to download the entire pipeline into our project directory using the script shown below. Copy the code block below into the Console panel (usually the entire left panel, or the bottom left panel if the Source Editor is open on the top left) of RStudio and run it. This will download the pipeline unzip it, and remove the zipped file.

This is probably the only R code we will be running from the Console. We typically run all the scripts by opening each file in the Source Editor and running from there so we have a record of your analyses, including any changes made and any comments that may be needed along the way.

```{R}
pipeline <- "https://github.com/SmithsonianWorkshops/eDNA_Metabarcoding_Workshop_LAB_2025/archive/refs/heads/main.zip"
download.file(pipeline, basename(pipeline))
untar(basename(pipeline))
file.remove(basename(pipeline))
dir.create(ref)
ref <- "https://www.dropbox.com/s/uznq6hyfoa2nbeb/midori_COI_curated_genus_dada2.fasta?dl=1"
download.file(ref, ref/basename(ref))
```

Next we install and load all the R libraries needed for this pipeline. We also set up our directory structure and find, load, and copy the raw Illumina read files to the directory from which they will be analyzed. In RStudio open [1_RStudioPrep.R](RStudio_Files/1_RStudioPrep.R) by clicking on the Files tab in the lower right panel, naviagating to the list of files, and selecting the appropriate file. This will open the chosen file in the Source Editor. You can run commands from the Source Editor using the "Run" button or `control + return`

## Install Cutadapt and Blast

Next we need to install Cutadapt and BLAST. Neither are R programs, but we can install them through R. Open [2_Install_Cutadapt_BLAST.R](RStudio_Files/2_Install_Cutadapt_BLAST.R) and follow the directions. The programs will be downlaoded and installed within your project folder.

## Cutadapt

We use Cutadapt to remove primer sequences from our raw reads. This section ends with primer-trimmed sequences. Open [3_Cutadapt.R](RStudio_Files/3_Cutadapt.R) and follow the directions.

## DADA2

Here we use DADA2 to quality-filter and quality-trim reads, estimate error rates and denoise reads, merge paired reads, and remove chimeric sequences. This section ends with a sequence-table, which is a table containing columns of ASV's (Amplicon Sequence Variants), rows of samples, and cell values equal "# of reads", a feature-table (rows of ASVs and columns of samples - same as the output of Qiime2) a fasta file containing all ASVs, and a file associating ASVs with their unique md5 hash. Open [4_Data2.R](Rstudio_files/4_Dada2.R) and follow the directions.

## Visualize Results

Here we use several programs to visualize your results. We will explore our results multiple ways. Open [5_VisualizeResults.R](RStudio_Files/5_VisualizeResults.R) and follow the directions.

## Assign Taxonomy

Here we use DADA2s RDP identifier and BLAST to assign taxonomic identities to ASV's. This section requires a reference library. We will supply you with a reference library for your identifications here, but later we will also show you how to get and create your own reference database later. Open [6_TaxAssignment.R](RStudio_Files/6_TaxAssignment.R) and follow the directions.

## Create a custom database

In this section we will use the [refdb R package](https://github.com/fkeck/refdb) and other R tools to create a custom reference database. Open [7_CustomDatabases.R](RStudio_Files/7_CustomDatabases.R) and follow the directions.

## phyloseq

Phyloseq is a R library that allows for manipulation, visualization, and analysis of metabarcoding data. This section describes how to set up and load your denoised results from DADA2 into phyloseq, how to perform some preliminary analyses, ana how to visualize a few basic results. Open [8_phyloseq.R](RStudio_Files/8_phyloseq.R) and follow the directions.
