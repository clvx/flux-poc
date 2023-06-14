# Flux PoC

## Getting Started

There are 2 clusters defined in this repo.

    clusters/
    ├── dev
    └── stage

    2 directories, 0 files

To get started, modify `ENV` in Makefile pointing to one of the above clusters 
and run `make bootstrap`.

- If it doesn't exist nor it's tracked, it will create the cluster and trigger 
a full bootstrap.

- If cluster exists and tracked, it will skip.

## Installation

I shipped a `flake.nix` with all the dependencies to run this.

If you have `nix` installed and `direnv`, just do `direnv allow` if it isn't already.

