#! /bin/bash -e

export GIT_REV=$(git describe --always)
TAG=ideal-pancake
docker build --rm=true --tag=$TAG-base:${GIT_REV} -f BaseDockerFile .
