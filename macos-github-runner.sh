#! /bin/bash

# Installs and sets up conda on macOS GitHub Action runners.
#
# Intended to be run from GitHub Action steps. You'll want to also have a step
# early on in a job that sets the path, like this:
#
# jobs:
#   job-name-1:
#     name: jobs, part 1
#     runs-on: macOS-latest
#     steps:
#       - name: set path
#         run: echo "${HOME}/miniconda/bin" >> $GITHUB_PATH
#       - name: next step
#       ...

# Remove existing installation on macOS runners
sudo rm -rf /usr/local/miniconda
sudo rm -rf ${HOME}/miniconda

# Extract the versions we should be using from the previously-downloaded common.sh
curl -L "https://raw.githubusercontent.com/bioconda/bioconda-common/master/common.sh" > common.sh
BIOCONDA_UTILS_TAG=$(grep "^BIOCONDA_UTILS_TAG=" common.sh | cut -f2 -d "=" | sed "s/^v//g")
MINICONDA_VER=$(grep "^MINICONDA_VER=" common.sh | cut -f2 -d "=")

# Basic miniconda installation with bioconda channels configured
curl "https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VER}-MacOSX-x86_64.sh" > miniconda.sh
bash miniconda.sh -b -p "${HOME}/miniconda"
export PATH="${HOME}/miniconda/bin:${PATH}"
conda config --set always_yes yes
conda config --system --add channels defaults
conda config --system --add channels bioconda
conda config --system --add channels conda-forge
conda config --system --set channel_priority strict
conda info


conda install -y mamba

# By default, install bioconda-utils. However when testing bioconda-utils
# itself, we don't want to install it from conda.
if ${BIOCONDA_PREP_MACOS_FOR_BUILDING:=1}; then
    # The run_conda_forge_build_setup script, from the conda-forge-ci-setup
    # script, helps install required SDK for macOS.
    #
    # Installing bioconda-utils and conda-forge-ci-setup with conda causes dependency conflicts.
    # Installing bioconda-utils and conda-forge-ci-setup with mamba works fine.
    mamba install bioconda-utils=${BIOCONDA_UTILS_TAG} conda-forge-ci-setup

    # Set local channel as highest priority (requires conda-build, which is
    # installed as a dependency of bioconda-utils)
    mkdir -p "${HOME}/miniconda/conda-bld/{noarch,linux-64,osx-64}"
    conda index "${HOME}/miniconda/conda-bld"
    conda config --system --add channels "file://${HOME}/miniconda/conda-bld"
fi
