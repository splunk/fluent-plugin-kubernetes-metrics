[![CircleCI](https://circleci.com/gh/git-lfs/git-lfs.svg?style=shield&circle-token=856152c2b02bfd236f54d21e1f581f3e4ebf47ad)](https://circleci.com/gh/splunk/fluent-plugin-kubernetes-metrics)
# Fluentd Plugin for Kubernetes Metrics

The [Fluentd](https://fluentd.org/) input plugin collects Kubernetes cluster metrics which are exposed by the [Kubelet API](https://kubernetes.io/docs/admin/kubelet/) and forwards them to fluentd.
The plugin collects metrics from:
   * The kubelet summary API
   * The kubelet stats API
   * The cAdvisor metrics API

The Fluentd input plugin can be configured to fetch metrics from the Kubernetes API server or from the Kubelet. 
For more details on the specific metrics that are collected and aggregated with this plugin, please refer to the 
[metrics information](https://github.com/splunk/fluent-plugin-kubernetes-metrics/blob/master/metrics-information.md) document.

## Installation

See: [Plugin Management](https://docs.fluentd.org/v1.0/articles/plugin-management).

### RubyGems

```
$ gem install fluent-plugin-kubernetes-metrics
```

### Bundler

Add the following line to your Gemfile:

```ruby
gem "fluent-plugin-kubernetes-metrics"
```

Then execute:

```
$ bundle
```

## Plugin helpers

* [timer](https://docs.fluentd.org/v1.0/articles/api-plugin-helper-timer)

* See also: [Input Plugin Overview](https://docs.fluentd.org/v1.0/articles/input-plugin-overview)

## Fluent::Plugin::KubernetesMetricsInput

### tag (string) (optional)

The tag for the event.

Default value: `kubernetes.metrics.*`.

### interval (time) (optional)

How often the plugin should pull metrcs.

Default value: `15s`.

### kubeconfig (string) (optional)

Path to a kubeconfig file that points to a cluster from which the plugin should collect metrics. Mostly useful when running fluentd outside of the cluster. When `kubeconfig` is set, `kubernetes_url`, `client_cert`, `client_key`, `ca_file`, `insecure_ssl`, `bearer_token_file`, and `secret_dir` are ignored.

### kubernetes_url (string) (optional)

URL of the kubernetes API server.

### client_cert (string) (optional)

Path to the certificate file for this client.

### client_key (string) (optional)

Path to the private key file for this client.

### ca_file (string) (optional)

Path to the CA file.

### insecure_ssl (bool) (optional)

If `insecure_ssl` is set to `true`, apiserver's certificate is not verified.

### bearer_token_file (string) (optional)

Path to the file that contains the API token. The default value is the file "token" in `secret_dir`.

### secret_dir (string) (optional)

Path of the location where the pod's service account credentials are stored.

Default value: `/var/run/secrets/kubernetes.io/serviceaccount`.

### node_name (string) (required)

The name of the node from which the plugin should collect metrics. This enables the plugin to fetch metrics from a kubelet API. Used only when the use_rest_client configuration parameter is enabled. 

### node_names Array(string) (required)

Array of the nodes from which the this plugin should collect metrics. This enables the plugin to fetch metrics from kubeapiserver. Used only when use_rest_client configuration parameter is not enabled. 

### kubelet_address (string) (optional)

The address that Kubelet is on. This can be a hostname or an IP address. If this is not provided, node_name is used to fetch metrics from the Kubelet API.

Default value: `nil`.

### kubelet_port (integer) (optional)

The port that kubelet is listening on.

Default value: `10250`.

### use_rest_client (bool) (optional)

Enable to use the rest client to get the metrics from summary api on each kubelet.

Default value: `true`.

### use_rest_client_ssl (bool) (optional)

Enable to use SSL for rest client.

Default value: `true`.

## License

See [License](LICENSE).
