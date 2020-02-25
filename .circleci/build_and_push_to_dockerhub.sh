#!/usr/bin/env bash
set -e
echo "Building docker image..."
cp /tmp/pkg/fluent-plugin-kubernetes-metrics-*.gem docker
VERSION=`cat VERSION`
echo "Copying licenses to be included in the docker image..."
mkdir docker/licenses
cp -rp LICENSE docker/licenses/
docker build --build-arg VERSION=$VERSION --no-cache -t splunk/fluent-plugin-kubernetes-metrics:ci ./docker
docker tag splunk/fluent-plugin-kubernetes-metrics:ci splunk/${DOCKERHUB_REPO_NAME}:${VERSION}
docker tag splunk/fluent-plugin-kubernetes-metrics:ci splunk/${DOCKERHUB_REPO_NAME}:latest
echo "Push docker image to splunk dockerhub..."
docker login --username=$DOCKERHUB_ACCOUNT_ID --password=$DOCKERHUB_ACCOUNT_PASS
docker push splunk/${DOCKERHUB_REPO_NAME}:${VERSION} | awk 'END{print}'
docker push splunk/${DOCKERHUB_REPO_NAME}:latest | awk 'END{print}'
echo "Docker image pushed successfully to docker-hub."