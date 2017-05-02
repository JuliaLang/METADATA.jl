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
for ver in 0.4 0.5 0.6 nightly; do
  if [ $ver = "nightly" ]; then
    url="julianightlies/bin/linux/x64/julia-latest-linux64"
    ver=0.7
  elif [ $ver = "0.6" ]; then # delete this case once rc1 is available
    url="julianightlies/bin/linux/x64/0.6/julia-0.6.0-609b3d12c7-linux64"
  else
    url="julialang/bin/linux/x64/$ver/julia-$ver-latest-linux-x86_64"
  fi
  mkdir -p $JULIA_PKGDIR/v$ver/.cache julia-$ver
  ln -s $BUILD_DIR $JULIA_PKGDIR/v$ver/METADATA
  curl -A "$CI_NAME for METADATA tests $(curl --version | head -n 1)" \
    -L --retry 5 https://s3.amazonaws.com/$url.tar.gz | \
    tar -C julia-$ver --strip-components=1 -xzf - && \
    julia-$ver/bin/julia -e 'versioninfo(); include("$(ENV["BUILD_DIR"])/.test/METADATA.jl")' && \
    touch success-$ver &
done
wait
if ! [ -e success-0.4 -a -e success-0.5 -a -e success-0.6 ]; then # nightly allowed to fail
  exit 1
fi
