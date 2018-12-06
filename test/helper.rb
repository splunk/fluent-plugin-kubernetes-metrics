require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))
require "test-unit"
require "fluent/test"
require "fluent/test/driver/input"
require "fluent/test/helpers"
require "webmock/test_unit"

# require "minitest/autorun"
# require "webmock/minitest"

Test::Unit::TestCase.include(Fluent::Test::Helpers)
Test::Unit::TestCase.extend(Fluent::Test::Helpers)

#WebMock.allow_net_connect!

module PluginTestHelper

  def k8s_host() "generics-aws-node-name" end
  def k8s_port() "10255" end
  def k8s_url(path='api') "https://#{k8s_host}:#{k8s_port}/#{path}" end
  def kubelet_summary_api_url() "http://generics-aws-node-name:10255/stats/summary" end
  def kubelet_stats_api_url() "http://generics-aws-node-name:10255/stats/" end
  def kubelet_cadvisor_api_url() "http://generics-aws-node-name:10255/cadvisor/metrics" end

  def stub_k8s_requests
    ENV['KUBERNETES_SERVICE_HOST'] = k8s_host
    ENV['KUBERNETES_SERVICE_PORT'] = k8s_port
    # all stub response bodies are from real k8s 1.8 API calls
    stub_k8s_api
    stub_k8s_v1
    stub_kubelet_summary_api
    stub_k8s_proxy_summary_api
  end

  def stub_k8s_proxy_summary_api
    open(File.expand_path('../unit.json', __FILE__)).tap { |f|
      stub_request(:get, "#{k8s_url}/v1/nodes/generics-aws-node-name:10255/proxy/stats/summary")
        .to_return(body: f.read)
    }.close
  end

  def stub_k8s_api
    open(File.expand_path('../api.json', __FILE__)).tap { |f|
      stub_request(:get, k8s_url)
        .to_return(body: f.read)
    }.close
  end

  def stub_k8s_v1
    open(File.expand_path('../v1.json', __FILE__)).tap { |f|
      stub_request(:get, "#{k8s_url}/v1")
        .to_return(body: f.read)
    }.close
  end

  def stub_kubelet_summary_api
    open(File.expand_path('../unit.json', __FILE__)).tap { |f|
      stub_request(:get, "#{kubelet_summary_api_url}")
        .to_return(body: f.read())
    }.close
  end

  def stub_metrics_cadvisor
    open(File.expand_path('../metrics_cadvisor.json', __FILE__)).tap { |f|
      stub_request(:get, "#{kubelet_cadvisor_api_url}")
        .to_return(body: f.read())
    }.close
  end

  def stub_metrics_stats
    open(File.expand_path('../stats.json', __FILE__)).tap { |f|
      stub_request(:get, "#{kubelet_stats_api_url}")
          .to_return(body: f.read())
    }.close
  end

  def get_parsed_string
    parsed_string = nil
    open(File.expand_path('../unit.json', __FILE__)).tap { |f|
      parsed_string = f.read()
    }.close
    parsed_string
  end
end