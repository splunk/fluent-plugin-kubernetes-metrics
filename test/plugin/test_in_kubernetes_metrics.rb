require "helper"
require "fluent/plugin/in_kubernetes_metrics.rb"

class KubernetesMetricsInputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers
  include PluginTestHelper

  @@driver = nil

  @@hash_map_test = Hash.new
  @@hash_map_cadvisor = Hash.new

  CONFIG = %[
      type kubernetes_metrics
      node_name generics-aws-node-name
      tag kube.*
      insecure_ssl true
      interval 10s
      use_rest_client true
      use_rest_client_ssl false
      kubelet_port 10_255
  ]

  SUMMARY_CONFIG = %[
      type kubernetes_metrics
      node_names 'generics-aws-node-name'
      tag kube.*
      insecure_ssl true
      interval 10s
      use_rest_client false
      use_rest_client_ssl false
      kubelet_port 10_255
  ]
  
  setup do
    Fluent::Test.setup

    @@parsed_unit_string = JSON.parse(get_unit_parsed_string)
    @@parsed_string2 = JSON.parse(get_stats_parsed_string)

    get_cadvisor_parsed_string = nil
    open(File.expand_path('../../metrics_cadvisor.txt', __FILE__)).tap { |f|
      get_cadvisor_parsed_string = f.read()
    }.close

    stub_k8s_requests

    @@ca_driver = create_driver
    @@ca_driver.run timeout:20,  expect_emits: 1, shutdown: true

    @@driver = create_driver
    @@driver.run timeout:20,  expect_emits: 1, shutdown: true

    metrics = get_cadvisor_parsed_string.split("\n")
    for metric in metrics
      if metric.include? "container_name="
        if metric.match(/^((?!container_name="").)*$/) && metric[0] != '#'
          metric_str, metric_val =  metric.split(" ")
          first_occur = metric_str.index('{')
          metric_name = metric_str[0..first_occur-1]
          pod_name = metric.match(/pod_name="\S*"/).to_s
          pod_name = pod_name.split('"')[1]
          image_name = metric.match(/image="\S*"/).to_s
          image_name = image_name.split('"')[1]
          namespace = metric.match(/namespace="\S*"/).to_s
          namespace = namespace.split('"')[1]
          metric_labels = {'pod_name' => pod_name, 'image' => image_name, 'namespace' => namespace, 'value' => metric_val, 'node' => @node_name}
          if metric.match(/^((?!container_name="POD").)*$/)
            tag = 'pod'
            tag = generate_tag("#{tag}#{metric_name.gsub('_', '.')}", @@driver.instance.tag)
            tag = tag.gsub('container', '')
          else
            container_name = metric.match(/container_name="\S*"/).to_s
            container_name = container_name.split('"')[1]
            container_label = {'container_name' => container_name}
            metric_labels.merge(container_label)
            tag = generate_tag("#{metric_name.gsub('_', '.')}", @@driver.instance.tag)
          end
          @@hash_map_cadvisor[tag] = metric_labels["value"]
        end
      end
    end

    @@ca_driver.events.each do |tag, time, record|
      @@hash_map_cadvisor[tag] = tag, time, record
    end

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
      assert_equal @@parsed_unit_string['node']['cpu']['usageNanoCores'], @@hash_map_test['kube.node.cpu.usage'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.cpu.usage_rate')
      assert_equal @@parsed_unit_string['node']['cpu']['usageNanoCores']/ 1_000_000, @@hash_map_test['kube.node.cpu.usage_rate'][2]["value"]

    end

    test 'test_emit_memory_metrics' do
      puts 'Test: test_emit_memory_metrics'

      assert_not_nil @@hash_map_test.find('kube.node.memory.available_bytes')
      assert_equal @@parsed_unit_string['node']['memory']['availableBytes'], @@hash_map_test['kube.node.memory.available_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.memory.usage_bytes')
      assert_equal @@parsed_unit_string['node']['memory']['usageBytes'], @@hash_map_test['kube.node.memory.usage_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.memory.working_set_bytes')
      assert_equal @@parsed_unit_string['node']['memory']['workingSetBytes'], @@hash_map_test['kube.node.memory.working_set_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.memory.rss_bytes')
      assert_equal @@parsed_unit_string['node']['memory']['rssBytes'], @@hash_map_test['kube.node.memory.rss_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.memory.page_faults')
      assert_equal @@parsed_unit_string['node']['memory']['pageFaults'], @@hash_map_test['kube.node.memory.page_faults'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.memory.major_page_faults')
      assert_equal @@parsed_unit_string['node']['memory']['majorPageFaults'], @@hash_map_test['kube.node.memory.major_page_faults'][2]["value"]

    end

    test 'test_emit_network_metrics' do
      puts 'Test: test_emit_network_metrics'

      assert_not_nil @@hash_map_test.find('kube.node.network.rx_bytes')
      assert_equal @@parsed_unit_string['node']['network']['rxBytes'], @@hash_map_test['kube.node.network.rx_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.network.rx_errors')
      assert_equal @@parsed_unit_string['node']['network']['rxErrors'], @@hash_map_test['kube.node.network.rx_errors'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.network.tx_bytes')
      assert_equal @@parsed_unit_string['node']['network']['txBytes'], @@hash_map_test['kube.node.network.tx_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.network.tx_errors')
      assert_equal @@parsed_unit_string['node']['network']['txErrors'], @@hash_map_test['kube.node.network.tx_errors'][2]["value"]

    end

    test 'test_emit_fs_metrics' do
      puts 'Test: test_emit_fs_metrics'

      assert_not_nil @@hash_map_test.find('kube.node.fs.available_bytes')
      assert_equal @@parsed_unit_string['node']['fs']['availableBytes'], @@hash_map_test['kube.node.fs.available_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.capacity_bytes')
      assert_equal @@parsed_unit_string['node']['fs']['capacityBytes'], @@hash_map_test['kube.node.fs.capacity_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.used_bytes')
      assert_equal @@parsed_unit_string['node']['fs']['usedBytes'], @@hash_map_test['kube.node.fs.used_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_free')
      assert_equal @@parsed_unit_string['node']['fs']['inodesFree'], @@hash_map_test['kube.node.fs.inodes_free'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes')
      assert_equal @@parsed_unit_string['node']['fs']['inodes'], @@hash_map_test['kube.node.fs.inodes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_used')
      assert_equal @@parsed_unit_string['node']['fs']['inodesUsed'], @@hash_map_test['kube.node.fs.inodes_used'][2]["value"]

    end

    test 'test_emit_fs_imagefs_metrics' do
      puts 'Test: test_emit_fs_imagefs_metrics'

      assert_not_nil @@hash_map_test.find('kube.node.fs.available_bytes')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['availableBytes'], @@hash_map_test['kube.node.imagefs.available_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.capacity_bytes')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['capacityBytes'], @@hash_map_test['kube.node.imagefs.capacity_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.used_bytes')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['usedBytes'], @@hash_map_test['kube.node.imagefs.used_bytes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_free')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['inodesFree'], @@hash_map_test['kube.node.imagefs.inodes_free'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['inodes'], @@hash_map_test['kube.node.imagefs.inodes'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_used')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['inodesUsed'], @@hash_map_test['kube.node.imagefs.inodes_used'][2]["value"]

    end

    test 'summary_api' do

      d = create_driver SUMMARY_CONFIG
      d.run timeout:20,  expect_emits: 1, shutdown: true
      events = d.events
      assert_not_nil events
    end

  end

  sub_test_case "metrics_cadvisor_unit_tests" do

    test 'metrics cadvisor unit tests' do
      puts 'should be a string kubernetes.metrics.*'

      assert_not_nil @@hash_map_cadvisor.find('tag.string.default')
      assert_equal @@hash_map_cadvisor['tag']['string']['default'], @@NeedThisVal['tag']['string']['default']["kubernetes.metrics.*"]

    end
  end

  sub_test_case "node_stats_tests" do

    test 'test_stats_cpu_usage' do
      puts 'Test: test_stats_cpu_usage'

      # assert_not_nil @@hash_map_test.find('kube.container.cpu.usage')
      # assert_equal @@parsed_string2["stats"][0]["cpu"]["usage"]["total"], @@hash_map_test['kube.container.cpu.usage'][2]["value"]

      puts @@parsed_string2["stats"][0]["cpu"]["usage"]["total"].inspect

      # puts @@hash_map_test['kube.container.cpu.usage'][2]["value"].inspect

    end

  end

end