# Docker Image for Splunk Connect for Kubernetes
Fluentd with input plugin for k8s metrics
# To Build
`docker build --build-arg VERSION=$(cat VERSION) --no-cache -t splunk/splunk/k8s-metrics:local -f docker/Dockerfile .`