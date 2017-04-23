#!/bin/sh
set -e
cd $(dirname $0)/..
BUILD_DIR=$PWD
[ -z "$CI_TMP_DIR" ] && CI_TMP_DIR=$PWD/..
[ -z "$JULIA_PKGDIR" ] && JULIA_PKGDIR=$HOME/.julia
export BUILD_DIR JULIA_PKGDIR

# Need to be on a local or remote branch for check_metadata
git checkout -q --detach HEAD && git branch -D localbranch 2>/dev/null || true
git checkout -b localbranch

mkdir -p $CI_TMP_DIR
cd $CI_TMP_DIR
for ver in 0.4 0.5 0.6; do
  mkdir -p $JULIA_PKGDIR/v$ver/.cache julia-$ver
  ln -s $BUILD_DIR $JULIA_PKGDIR/v$ver/METADATA
  if [ $ver = 0.6 ]; then
    url="julianightlies/bin/linux/x64/julia-latest-linux64"
  else
    url="julialang/bin/linux/x64/$ver/julia-$ver-latest-linux-x86_64"
  fi
  curl -A "$CI_NAME for METADATA tests $(curl --version | head -n 1)" \
    -L --retry 5 https://s3.amazonaws.com/$url.tar.gz | \
    tar -C julia-$ver --strip-components=1 -xzf - && \
    julia-$ver/bin/julia -e 'versioninfo(); include("$(ENV["BUILD_DIR"])/.test/METADATA.jl")' && \
    touch success-$ver &
done
wait
if ! [ -e success-0.4 -a -e success-0.5 ]; then # add success-0.6 once there are any 0.6-only package versions
  exit 1
fi
