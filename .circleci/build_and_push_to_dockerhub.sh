#!/usr/bin/env bash
set -e
FLUENTD_HEC_GEM_VERSION=`cat docker/FLUENTD_HEC_GEM_VERSION`
echo "Building docker image..."
cp /tmp/pkg/fluent-plugin-kubernetes-metrics-*.gem docker
echo "Copying licenses to be included in the docker image..."
mkdir licenses
cp -rp LICENSE licenses/
VERSION=`cat VERSION`
docker build --build-arg VERSION=$FLUENTD_HEC_GEM_VERSION --no-cache -t splunk/fluent-plugin-kubernetes-metrics:ci ./docker
docker tag splunk/fluent-plugin-kubernetes-metrics:ci splunk/${DOCKERHUB_REPO_NAME}:${VERSION}
docker tag splunk/fluent-plugin-kubernetes-metrics:ci splunk/${DOCKERHUB_REPO_NAME}:latest
echo "Push docker image to splunk dockerhub..."
docker login --username=$DOCKERHUB_ACCOUNT_ID --password=$DOCKERHUB_ACCOUNT_PASS
docker push splunk/${DOCKERHUB_REPO_NAME}:${VERSION} | awk 'END{print}'
docker push splunk/${DOCKERHUB_REPO_NAME}:latest | awk 'END{print}'
echo "Docker image pushed successfully to docker-hub."