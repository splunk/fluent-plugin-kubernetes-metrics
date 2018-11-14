require "helper"
require "fluent/plugin/in_kubernetes_metrics.rb"

class KubernetesMetricsInputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers
  include PluginTestHelper

  @@driver = nil

  @@hash_map_test = Hash.new

  CONFIG = %[
      type kubernetes_metrics
      node_name generics-aws-node-name
      tag kube.*
      insecure_ssl true
      interval 10s
      use_rest_client true
  ]

  SUMMARY_CONFIG = %[
      type kubernetes_metrics
      node_names 'generics-aws-node-name'
      tag kube.*
      insecure_ssl true
      interval 10s
      use_rest_client false
  ]
  
  setup do
    Fluent::Test.setup

    @@parsed_string = JSON.parse(get_parsed_string)

    stub_k8s_requests

    @@driver = create_driver
    @@driver.run timeout:20,  expect_emits: 1, shutdown: true

    @@driver.events.each do |tag, time, record|
      @@hash_map_test[tag] = tag, time, record
    end


  end

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::KubernetesMetricsInput).configure(conf)
  end

  test 'configuration' do
    assert_nothing_raised(Fluent::ConfigError) {
      create_driver(CONFIG)
    }

    d = create_driver
    assert_equal 'generics-aws-node-name', d.instance.node_name
    assert_equal 'kube.*', d.instance.tag
    assert_equal true, d.instance.insecure_ssl
    assert_equal 10, d.instance.interval
    assert_equal true, d.instance.use_rest_client
  end

  sub_test_case "node_unit_tests" do

    test 'test_emit_cpu_metrics' do
      puts 'Test: test_emit_cpu_metrics'

      assert_not_nil @@hash_map_test.find('kube.node.cpu.usage')
      assert_equal @@parsed_string['node']['cpu']['usageNanoCores'], @@hash_map_test['kube.node.cpu.usage'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.cpu.usage_rate')
      assert_equal @@parsed_string['node']['cpu']['usageNanoCores']/ 1_000_000, @@hash_map_test['kube.node.cpu.usage_rate'][2]["value"]

    end

    test 'test_emit_memory_metrics' do
      puts 'Test: test_emit_memory_metrics'

      assert_not_nil @@hash_map_test.find('kube.node.memory.available_bytes')
      assert_equal @@parsed_string['node']['memory']['availableBytes'], @@hash_map_test['kube.node.memory.available_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.memory.usage_bytes')
      assert_equal @@parsed_string['node']['memory']['usageBytes'], @@hash_map_test['kube.node.memory.usage_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.memory.working_set_bytes')
      assert_equal @@parsed_string['node']['memory']['workingSetBytes'], @@hash_map_test['kube.node.memory.working_set_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.memory.rss_bytes')
      assert_equal @@parsed_string['node']['memory']['rssBytes'], @@hash_map_test['kube.node.memory.rss_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.memory.page_faults')
      assert_equal @@parsed_string['node']['memory']['pageFaults'], @@hash_map_test['kube.node.memory.page_faults'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.memory.major_page_faults')
      assert_equal @@parsed_string['node']['memory']['majorPageFaults'], @@hash_map_test['kube.node.memory.major_page_faults'][2]["value"]

    end

    test 'test_emit_network_metrics' do
      puts 'Test: test_emit_network_metrics'

      assert_not_nil @@hash_map_test.find('kube.node.network.rx_bytes')
      assert_equal @@parsed_string['node']['network']['rxBytes'], @@hash_map_test['kube.node.network.rx_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.network.rx_errors')
      assert_equal @@parsed_string['node']['network']['rxErrors'], @@hash_map_test['kube.node.network.rx_errors'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.network.tx_bytes')
      assert_equal @@parsed_string['node']['network']['txBytes'], @@hash_map_test['kube.node.network.tx_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.network.tx_errors')
      assert_equal @@parsed_string['node']['network']['txErrors'], @@hash_map_test['kube.node.network.tx_errors'][2]["value"]

    end

    test 'test_emit_fs_metrics' do
      puts 'Test: test_emit_fs_metrics'

      assert_not_nil @@hash_map_test.find('kube.node.fs.available_bytes')
      assert_equal @@parsed_string['node']['fs']['availableBytes'], @@hash_map_test['kube.node.fs.available_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.capacity_bytes')
      assert_equal @@parsed_string['node']['fs']['capacityBytes'], @@hash_map_test['kube.node.fs.capacity_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.used_bytes')
      assert_equal @@parsed_string['node']['fs']['usedBytes'], @@hash_map_test['kube.node.fs.used_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_free')
      assert_equal @@parsed_string['node']['fs']['inodesFree'], @@hash_map_test['kube.node.fs.inodes_free'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes')
      assert_equal @@parsed_string['node']['fs']['inodes'], @@hash_map_test['kube.node.fs.inodes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_used')
      assert_equal @@parsed_string['node']['fs']['inodesUsed'], @@hash_map_test['kube.node.fs.inodes_used'][2]["value"]

    end

    test 'test_emit_fs_imagefs_metrics' do
      puts 'Test: test_emit_fs_imagefs_metrics'

      assert_not_nil @@hash_map_test.find('kube.node.fs.available_bytes')
      assert_equal @@parsed_string['node']['runtime']['imageFs']['availableBytes'], @@hash_map_test['kube.node.imagefs.available_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.capacity_bytes')
      assert_equal @@parsed_string['node']['runtime']['imageFs']['capacityBytes'], @@hash_map_test['kube.node.imagefs.capacity_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.used_bytes')
      assert_equal @@parsed_string['node']['runtime']['imageFs']['usedBytes'], @@hash_map_test['kube.node.imagefs.used_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_free')
      assert_equal @@parsed_string['node']['runtime']['imageFs']['inodesFree'], @@hash_map_test['kube.node.imagefs.inodes_free'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes')
      assert_equal @@parsed_string['node']['runtime']['imageFs']['inodes'], @@hash_map_test['kube.node.imagefs.inodes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_used')
      assert_equal @@parsed_string['node']['runtime']['imageFs']['inodesUsed'], @@hash_map_test['kube.node.imagefs.inodes_used'][2]["value"]

    end

    test 'summary_api' do

      d = create_driver SUMMARY_CONFIG
      d.run timeout:20,  expect_emits: 1, shutdown: true
      events = d.events
      assert_not_nil events
    end

  end

end