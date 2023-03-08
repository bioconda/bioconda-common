#! /bin/bash

# - Installs miniconda to /miniconda
# - Sets channels
# - Installs mamba into the base env
# - Installs bioconda-utils into a "bioconda" env.
# - Sets up local channel to have highest priority (unless $BIOCONDA_DISABLE_BUILD_PREP=1)
#
# Intended to be run from GitHub Action or Azure Pipeline or CircleCI steps.
# You'll want to also have a step early on in a job that sets the path, like
# this, (for GitHub Actions):
#
# jobs:
#   job-name-1:
#     name: ...
#     runs-on: ...
#     steps:
#       - name: set path
#         run: echo "/miniconda/bin" >> $GITHUB_PATH
#       - name: ...

# Extract the versions we should be using from common.sh
curl -L "https://raw.githubusercontent.com/bioconda/bioconda-common/master/common.sh" > common.sh
BIOCONDA_UTILS_TAG=$(grep "^BIOCONDA_UTILS_TAG=" common.sh | cut -f2 -d "=" | sed "s/^v//g")
MINICONDA_VER=$(grep "^MINICONDA_VER=" common.sh | cut -f2 -d "=")


if [[ $(uname) == "Darwin" ]]; then
    OS="MacOSX"

    # Remove existing installation on macOS runners
    sudo rm -rf /usr/local/miniconda
    sudo rm -rf ${HOME}/miniconda

    # conda-forge-ci-setup does some additional setup.
    # Installing bioconda-utils and conda-forge-ci-setup with conda causes dependency conflicts.
    # Installing bioconda-utils and conda-forge-ci-setup with mamba works fine.
    BIOCONDA_ADDITIONAL_INSTALL_PKGS="conda-forge-ci-setup"
else
    OS="Linux"
    BIOCONDA_ADDITIONAL_INSTALL_PKGS=""
fi


# Install miniconda
curl -L "https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VER}-${OS}-x86_64.sh" > miniconda.sh
bash miniconda.sh -b -p "${HOME}/miniconda"

export PATH="${HOME}/miniconda/bin:${PATH}"

# Set up channels
conda config --set always_yes yes
conda config --system --add channels defaults
conda config --system --add channels bioconda
conda config --system --add channels conda-forge
conda config --system --set channel_priority strict
conda info


# By default, for building packages, we install bioconda-utils. However when
# testing bioconda-utils itself, we don't want to install it from conda, in
# which case set BIOCONDA_DISABLE_BUILD_PREP to some nonzero value.
if ${BIOCONDA_DISABLE_BUILD_PREP:=0}; then

    mamba create -n bioconda -y bioconda-utils=$BIOCONDA_UTILS_TAG $BIOCONDA_ADDITIONAL_INSTALL_PKGS

    # Set local channel as highest priority (requires conda-build, which is
    # installed as a dependency of bioconda-utils)
    mkdir -p "${HOME}/miniconda/conda-bld/{noarch,linux-64,osx-64}"
    conda index "${HOME}/miniconda/conda-bld"
    conda config --system --add channels "file://${HOME}/miniconda/conda-bld"
fi
