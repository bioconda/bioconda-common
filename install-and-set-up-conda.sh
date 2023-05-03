#! /bin/bash

set -e

# - Installs mambaforge to ${HOME}/mambaforge. Version is determined by common.sh,
#   which is downloaded at runtime.
# - Sets channel order and sets strict channel priority
# - Installs mamba into the base env
# - Installs bioconda-utils into a "bioconda" env (unless
#   $BIOCONDA_DISABLE_BUILD_PREP=1). Version is determined by common.sh.
# - Sets up local channel to have highest priority (unless $BIOCONDA_DISABLE_BUILD_PREP=1)

# Extract the versions we should be using from common.sh
COMMON_GIT_REF=${COMMON_GIT_REF:-master}
curl -L "https://raw.githubusercontent.com/bioconda/bioconda-common/${COMMON_GIT_REF}/common.sh" > common.sh
cat common.sh

BIOCONDA_UTILS_TAG=$(grep "^BIOCONDA_UTILS_TAG=" common.sh | cut -f2 -d "=" | sed "s/^v//g")
MAMBAFORGE_VER=$(grep "^MAMBAFORGE_VER=" common.sh | cut -f2 -d "=")
MAMBAFORGE_INSTALLATION_DIR="/opt/mambaforge"
ARCH=$(uname -m)

if [[ $(uname) == "Darwin" ]]; then
    OS="MacOSX"
    
    # Remove existing installation on macOS runners
    sudo rm -rf ${MAMBAFORGE_INSTALLATION_DIR}
    sudo mkdir -p $(dirname $MAMBAFORGE_INSTALLATION_DIR)
    sudo chown -R $USER $(dirname $MAMBAFORGE_INSTALLATION_DIR)
    
    # conda-forge-ci-setup does some additional setup for Mac.
    # Installing bioconda-utils and conda-forge-ci-setup with conda causes dependency conflicts.
    # Installing bioconda-utils and conda-forge-ci-setup with mamba works fine.
    BIOCONDA_ADDITIONAL_INSTALL_PKGS="conda-forge-ci-setup"
else
    mkdir -p $(dirname $MAMBAFORGE_INSTALLATION_DIR)
    OS="Linux"
    BIOCONDA_ADDITIONAL_INSTALL_PKGS=""
fi

MAMBAFORGE_URL="https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VER}/Mambaforge-${MAMBAFORGE_VER}-${OS}-${ARCH}.sh"

# Install mambaforge
echo Download ${MAMBAFORGE_URL}
curl -L ${MAMBAFORGE_URL} > mambaforge.sh
head mambaforge.sh
bash mambaforge.sh -b -p "${MAMBAFORGE_INSTALLATION_DIR}"

export PATH="${MAMBAFORGE_INSTALLATION_DIR}/bin:${PATH}"

# Set up channels
conda config --set always_yes yes
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
mamba info

mamba install mamba -y

# By default, for building packages, we install bioconda-utils. However when
# testing bioconda-utils itself, we don't want to install it from conda, in
# which case set BIOCONDA_DISABLE_BUILD_PREP to a non-zero value.
if [ ${BIOCONDA_DISABLE_BUILD_PREP:=0} == 0 ]; then
    
    mamba create -n bioconda -y bioconda-utils=$BIOCONDA_UTILS_TAG $BIOCONDA_ADDITIONAL_INSTALL_PKGS
    
    source ${MAMBAFORGE_INSTALLATION_DIR}/etc/profile.d/conda.sh
    source ${MAMBAFORGE_INSTALLATION_DIR}/etc/profile.d/mamba.sh
    mamba activate bioconda
    
    # Set local channel as highest priority (requires conda-build, which is
    # installed as a dependency of bioconda-utils)
    mkdir -p "${MAMBAFORGE_INSTALLATION_DIR}/conda-bld/{noarch,linux-64,osx-64}"
    conda index "${MAMBAFORGE_INSTALLATION_DIR}/conda-bld"
    conda config --add channels "file://${MAMBAFORGE_INSTALLATION_DIR}/conda-bld"
fi

echo "=========="
echo "conda config:"
conda config --show
echo "=========="
echo "environment(s): $(conda env list)"
echo "DONE setting up via $0"

