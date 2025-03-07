# Installing command line tools for Mac or Windows:
#   cutadapt:     https://cutadapt.readthedocs.io/
#   NCBI BLAST+:  https://www.ncbi.nlm.nih.gov/books/NBK279690/

#######
# Cutadapt is a python-based program. We'll be using pixi (https://pixi.sh/) to
# install cutadapt. pixi uses conda recopies to install packages without require
# a full conda install. We'll first install pixi, then have it install python
# and finally use the python system PyPi to install cutadapt. This method works
# for Windows, Macs, and Linux.

# Name of the pixi download file depends on the OS of the system
os <- Sys.info()["sysname"]
pixi_archive <- switch (os,
                        "Windows" = "pixi-x86_64-pc-windows-msvc.zip",
                        "Darwin" = "pixi-x86_64-apple-darwin.tar.gz",
                        "Linux" = "pixi-x86_64-unknown-linux-musl.tar.gz",
                        stop(paste0("Unkown sysname: ", os)))

# Download and extract the pixi executable
pixi_url <-
  paste0("https://github.com/prefix-dev/pixi/releases/latest/download/",
         pixi_archive)
download.file(pixi_url, pixi_archive)

# Decompress the file
if (grepl("zip", pixi_archive)){
  unzip(pixi_archive)
} else if (grepl("tar.gz", pixi_archive)){
  untar(pixi_archive)
} else{
  stop(paste0("unknown pixi archive extension:", pixi_archive))
}
file.remove(pixi_archive)

# The pixi executable is named pixi in the current directory

# Install cutadapt from bioconda using pixi:
# A file name pixi.toml is created with the channels and packages
# The cutadapt executable and dependencies are installed
# in a hidden .pixi/ directory
if (!file.exists("pixi.toml")) {
  system2("./pixi", args = "init")
}
system2("./pixi", args = "add python")
system2("./pixi", args = "add --pypi cutadapt")

# Clean up un-needed pixi-related files
pixi_cruff <- list.files(pattern = "pixi")
file.remove(pixi_cruff)

# The location of cutadapt in the pixi install dir, this is determined
# by the OS you're using
cutadapt_loc_path <- switch(os,
                            "Windows" = "Scripts",
                            "Darwin" = "bin",
                            "Linux" = "bin",
                            stop(paste0("Unkown sysname: ", os)))

# Full path to where cutadapt will be
cutadapt <-
  paste0(getwd(),
         "/.pixi/envs/default/",
         cutadapt_loc_path,
         "/cutadapt")


# Download blast+ executable from NCBI
#

blast_ver <- "2.16.0"
blast_dir <- paste0("ncbi-blast-", blast_ver, "+")
blast_bin <- paste0(getwd(), "/", blast_dir, "/bin")

# Set the object os again, just in case you're starting the script
# from this point to only install BLAST
os <- Sys.info()["sysname"]

# This sets the right file to download for the current OS
blast_archive_extension <- switch(os,
                                  "Windows" = "-x64-win64.tar.gz",
                                  "Darwin" = "-universal-macosx.tar.gz",
                                  "Linux" = "-x64-linux.tar.gz",
                                  stop(paste0("Unknown sysname: ", os)))

blast_archive <- paste0(blast_dir, blast_archive_extension)

# Download BLAST
blast_url <-
  paste0(
    "https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/",
    blast_ver,
    "/",
    blast_archive
  )
download.file(blast_url, blast_archive)

# Decompress and then remove the download
untar(blast_archive)
file.remove(blast_archive)

# Update the system environment's PATH to include the BLAST bin directory
# Get the current PATH
path_with_blast <-
  paste(blast_bin, Sys.getenv("PATH"), sep = .Platform$path.sep)

# Update the system's PATH variable to include BLAST
# NOTE: this only lasts for the current R session and will need to reset
Sys.setenv(PATH = path_with_blast)


# Now lets test if cutadapt and BLAST are installed

# Testing cutadapt...
# After the next command you should see some cutadapt help
# messages that end in:
#   Run "cutadapt --help" to see all command-line options.
#   See https://cutadapt.readthedocs.io/ for full documentation.

# This should give a cutadapt help message, if not review the install.
system2(cutadapt)

# Test that blastn is now available
system2("blastn", args = "-version")

# Save cutadapt and path_with_blast objects
save(cutadapt,
     path_with_blast,
     file = "data/working/0_cutadapt_blast.RData")
