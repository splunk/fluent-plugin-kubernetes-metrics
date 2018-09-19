# fluent-plugin-kubernetes-metrics

[Fluentd](https://fluentd.org/) input plugin to collect kubernetes cluster metrics from the Summary API, exposed by [Kubelet](https://kubernetes.io/docs/admin/kubelet/) on each node.

## Installation

See also: [Plugin Management](https://docs.fluentd.org/v1.0/articles/plugin-management).

### RubyGems

```
$ gem install fluent-plugin-kubernetes-metrics
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-kubernetes-metrics"
```

And then execute:

```
$ bundle
```

## Plugin helpers

* [timer](https://docs.fluentd.org/v1.0/articles/api-plugin-helper-timer)

* See also: [Input Plugin Overview](https://docs.fluentd.org/v1.0/articles/input-plugin-overview)

## Fluent::Plugin::KubernetesMetricsInput

### tag (string) (optional)

The tag of the event.

Default value: `kubernetes.metrics.*`.

### interval (time) (optional)

How often it pulls metrcs.

Default value: `15s`.

### kubeconfig (string) (required)

Path to a kubeconfig file points to a cluster the plugin should collect metrics from. Mostly useful when running fluentd outside of the cluster. When `kubeconfig` is set, `kubernetes_url`, `client_cert`, `client_key`, `ca_file`, `insecure_ssl`, `bearer_token_file`, and `secret_dir` will all be ignored.

### kubernetes_url (string) (optional)

URL of the kubernetes API server.

### client_cert (string) (optional)

Path to the certificate file for this client.

### client_key (string) (optional)

Path to the private key file for this client.

### ca_file (string) (optional)

Path to the CA file.

### insecure_ssl (bool) (optional)

If `insecure_ssl` is set to `true`, it won't verify apiserver's certificate.

### bearer_token_file (string) (optional)

Path to the file contains the API token. By default it reads from the file "token" in the `secret_dir`.

### secret_dir (string) (optional)

Path of the location where pod's service account's credentials are stored.

Default value: `/var/run/secrets/kubernetes.io/serviceaccount`.

### node_name (string) (required)

Name of the node that this plugin should collect metrics from.

### kubelet_port (integer) (optional)

The port that kubelet is listening to.

Default value: `10255`.

## License

See [License](LICENSE).
