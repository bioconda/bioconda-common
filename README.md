This repository contains common definitions for the bioconda build system, e.g., the bioconda-utils tag to use and the miniconda version.


- `common.sh` contains environment variables that control versions
- `macos-github-runner.sh` sets up conda on macOS runners used in GitHub
  Actions. It is intended to be downloaded and run in other repos' GitHub
  Actions yaml files.
