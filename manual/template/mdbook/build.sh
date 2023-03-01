#!/usr/bin/env bash
set -uexo pipefail

# version of ockam for which we wish to generate markdown help
target_version="$1"
prefix="ockam_"
version=${target_version/#$prefix}

# remove folders that will be generated
rm -rf book src "$version" "../../$version"

# get the version
git clone --depth 1 git@github.com:build-trust/ockam.git "$version"
cd "$version"
git checkout "$target_version"

# generate markdown in src
cargo run --release --bin ockam markdown
mv ockam_markdown_pages ../src
cd ..

# generate mdbook - using ./src, into ../../$version
cp SUMMARY.md src/
mdbook build
mv book "../../$version"

# remove folders that were used during generation
rm -rf book src "$version"

# make latest
cd ../..
GLOBIGNORE='template:develop:v*'; rm -rf *
cp -R "$version"/. .
