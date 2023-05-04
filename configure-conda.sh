MAMBAFORGE_INSTALLATION_DIR="/opt/mambaforge"

conda config --set always_yes yes
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

if [ ${BIOCONDA_DISABLE_BUILD_PREP:=0} == 0 ]; then
    conda config --add channels "file://${MAMBAFORGE_INSTALLATION_DIR}/conda-bld"
fi