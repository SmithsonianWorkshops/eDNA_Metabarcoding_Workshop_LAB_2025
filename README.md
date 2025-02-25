# eDNA/Metabarcoding Workshop LAB 2025

In this workshop we will learn how to analyze illumina reads from eDNA or other mixed DNA sources

* [Computer Preparation](#computer-preparation)
  * [Install and Update R and RStudio](#install-and-update-r-and-rstudio)
  * [Create Directories](#create-directories)
  * [Get Raw Reads](#get-raw-reads)
* [RStudio](#rstudio)
  * [Install Cutadapt and Blast](#install-cutadapt-and-blast)
  * [RStudio Preparation](#rstudio-preparation)
  * [Cutadapt](#cutadapt)
  * [DADA2](#dada2)
  * [Visualize Results](#visualize-results)
  * [Assign Taxonomy](#assign-taxonomy)
  * [phyloseq](#phyloseq)

This protocol is for paired-end demultiplexed miseq sequences that have sufficient overlap to merge R1 and R2, and are going to be run on your computer, not on Hydra. It is broken up into sections, each section an `.R` document that can be opened in RStudio or (VSCode with the [R extension](https://code.visualstudio.com/docs/languages/r)).

However, before running RStudio, you must make sure the necessary programs are installed, and the illumina demultiplexed sequences have been downloaded.

## Computer Preparation

### Install and Update R and RStudio

If you do not have R and/or RStudio installed on your computer, go to [Installing R and RStudio](https://github.com/SmithsonianWorkshops/eDNA_Metabarcoding_Workshop_LAB_2025/blob/main/r-install.md) to install either or both.


### Get Raw Reads

The raw Illumina reads that you will be analyzing are in the Teams Channel for this workshop. You have each recieved an email letting you know which dataset you will be using. Download this data into the downloads directory.

## RStudio

The rest of this workshop will be run in RStudio

### Create a New Project

Open RStudio and create a new project. When you do this it will ask if you want to create it from an "Existing Directory" or a "New Directory". Choose "New Directory". For Mac users the default location is ~/user/username; this is where you want to create this new project. For Windows users, the default is in your documents folder. For many, this is backed up to OneDrive automatically, which may cause problems down the road with RStudio, so you want to browse to xxxxx and made a new project there. Making a new project from a new directory in RStudio will automatically create a project folder and a project file (.Rproject) in that folder.

### RStudio Preparation

Download this entire pipeline, including the RStudio files using this link: [Metabarcoding Workshop 2025 - RStudio Documents](https://github.com/SmithsonianWorkshops/eDNA_Metabarcoding_Workshop_LAB_2025/archive/refs/heads/main.zip). Download this .zip file and move/save it in the project directory.

Copy this next script into the Console panel (usually the entire left panel, or the bottom left panel if the Source Editor is open on the top left) of RStudio and run it. This will unzip the pipeline, organize files and directories, and remove the zipped file. This is probable the only script we will be running from the Console. We typically run all the scripts by opening each file in the Source Editor and running from there so we have a record of your analyses, including any changes made and any comments that may be needed along the way.

```
pipeline <- "https://github.com/SmithsonianWorkshops/eDNA_Metabarcoding_Workshop_LAB_2025/archive/refs/heads/main.zip"
untar(pipeline)
file.remove(pipeline)
```

Next we install and load all the R libraries needed for this pipeline. We also set up our directory structure and find, load, and copy the raw Illumina read files to the directory from which they will be analyzed. Open [RStudioPrep.R](https://xxxxxx) by clicking on the Files tab in the lower right panel, naviagating to the list of files, and selecting the appropriate file. This will open the chosen file in the Source Editor. You can run commands from the Source Editor using the "Run" button or `control + return`

## Install Cutadapt and Blast
Next we need to install Cutadapt and Blast. Neither are R programs, but we can install them through R. Open [Install Cutadapt and Blast](https://xxxxxx) and follow the directions.

## Cutadapt
We use Cutadapt to remove primer sequences from our raw reads. This section ends with primer-trimmed sequences. Open [Cutadapt_trim.R](https://xxxxxx) and follow the directions.

## DADA2
Here we use DADA2 to quality-filter and quality-trim reads, estimate error rates and denoise reads, merge paired reads, and remove chimeric sequences. This section ends with a sequence-table, which is a table containing columns of ASV's (Amplicon Sequence Variants), rows of samples, and cell values equal "# of reads", a feature-table (rows of ASVs and columns of samples - same as the output of Qiime2) a fasta file containing all ASVs, and a file associating ASVs with their unique md5 hash. Open [Data2.R](https://xxxxxx) and follow the directions.

## Visualize Results
Here we use several programs to visualize your results. We will explore our results multiple ways.  . Open [VisualizeResults](https://xxxxxx) and follow the directions.

## Assign Taxonomy

Here we use DADA2s RDP identifier and BLAST to assign taxonomic identities to ASV's. This section requires a reference library. We will supply you with a reference library for your identifications here, but later we will also show you how to get and create your own reference database. Open [TaxAssignment.R](https://xxxxxx) and follow the directions.

## phyloseq

Phyloseq is a R library that allows for manipulation, visualization, and analysis of metabarcoding data. This section describes how to set up and load your denoised results from DADA2 into phyloseq, how to perform some preliminary analyses, ana how to visualize a few basic results. Open [phyloseq](https://xxxxxx) and follow the directions.
