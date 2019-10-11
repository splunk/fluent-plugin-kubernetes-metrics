#!/usr/bin/env bash
set -e
FLUENTD_HEC_GEM_VERSION=`cat docker/FLUENTD_HEC_GEM_VERSION`
aws ecr get-login --region $AWS_REGION --no-include-email | bash
echo "Building docker image..."
cp /tmp/pkg/fluent-plugin-kubernetes-metrics-*.gem docker
docker build --build-arg VERSION=$FLUENTD_HEC_GEM_VERSION --no-cache -t splunk/fluent-plugin-kubernetes-metrics:metrics ./docker
docker tag splunk/fluent-plugin-kubernetes-metrics:metrics $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/k8s-ci-metrics:latest
echo "Push docker image to ecr..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/k8s-ci-metrics:latest | awk 'END{print}'
echo "Docker image pushed successfully."