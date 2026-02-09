# Respect overrides from environment
BIOCONDA_UTILS_TAG=${BIOCONDA_UTILS_TAG:="v3.9.2"}
MINIFORGE_VER=${MINIFORGE_VER:="25.3.1-0"}
MINIFORGE_INSTALLATION_DIR=${MINIFORGE_INSTALLATION_DIR:="/opt/mambaforge"}
platform=$(uname -s)
arch=$(uname -m)
if [[ "$platform" == "Darwin" ]]; then
    if [[ "$arch" == "arm64" ]]; then
        export MACOSX_DEPLOYMENT_TARGET=11.3
        export MACOSX_SDK_VERSION=11.3
    elif [[ "$arch" == "x86_64" ]]; then
        export MACOSX_DEPLOYMENT_TARGET=11.3
        export MACOSX_SDK_VERSION=11.3
    fi
fi
