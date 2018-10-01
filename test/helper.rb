require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))
require "test-unit"
require "fluent/test"
require "fluent/test/driver/input"
require "fluent/test/helpers"
require "webmock/test_unit"

Test::Unit::TestCase.include(Fluent::Test::Helpers)
Test::Unit::TestCase.extend(Fluent::Test::Helpers)

module PluginTestHelper

  def k8s_host() "127.0.0.1" end
  def k8s_port() "8001" end
  def k8s_url(path='api') "https://#{k8s_host}:#{k8s_port}/#{path}" end

  def kubelet_summary_api_url() "http://generics-aws-node-name:10255/stats/summary" end
  def stub_k8s_requests
    # all stub response bodies are from real k8s 1.8 API calls
    stub_kubelet_summary_api
  end

  def stub_kubelet_summary_api
    open(File.expand_path('../unit.json', __FILE__)).tap { |f|
      stub_request(:get, "#{kubelet_summary_api_url}").to_return(body: f.read())
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