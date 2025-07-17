#!/bin/bash
set -e

# - Installs miniforge to ${HOME}/miniforge. Version is determined by common.sh,
#   which is downloaded at runtime.
# - Sets channel order and sets strict channel priority
# - Installs bioconda-utils into a "bioconda" env (unless
#   $BIOCONDA_DISABLE_BUILD_PREP=1). Version is determined by common.sh.
# - Sets up local channel to have highest priority (unless $BIOCONDA_DISABLE_BUILD_PREP=1)

for dep in configure-conda.sh common.sh
do
    if [ ! -f $dep ]
    then
        echo "ERROR: The file $dep cannot be found in $(pwd). Please ensure it is present, e.g. using wget from the bioconda/bioconda-common repository. Exiting."
        exit 1
    fi
done

# Extract the versions we should be using from common.sh
source common.sh

# assert that common.sh has set the variables we need
for var in BIOCONDA_UTILS_TAG MINIFORGE_VER MINIFORGE_INSTALLATION_DIR
do
    if [ -z ${var+x} ]
    then
        echo "ERROR: The variable $var is not set by common.sh. Exiting."
        exit 1
    fi
done

BIOCONDA_UTILS_VER=$(echo ${BIOCONDA_UTILS_TAG} | sed "s/^v//g")
ARCH=$(uname -m)

if [[ $(uname) == "Darwin" ]]; then
    OS="MacOSX"
    
    # Remove existing installation on macOS runners
    sudo rm -rf ${MINIFORGE_INSTALLATION_DIR}
    sudo mkdir -p $(dirname $MINIFORGE_INSTALLATION_DIR)
    sudo chown -R $USER $(dirname $MINIFORGE_INSTALLATION_DIR)
    
    # conda-forge-ci-setup does some additional setup for Mac.
    BIOCONDA_ADDITIONAL_INSTALL_PKGS="conda-forge-ci-setup"
else
    mkdir -p $(dirname $MINIFORGE_INSTALLATION_DIR)
    OS="Linux"
    BIOCONDA_ADDITIONAL_INSTALL_PKGS=""
fi

MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VER}/Miniforge3-${MINIFORGE_VER}-${OS}-${ARCH}.sh"

# Install miniforge
echo Download ${MINIFORGE_URL}
curl -L ${MINIFORGE_URL} > miniforge.sh
head miniforge.sh
bash miniforge.sh -b -p "${MINIFORGE_INSTALLATION_DIR}"

export PATH="${MINIFORGE_INSTALLATION_DIR}/bin:${PATH}"

# Set up channels
# disable build preparation here because we don't yet have the local channel from conda-build
BIOCONDA_DISABLE_BUILD_PREP=1 bash configure-conda.sh

# By default, for building packages, we install bioconda-utils. However when
# testing bioconda-utils itself, we don't want to install a release, in
# which case set BIOCONDA_DISABLE_BUILD_PREP to a non-zero value.
if [ ${BIOCONDA_DISABLE_BUILD_PREP:=0} == 0 ]; then
    
    source ${MINIFORGE_INSTALLATION_DIR}/etc/profile.d/conda.sh
    source ${MINIFORGE_INSTALLATION_DIR}/etc/profile.d/mamba.sh
    
    # set up env with all dependencies
    conda create -n bioconda -y --file https://raw.githubusercontent.com/bioconda/bioconda-utils/$BIOCONDA_UTILS_TAG/bioconda_utils/bioconda_utils-requirements.txt $BIOCONDA_ADDITIONAL_INSTALL_PKGS
    
    conda activate bioconda
    
    # install bioconda-utils itself via pip (this way we don't always have to wait for the conda package to be built before being able to fix things here)
    pip install git+https://github.com/bioconda/bioconda-utils.git@$BIOCONDA_UTILS_TAG
    
    # Set local channel as highest priority (requires conda-build, which is
    # installed as a dependency of bioconda-utils)
    mkdir -p "${MINIFORGE_INSTALLATION_DIR}/conda-bld/{noarch,linux-64,osx-64,linux-aarch64,osx-arm64}"
    # The base installation does not include conda-index, so use "command conda" to run bioconda
    # env's "conda index".
    command conda index "${MINIFORGE_INSTALLATION_DIR}/conda-bld"
    conda config --add channels "file://${MINIFORGE_INSTALLATION_DIR}/conda-bld"
fi

echo "=========="
echo "conda config:"
conda config --show
echo "=========="
echo "environment(s): $(conda env list)"
echo "DONE setting up via $0"

