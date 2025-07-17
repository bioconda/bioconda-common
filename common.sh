# Respect overrides from environment
BIOCONDA_UTILS_TAG=${BIOCONDA_UTILS_TAG:="v3.7.2"}
MAMBAFORGE_VER=${MAMBAFORGE_VER:="24.11.3-2"}
MAMBAFORGE_INSTALLATION_DIR=${MAMBAFORGE_INSTALLATION_DIR:="/opt/mambaforge"}
platform=$(uname -s)
arch=$(uname -m)
if [[ "$platform" == "Darwin" ]]; then
    if [[ "$arch" == "arm64" ]]; then
        export MACOSX_DEPLOYMENT_TARGET=13.0
        export MACOSX_SDK_VERSION=13.0
    elif [[ "$arch" == "x86_64" ]]; then
        export MACOSX_DEPLOYMENT_TARGET=11.0
        export MACOSX_SDK_VERSION=11.0
    fi
fi
