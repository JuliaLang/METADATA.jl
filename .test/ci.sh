#!/bin/sh
set -e
cd $(dirname $0)/..
git checkout -b localbranch
cd ..
ln -s $PWD/METADATA.jl METADATA
for ver in 0.4 0.5 0.6; do
  mkdir -p ~/.julia/v$ver/.cache julia-$ver
  ln -s $PWD/METADATA.jl ~/.julia/v$ver/METADATA
  if [ $ver = 0.6 ]; then
    url="julianightlies/bin/linux/x64/julia-latest-linux64"
  else
    url="julialang/bin/linux/x64/$ver/julia-$ver-latest-linux-x86_64"
  fi
  curl -A "Travis-CI for METADATA tests $(curl --version | head -n 1)" \
    -L --retry 5 https://s3.amazonaws.com/$url.tar.gz | \
    tar -C julia-$ver --strip-components=1 -xzf - && \
    julia-$ver/bin/julia -e 'versioninfo(); include("METADATA/.test/METADATA.jl")' && \
    touch success-$ver &
done
wait
if ! [ -e success-0.4 -a -e success-0.5 ]; then # add success-0.6 once there are any 0.6-only package versions
  exit 1
fi
