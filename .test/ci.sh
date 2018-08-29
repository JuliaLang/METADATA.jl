#!/bin/sh
set -e
cd $(dirname $0)/..
BUILD_DIR=$PWD
[ -z "$CI_TMP_DIR" ] && CI_TMP_DIR=$PWD/..
[ -z "$JULIA_PKGDIR" ] && JULIA_PKGDIR=$HOME/.julia
export BUILD_DIR JULIA_PKGDIR

# Ensure that "origin/HEAD" is present (typically set to "origin/metadata-v2")
git fetch origin +:refs/remotes/origin/HEAD

# Need to be on a local or remote branch for check_metadata
git checkout -q --detach HEAD && git branch -D localbranch 2>/dev/null || true
git checkout -b localbranch

mkdir -p $CI_TMP_DIR
cd $CI_TMP_DIR

ver=$CI_JULIA_VERSION
if [ $ver = "nightly" ]; then
  url="https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz"
  ver=1.1
else
  url="https://julialang-s3.julialang.org/bin/linux/x64/$ver/julia-$ver-latest-linux-x86_64.tar.gz"
fi
mkdir -p $JULIA_PKGDIR/v$ver/.cache julia-$ver
ln -s $BUILD_DIR $JULIA_PKGDIR/v$ver/METADATA
if [ $ver = "0.6" ]; then
  curl -A "$CI_NAME for METADATA tests $(curl --version | head -n 1)" -L --retry 5 $url | \
    tar -C julia-$ver --strip-components=1 -xzf - && \
    julia-$ver/bin/julia -e 'versioninfo(); include("$(ENV["BUILD_DIR"])/.test/METADATA.jl")'
else
  curl -A "$CI_NAME for METADATA tests $(curl --version | head -n 1)" -L --retry 5 $url | \
    tar -C julia-$ver --strip-components=1 -xzf - && \
    julia-$ver/bin/julia -e 'using InteractiveUtils; versioninfo(); include("$(ENV["BUILD_DIR"])/.test/METADATA.jl")'
fi
