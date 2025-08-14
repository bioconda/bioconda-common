# Overview

This repository acts as a central "source of truth" which can be used by
various components of the Bioconda build system.

# Components

**`common.sh`:** contains environment variables that control versions.

**`install-and-set-up-conda.sh`:**
- downloads and installs conda using the Miniforge distribution
- installs bioconda-utils dependencies
- installs the version of bioconda-utils specified in common.sh via pip install

**`configure-conda.sh`:** ensures channels are configured correctly.

# Typical usage

In practice, a typical CI environment will do the following:

1. Download the files, typically via:

    ```bash
    wget https://raw.githubusercontent.com/bioconda/bioconda-common/master/{common,install-and-set-up-conda,configure-conda}.sh
    ```

2. Run `install-and-set-up-conda.sh` (which sources `common.sh`).

3. Use the CI platform's mechanism to cache the conda install dir (which is
   configured in `common.sh`).

4. After a cache restore, run `configure-conda.sh`. The reason for this is that
   the `--system` arg for `conda config` is not supported by mamba, and so the
   channel config ends up in the home directory which is not cached.
