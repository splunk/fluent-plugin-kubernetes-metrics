#!/usr/bin/env bash
set -e

VERSION=`cat VERSION`
docker build --build-arg VERSION=$VERSION --no-cache -t splunk/fluent-plugin-kubernetes-metrics:ci -f docker/Dockerfile .
docker tag splunk/fluent-plugin-kubernetes-metrics:ci splunk/${DOCKERHUB_REPO_NAME}:${VERSION}
docker tag splunk/fluent-plugin-kubernetes-metrics:ci splunk/${DOCKERHUB_REPO_NAME}:latest
echo "Push docker image to splunk dockerhub..."
docker login --username=$DOCKERHUB_ACCOUNT_ID --password=$DOCKERHUB_ACCOUNT_PASS
docker push splunk/${DOCKERHUB_REPO_NAME}:${VERSION} | awk 'END{print}'
docker push splunk/${DOCKERHUB_REPO_NAME}:latest | awk 'END{print}'
echo "Docker image pushed successfully to docker-hub."