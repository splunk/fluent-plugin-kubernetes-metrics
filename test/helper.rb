require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.expand_path('..', __dir__))
require 'test-unit'
require 'fluent/test'
require 'fluent/test/driver/input'
require 'fluent/test/helpers'
require 'webmock/test_unit'

# require "minitest/autorun"
# require "webmock/minitest"

Test::Unit::TestCase.include(Fluent::Test::Helpers)
Test::Unit::TestCase.extend(Fluent::Test::Helpers)

# WebMock.allow_net_connect!

module PluginTestHelper
  def k8s_host
    'generics-aws-node-name'
  end

  def k8s_port
    '10255'
  end

  def k8s_url(path = 'api')
    "https://#{k8s_host}:#{k8s_port}/#{path}"
  end

  def kubelet_summary_api_url
    'http://generics-aws-node-name:10255/stats/summary'
  end

  def kubelet_stats_api_url
    'http://generics-aws-node-name:10255/stats'
  end

  def kubelet_cadvisor_api_url
    'http://generics-aws-node-name:10255/metrics/cadvisor'
  end

  def stub_k8s_requests
    ENV['KUBERNETES_SERVICE_HOST'] = k8s_host
    ENV['KUBERNETES_SERVICE_PORT'] = k8s_port
    # all stub response bodies are from real k8s 1.8 API calls
    stub_k8s_api
    stub_k8s_v1
    stub_kubelet_summary_api
    stub_k8s_proxy_summary_api
    stub_metrics_cadvisor
    stub_k8s_proxy_cadvisor_api
    stub_metrics_stats
    stub_metrics_proxy_stats
  end

  def stub_k8s_proxy_summary_api
    open(File.expand_path('unit.json', __dir__)).tap do |f|
      stub_request(:get, "#{k8s_url}/v1/nodes/generics-aws-node-name:10255/proxy/stats/summary")
        .to_return(body: f.read)
    end.close
  end

  def stub_k8s_api
    open(File.expand_path('api.json', __dir__)).tap do |f|
      stub_request(:get, k8s_url)
        .to_return(body: f.read)
    end.close
  end

  def stub_k8s_v1
    open(File.expand_path('v1.json', __dir__)).tap do |f|
      stub_request(:get, "#{k8s_url}/v1")
        .to_return(body: f.read)
    end.close
  end

  def stub_kubelet_summary_api
    open(File.expand_path('unit.json', __dir__)).tap do |f|
      stub_request(:get, kubelet_summary_api_url.to_s)
        .to_return(body: f.read)
    end.close
  end

  def stub_kubelet_summary_api_missing_timestamps
    open(File.expand_path('unit_without_time.json', __dir__)).tap do |f|
      stub_request(:get, kubelet_summary_api_url.to_s)
        .to_return(body: f.read)
    end.close
  end

  def stub_metrics_cadvisor
    open(File.expand_path('metrics_cadvisor.txt', __dir__)).tap do |f|
      stub_request(:get, kubelet_cadvisor_api_url.to_s)
        .to_return(body: f.read)
    end.close
  end

  def stub_k8s_proxy_cadvisor_api
    open(File.expand_path('metrics_cadvisor.txt', __dir__)).tap do |f|
      stub_request(:get, "#{k8s_url}/v1/nodes/generics-aws-node-name:10255/proxy/metrics/cadvisor")
        .to_return(body: f.read)
    end.close
  end

  def stub_metrics_stats
    open(File.expand_path('stats.json', __dir__)).tap do |f|
      stub_request(:get, kubelet_stats_api_url.to_s)
        .to_return(body: f.read)
    end.close
  end

  def stub_metrics_proxy_stats
    open(File.expand_path('stats.json', __dir__)).tap do |f|
      stub_request(:get, "#{k8s_url}/v1/nodes/generics-aws-node-name:10255/proxy/stats")
        .to_return(body: f.read)
    end.close
  end

  def get_unit_parsed_string
    parsed_string = nil
    open(File.expand_path('unit.json', __dir__)).tap do |f|
      parsed_string = f.read
    end.close
    parsed_string
  end

  def get_unit_parsed_string_missing_timestamps
    parsed_string = nil
    open(File.expand_path('unit_without_time.json', __dir__)).tap do |f|
      parsed_string = f.read
    end.close
    parsed_string
  end

  def get_stats_parsed_string
    get_stats_parsed_string = nil
    open(File.expand_path('stats.json', __dir__)).tap do |f|
      get_stats_parsed_string = f.read
    end.close
    get_stats_parsed_string
  end

  def generate_tag(item_name, tag)
    tag_prefix, tag_suffix = tag.split('*') if tag.include?('*')
    return tag unless tag_prefix

    [tag_prefix, item_name, tag_suffix].join
  end
end
