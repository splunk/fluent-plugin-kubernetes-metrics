require 'helper'
require 'fluent/plugin/in_kubernetes_metrics.rb'

class KubernetesMetricsInputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers
  include PluginTestHelper

  @@driver = nil
  
  CONFIG = %(
      type kubernetes_metrics
      node_name generics-aws-node-name
      tag kube.*
      insecure_ssl true
      interval 10s
      use_rest_client true
      use_rest_client_ssl false
      kubelet_port 10_255
      kubelet_address generics-aws-node-name
  ).freeze

  setup do
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::KubernetesMetricsInput).configure(conf)
  end

  test 'timestamps_missing' do
    @@parsed_unit_string = JSON.parse(get_unit_parsed_string_missing_timestamps)
    ENV['KUBERNETES_SERVICE_HOST'] = k8s_host
    ENV['KUBERNETES_SERVICE_PORT'] = k8s_port
    # all stub response bodies are from real k8s 1.8 API calls
    stub_k8s_api
    stub_kubelet_summary_api_missing_timestamps
    stub_k8s_v1
    stub_kubelet_summary_api_missing_timestamps
    stub_metrics_cadvisor
    stub_metrics_stats
    @@driver = create_driver
    @@driver.run timeout: 20, expect_emits: 1, shutdown: true
  end
end
