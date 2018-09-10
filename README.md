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

`*` can be used as a placeholder that expands to the actual metric name. For example, with the default tag value `kubernetes.metrics.*`, it will emit node cpu usage metric with tag `kubernetes.metrics.node.cpu.usage`.

Default value: `kubernetes.metrics.*`.

### interval (time) (optional)

How often it pulls metrcs.

Default value: `15s`.

### kubeconfig (string) (required)

Path to a kubeconfig file points to a cluster the plugin should collect metrics from. Mostly useful when running fluentd outside of the cluster.

### node_name (string) (required)

Name of the node that this plugin should collect metrics from.

### kubelet_port (integer) (optional)

The port that kubelet is listening to.

Default value: `10255`.

## License

See [License](LICENSE).
