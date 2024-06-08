BIOCONDA_UTILS_TAG=v3.3.1
MAMBAFORGE_VER=24.3.0-0
MAMBAFORGE_INSTALLATION_DIR="/opt/mambaforge"

# While these are specified in
# bioconda-utils:bioconda_utils/bioconda_utils-conda_build_config.yaml,
# they do not make it out into environment variables. Yet they are required for
# run_conda_forge_build_setup to set the correct deployment target.
platform=$(uname -s)
arch=$(uname -m)
if [[ "$platform" == "Darwin" ]]; then
    if [[ "$arch" == "arm64" ]]; then
        export MACOSX_DEPLOYMENT_TARGET=11
        export MACOSX_SDK_VERSION=11
    elif [[ "$arch" == 'x86_64' ]]; then
        export MACOSX_DEPLOYMENT_TARGET=10.13
        export MACOSX_SDK_VERSION=10.13
    fi
fi
