# Installing command line tools for Mac or Windows
# cutadapt
# NCBI blast

# Download and install paths will vary by OS
os <- Sys.info()["sysname"]

# Using pixi to install cutadapt in R
#

# First, is cutadapt already installed via pixi?
# If it is, we won't reinstall.

# Expected location of cutadapt in the pixi install dir, this is determined
# by the OS you're using
cutadapt_loc_path <- switch(os,
                            "Windows" = "Scripts",
                            "Darwin" = "bin",
                            "Linux" = "bin",
                            stop(paste0("Unkown sysname: ", os))
)

# Full path to where cutadapt will be
cutadapt <- paste0(getwd(), "/.pixi/envs/default/", cutadapt_loc_path, "/cutadapt")

# If the cutadapt executable isn't already there, install it.
if (!file.exists(cutadapt)) {
  # Name of the pixi download
  pixi_archive <- switch (os,
                          "Windows" = "pixi-x86_64-pc-windows-msvc.zip",
                          "Darwin" = "pixi-x86_64-apple-darwin.tar.gz",
                          "Linux" = "pixi-x86_64-unknown-linux-musl.tar.gz",
                          stop(paste0("Unkown sysname: ", os))
  )

  # Download and extract the pixi executable
  pixi_url <- paste0("https://github.com/prefix-dev/pixi/releases/latest/download/", pixi_archive)
  download.file(pixi_url, pixi_archive)

  # Decompress the tar.bz2 file and then remove it
  untar(pixi_archive)
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

} else {
  message(paste0("cutadapt appears to be installed already. It was found here: ", cutadapt))
}

message("Attempting to run cutdapt, you should see the cutadapt usage message...\nIf you don't STOP here and review the code.")

# This should give a cutadapt help message, if not review the install.
system2(cutadapt)


# Download blast+ executable from NCBI
#

if (exists("os")) {
  os <- Sys.info()["sysname"]
}

blast_ver <- "2.16.0"
blast_dir <- paste0("ncbi-blast-", blast_ver, "+")
blast_bin <- paste0(getwd(), "/", blast_dir, "/bin")

# Check if the blast_bin directory exists, if not we need to install blast.
if (!dir.exists(blast_bin)) {

  # This sets the right file to download for the current OS
  blast_archive_extension <- switch(os,
                                    "Windows" = "-x64-win64.tar.gz",
                                    "Darwin" = "-universal-macosx.tar.gz",
                                    "Linux" = "-x64-linux.tar.gz",
                                    stop(paste0("Unknown sysname: ", os))
  )

  blast_archive <- paste0(blast_dir, blast_archive_extension)

  # Download BLAST
  blast_url <- paste0("https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/", blast_ver, "/", blast_archive)
  download.file( blast_url, blast_archive)

  # Decompress and then remove the download
  untar(blast_archive)
  file.remove(blast_archive)
} else {
  message(paste0("A copy of blast appears to be installed already in the project folder. It was found here: ", blast_bin))
}

# Update the system environment's PATH to include the BLAST bin directory
# Get the current PATH
current_path <- Sys.getenv("PATH")

# Add the current working directory to the PATH
Sys.setenv(PATH = paste(current_path, blast_bin, sep = .Platform$path.sep))

# Test that blastn is now available
system2("blastn", args = "-version")

