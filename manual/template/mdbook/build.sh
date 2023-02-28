#!/usr/bin/env bash
set -uexo pipefail

# the build script would look something like this

rm -rf src v0.81.0
# git clone --depth 1 --branch ockam_v0.81.0 git@github.com:build-trust/ockam.git v0.81.0
git clone git@github.com:murex971/ockam.git v0.81.0
cd v0.81.0 && git checkout murex971/markdown
cargo run --release --bin ockam markdown
mv ockam_markdown_pages ../src
cd ..

for f in $(find src -type f); do mv $f ${f}.md; done
cp SUMMARY.md src/

mdbook build
mv book ../v0.81.0

rm -rf book src v0.81.0
