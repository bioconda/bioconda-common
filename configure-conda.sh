# This script can be used to reconfigure conda to use the right channel setup.
# This has to be done after the cache is restored, because
# the channel setup is not cached as it resides in the home directory.
# We could use a system-wide (and therefore cached) channel setup,
# but mamba does not support that at the time of implementation
# (it ignores settings made with --system).

MAMBAFORGE_INSTALLATION_DIR="/opt/mambaforge"

conda config --set always_yes yes
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

if [ ${BIOCONDA_DISABLE_BUILD_PREP:=0} == 0 ]; then
    conda config --add channels "file://${MAMBAFORGE_INSTALLATION_DIR}/conda-bld"
fi