#!/usr/bin/env bash
set -uexo pipefail

version="v0.81.0"

# the build script would look something like this

rm -rf src "$version" "../../$version"

# git clone --depth 1 --branch "ockam_$version" git@github.com:build-trust/ockam.git "$version"
git clone git@github.com:murex971/ockam.git "$version"
cd "$version" && git checkout murex971/markdown
cargo run --release --bin ockam markdown
mv ockam_markdown_pages ../src
cd ..

cp SUMMARY.md src/

mdbook build

# move to version folder
mv book "../../$version"

rm -rf book src "$version"

# make latest
cd ../..
GLOBIGNORE='template:v*'; rm -rf *
cp -R "$version"/. .
