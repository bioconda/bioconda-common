# This script can be used to reconfigure conda to use the right channel setup.
# This has to be done after the cache is restored, because
# the channel setup is not cached as it resides in the home directory.
# We could use a system-wide (and therefore cached) channel setup,
# but mamba does not support that at the time of implementation
# (it ignores settings made with --system).

if [ ! -f common.sh ]
then
    echo "ERROR: The file common.sh cannot be found in $(pwd). Please ensure it is present, e.g. using wget from the bioconda/bioconda-common repository. Exiting."
    exit 1
fi

source common.sh

# assert that common.sh has set the variables we need
if [ -z ${MINIFORGE_INSTALLATION_DIR+x} ]
then
    echo "ERROR: The variable MINIFORGE_INSTALLATION_DIR is not set by common.sh. Exiting."
    exit 1
fi

conda config --set always_yes yes
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --remove channels defaults || true
conda config --set channel_priority strict
# .conda support is pending https://github.com/conda/infrastructure/issues/950
# conda config --set conda_build.pkg_format 2

if [ ${BIOCONDA_DISABLE_BUILD_PREP:=0} == 0 ]; then
    conda config --add channels "file://${MINIFORGE_INSTALLATION_DIR}/conda-bld"
fi
