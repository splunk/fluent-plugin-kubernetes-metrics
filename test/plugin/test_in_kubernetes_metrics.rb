require "helper"
require "fluent/plugin/in_kubernetes_metrics.rb"

class KubernetesMetricsInputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  CONFIG = %[
      type kubernetes_metrics
      node_name generics-aws-node-name
      tag kube.*
      insecure_ssl true
      interval 10s
  ]

  setup do
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::KubernetesMetricsInput).configure(conf)
  end

  test 'configure' do
    assert_nothing_raised(Fluent::ConfigError) {
      create_driver(BASE_CONFIG)
    }

    assert_nothing_raised(Fluent::ConfigError) {
      create_driver(CONFIG)
    }

    d = create_driver
    assert_equal 'generics-aws-node-name', d.instance.node_name
    assert_equal 'kube.*', d.instance.tag
    assert_equal true, d.instance.insecure_ssl
    assert_equal 10, d.instance.interval
  end

end
