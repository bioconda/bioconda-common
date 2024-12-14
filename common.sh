BIOCONDA_UTILS_TAG=v3.6.1
MAMBAFORGE_VER=24.9.0-0
MAMBAFORGE_INSTALLATION_DIR="/opt/mambaforge"
platform=$(uname -s)
arch=$(uname -m)
if [[ "$platform" == "Darwin" ]]; then
    if [[ "$arch" == "arm64" ]]; then
        export MACOSX_DEPLOYMENT_TARGET=11.0
        export MACOSX_SDK_VERSION=11.0
    elif [[ "$arch" == 'x86_64' ]]; then
        export MACOSX_DEPLOYMENT_TARGET=10.13
        export MACOSX_SDK_VERSION=10.13
    fi
fi
