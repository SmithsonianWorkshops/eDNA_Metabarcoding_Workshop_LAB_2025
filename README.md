# eDNA/Metabarcoding Workshop LAB 2025
In this workshop we will learn how to analyze illumina reads from eDNA or other mixed DNA sources

* [Computer Preparation](computer-preparation) </br>
    * [Install and Update R and RStudio](install-and-update-r-and-rstudio) </br>
    * [Create Directories](#create-directories) </br>
    * [Get Raw Reads](#get-raw-reads) </br>
* [RStudio]("rstudio) </br>
    * [Install Cutadapt and Blast](#install-cutadapt-and-blast) </br>
    * [RStudio Preparation](#rstudio-preparation) </br>
    * [Cutadapt](cutadapt) </br>
    * [DADA2](dada2) </br>
    * [Visualize Results](visualize-results) </br>
    * [Assign Taxonomy](assign-taxonomy) </br>
    * [phyloseq](phyloseq) </br>

This protocol is for paired-end demultiplexed miseq sequences that have sufficient overlap to merge R1 and R2, and are going to be run on your computer, not on Hydra. It is broken up into sections, each section an `.R` document that can be opened in RStudio or (VSCode with the [R extension](https://code.visualstudio.com/docs/languages/r)).

However, before running RStudio, you must make sure the necessary programs are installed, and the illumina demultiplexed sequences have been downloaded.

## Computer Preparation
### Install and Update R and RStudio
If you do not have R and/or RStudio installed on your computer, go to [Installing R and RStudio](https://github.com/SmithsonianWorkshops/eDNA_Metabarcoding_Workshop_LAB_2025/blob/main/r-install.md) to install either or both.

### Create Directories
You first need to create a project directory to run these analyses and within this directory a data/raw directory to hold your raw Illumina reads. You can do this either through the terminal or using Finder (MAC)/File Explorer (windows).

Through a terminal on a Mac, use
```
mkdir -p PROJECTNAME/data/raw
```

Through a terminal on a Windows machine use
```
md PROJECTNAME/data/raw
```
### Get Raw Reads
Raw reads are available for download from the github repository. Download the dataset you have been assigned from the following list:  
[Dataset1a](https://xxxxxx)  
[Dataset 1b](https://xxxxxx)  
[Dataset 2a](https://xxxxxx)  
[Dataset 2b](https://xxxxxx)  

Move your compressed raw reads into PROJECTNAME/data/raw. We will decompress later through R.  
The rest of this pipeline will be run in RStudio.

## RStudio

Open RStudio and create a new project. When you do this it will ask if you want to create it from an "Existing Directory" or a new directory. Choose existing and browse to the project directory that you made earlier. Once you have created this project, it will automatically make this directory the current working directory, and you won't need to set your working directory later.

## Install Cutadapt and Blast
Go to [Install Cutadapt and Blast](https://xxxxxx). Copy this text into the Source Editor (typically the top left panel). We will run the remainder of this section through RStudio. You can run commands in the source editor using the "Run" button or `control + return`

### RStudio Preparation
Download this entire pipeline, including the RStudio files using this link: [Metabarcoding Workshop 2025 - RStudio Documents](https://github.com/SmithsonianWorkshops/eDNA_Metabarcoding_Workshop_LAB_2025/archive/refs/heads/main.zip). Download this .zip file and move/save it in the working directory of your project.

Copy this next script into the Source Editor of RStudio and run it. This will unzip the pipeline, organize files and directories, and remove the zipped file. We run all the scripts for this pipeline from this download so we have a record of your analysis, including any changes made and any comments that may be needed along the way.
```
pipeline <- "eDNA_Metabarcoding_Workshop_LAB_2025.zip"
untar(pipeline)
file.remove(pipeline)
```


Next we install and load all the R libraries needed for this pipeline. We also set up our directory structure and find, load, and copy the raw Illumina read files to the directory from which they will be analyzed. Open [RStudioPrep.R](https://xxxxxx) by on the Files tab in the lower right panel, naviagating to the list of files, and selecting the appropriate file. This will open the chosen file in the Source Editor.

## Cutadapt
We use Cutadapt to remove primer sequences from our raw reads. This section ends with primer-trimmed sequences. Open [Cutadapt_trim.R](https://xxxxxx) and follow the directions.

## DADA2
Here we use DADA2 to quality-filter and quality-trim reads, estimate error rates and denoise reads, merge paired reads, and remove chimeric sequences. This section ends with a sequence-table, which is a table containing columns of ASV's (Amplicon Sequence Variants), rows of samples, and cell values equal "# of reads", a feature-table (rows of ASVs and columns of samples - same as the output of Qiime2) a fasta file containing all ASVs, and a file associating ASVs with their unique md5 hash. Open [Data2.R](https://xxxxxx) and follow the directions.

## Assign Taxonomy
Here we use DADA2s RDP identifier and blast to assign taxonomic identities to ASV's. This section requires a reference library. We will supply you with a reference library for your identifications here, but later we will also show you how to get and create your own reference database. Open [TaxAssignment.R](https://xxxxxx) and follow the directions.

## Visualize Results
Here we use several programs to visualize your results. We are going  to assign taxonomic identities to ASV's. This section requires a reference library. LAB has libraries available for both COI and 12S, but you may want to use your own. How to do so is described in the section description. Open [VisualizeResults](https://xxxxxx) and follow the directions.

## phyloseq
Phyloseq is a R library that allows for manipulation, visualization, and analysis of metabarcoding data. This section describes how to set up and load your denoised results from DADA2 into phyloseq, how to perform some preliminary analyses, ana how to visualize a few basic results. Open [phyloseq](https://xxxxxx) and follow the directions.

