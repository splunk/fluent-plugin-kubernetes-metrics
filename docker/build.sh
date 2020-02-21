#!/usr/bin/env bash
set -e
TAG=$1

# Build Docker Image
VERSION=`cat VERSION`
docker build --build-arg VERSION=$VERSION --no-cache -t splunk/k8s-metrics:$TAG -f docker/Dockerfile .
