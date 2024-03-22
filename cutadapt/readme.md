# Installing CutAdapt
### Install Conda with Miniforge
1. On the ASC run `wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"`
2. `bash Miniforge3-$(uname)-$(uname -m).sh`
3. Accept defaults. You may have to add the bin to your path with `export PATH="/home/YOURUSERID/miniforge3/bin:$PATH"`
4. Make sure conda is installed by running `conda --version` More information at https://github.com/conda-forge/miniforge
### Install CutAdapt with Conda
5. `conda config --add channels bioconda`
6. `conda config --add channels conda-forge`
7. `conda config --set channel_priority strict`
8. `conda create -n cutadapt cutadapt`
9. `conda activate cutadaptenv`
10. `cutadapt --version` to make sure cutadapt installed properly. You may be prompted to run `conda init` and might have to close and reopen your terminal.
