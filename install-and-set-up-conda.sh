#! /bin/bash

set -e

# - Installs miniconda to ${HOME}/miniconda. Version is determined by common.sh,
#   which is downloaded at runtime.
# - Sets channel order and sets strict channel priority
# - Installs mamba into the base env
# - Installs bioconda-utils into a "bioconda" env (unless
#   $BIOCONDA_DISABLE_BUILD_PREP=1). Version is determined by common.sh.
# - Sets up local channel to have highest priority (unless $BIOCONDA_DISABLE_BUILD_PREP=1)

# Extract the versions we should be using from common.sh
curl -L "https://raw.githubusercontent.com/bioconda/bioconda-common/master/common.sh" > common.sh
BIOCONDA_UTILS_TAG=$(grep "^BIOCONDA_UTILS_TAG=" common.sh | cut -f2 -d "=" | sed "s/^v//g")
MINICONDA_VER=$(grep "^MINICONDA_VER=" common.sh | cut -f2 -d "=")
MINICONDA_INSTALLATION_DIR="/opt/miniconda"
ARCH=$(uname -m)

if [[ $(uname) == "Darwin" ]]; then
    OS="MacOSX"

    # Remove existing installation on macOS runners
    sudo rm -rf /usr/local/miniconda
    sudo rm -rf ${MINICONDA_INSTALLATION_DIR}
    sudo mkdir -p $(dirname $MINICONDA_INSTALLATION_DIR)
    sudo chown -R $USER $(dirname $MINICONDA_INSTALLATION_DIR)

    # conda-forge-ci-setup does some additional setup for Mac.
    # Installing bioconda-utils and conda-forge-ci-setup with conda causes dependency conflicts.
    # Installing bioconda-utils and conda-forge-ci-setup with mamba works fine.
    BIOCONDA_ADDITIONAL_INSTALL_PKGS="conda-forge-ci-setup"
else
    mkdir -p $(dirname $MINICONDA_INSTALLATION_DIR)
    OS="Linux"
    BIOCONDA_ADDITIONAL_INSTALL_PKGS=""
fi


# Install miniconda
curl -L "https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VER}-${OS}-${ARCH}.sh" > miniconda.sh
bash miniconda.sh -b -p "${MINICONDA_INSTALLATION_DIR}"

export PATH="${MINICONDA_INSTALLATION_DIR}/bin:${PATH}"

# Set up channels
conda config --set always_yes yes
conda config --system --add channels defaults
conda config --system --add channels bioconda
conda config --system --add channels conda-forge
conda config --system --set channel_priority strict
conda info

conda install mamba -y

# By default, for building packages, we install bioconda-utils. However when
# testing bioconda-utils itself, we don't want to install it from conda, in
# which case set BIOCONDA_DISABLE_BUILD_PREP to a non-zero value.
if [ ${BIOCONDA_DISABLE_BUILD_PREP:=0} == 0 ]; then

    mamba create -n bioconda -y bioconda-utils=$BIOCONDA_UTILS_TAG $BIOCONDA_ADDITIONAL_INSTALL_PKGS

    source ${MINICONDA_INSTALLATION_DIR}/etc/profile.d/conda.sh
    conda activate bioconda

    # Set local channel as highest priority (requires conda-build, which is
    # installed as a dependency of bioconda-utils)
    mkdir -p "${MINICONDA_INSTALLATION_DIR}/conda-bld/{noarch,linux-64,osx-64}"
    conda index "${MINICONDA_INSTALLATION_DIR}/conda-bld"
    conda config --system --add channels "file://${MINICONDA_INSTALLATION_DIR}/conda-bld"
fi

echo "=========="
echo "conda config:"
conda config --show
echo "=========="
echo "environment(s): $(conda env list)"
echo "DONE setting up via $0"

