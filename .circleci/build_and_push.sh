#!/usr/bin/env bash
set -e
aws ecr get-login --region $AWS_REGION --no-include-email | bash
echo "Building docker image..."
cp /tmp/pkg/fluent-plugin-kubernetes-metrics-*.gem docker
echo "Copy latest fluent-plugin-splunk-hec gem from S3"
aws s3 cp s3://k8s-ci-artifacts/fluent-plugin-splunk-hec-${FLUENT_SPLUNK_HEC_GEM_VERSION}.gem ./docker
docker build --no-cache -t splunk/fluent-plugin-kubernetes-metrics:metrics ./docker
docker tag splunk/fluent-plugin-kubernetes-metrics:metrics $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/k8s-ci-metrics:latest
echo "Push docker image to ecr..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/k8s-ci-metrics:latest | awk 'END{print}'
echo "Docker image pushed successfully."