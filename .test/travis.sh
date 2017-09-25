#!/bin/sh
set -e
cd $(dirname $0)/..
echo "TRAVIS_PULL_REQUEST: $TRAVIS_PULL_REQUEST"
echo "TRAVIS_PULL_REQUEST_SHA: $TRAVIS_PULL_REQUEST_SHA"
git log -2
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  git fetch origin +refs/pull/$TRAVIS_PULL_REQUEST/merge:
  git log -2 FETCH_HEAD
fi
