# Docker Image for Splunk Connect for Kubernetes
Fluentd with input plugin for k8s metrics
# To Build
`docker build --build-arg VERSION=$(cat VERSION) --no-cache -t splunk/fluent-plugin-kubernetes-metrics:ci ./docker`