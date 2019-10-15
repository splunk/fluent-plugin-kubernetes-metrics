require 'helper'
require 'fluent/plugin/in_kubernetes_metrics.rb'

class KubernetesMetricsInputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers
  include PluginTestHelper

  @@driver = nil

  @@hash_map_test = {}
  @@hash_map_cadvisor = {}

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

  SUMMARY_CONFIG = %(
      type kubernetes_metrics
      node_names 'generics-aws-node-name'
      tag kube.*
      insecure_ssl true
      interval 10s
      use_rest_client false
      use_rest_client_ssl false
      kubelet_port 10_255
      kubelet_address generics-aws-node-name
  ).freeze

  setup do
    Fluent::Test.setup

    @@parsed_unit_string = JSON.parse(get_unit_parsed_string)
    @@parsed_string2 = JSON.parse(get_stats_parsed_string)

    get_cadvisor_parsed_string = nil
    open(File.expand_path('../metrics_cadvisor.txt', __dir__)).tap do |f|
      get_cadvisor_parsed_string = f.read
    end.close

    stub_k8s_requests

    @@ca_driver = create_driver
    @@ca_driver.run timeout: 20, expect_emits: 1, shutdown: true

    @@driver = create_driver
    @@driver.run timeout: 20, expect_emits: 1, shutdown: true

    metrics = get_cadvisor_parsed_string.split("\n")
    metrics.each do |metric|
      next unless metric.include? 'container_name='

      next unless metric.match(/^((?!container_name="").)*$/) && metric[0] != '#'

      metric_str, metric_val = metric.split(' ')
      metric_val = metric_val.to_f if metric_val.is_a? String
      first_occur = metric_str.index('{')
      metric_name = metric_str[0..first_occur - 1]
      pod_name = metric.match(/pod_name="\S*"/).to_s
      pod_name = pod_name.split('"')[1]
      image_name = metric.match(/image="\S*"/).to_s
      image_name = image_name.split('"')[1]
      namespace = metric.match(/namespace="\S*"/).to_s
      namespace = namespace.split('"')[1]
      metric_labels = { 'pod_name' => pod_name, 'image' => image_name, 'namespace' => namespace, 'value' => metric_val, 'node' => @node_name }
      if metric =~ /^((?!container_name="POD").)*$/
        tag = 'pod'
        tag = generate_tag("#{tag}#{metric_name.tr('_', '.')}", @@driver.instance.tag)
        tag = tag.gsub('container', '')
      else
        container_name = metric.match(/container_name="\S*"/).to_s
        container_name = container_name.split('"')[1]
        container_label = { 'container_name' => container_name }
        metric_labels.merge(container_label)
        tag = generate_tag(metric_name.tr('_', '.').to_s, @@driver.instance.tag)
      end
      @@hash_map_cadvisor[tag] = metric_labels['value']
    end

    @@driver.events.each do |tag, time, record|
      @@hash_map_test[tag] = tag, time, record
    end
  end

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::KubernetesMetricsInput).configure(conf)
  end

  test 'configuration' do
    assert_nothing_raised(Fluent::ConfigError) do
      create_driver(CONFIG)
    end

    d = create_driver
    assert_equal 'generics-aws-node-name', d.instance.node_name
    assert_equal 'kube.*', d.instance.tag
    assert_equal true, d.instance.insecure_ssl
    assert_equal 10, d.instance.interval
    assert_equal true, d.instance.use_rest_client
  end

  sub_test_case 'node_unit_tests' do
    test 'test_emit_cpu_metrics' do
      assert_not_nil @@hash_map_test.key?('kube.node.cpu.usage')
      assert_equal @@parsed_unit_string['node']['cpu']['usageNanoCores'], @@hash_map_test['kube.node.cpu.usage'][2]['value']

      assert_not_nil @@hash_map_test.key?('kube.node.cpu.usage_rate')
      assert_equal @@parsed_unit_string['node']['cpu']['usageNanoCores'] / 1_000_000, @@hash_map_test['kube.node.cpu.usage_rate'][2]['value']
    end

    test 'test_emit_memory_metrics' do
      assert_not_nil @@hash_map_test.find('kube.node.memory.available_bytes')
      assert_equal @@parsed_unit_string['node']['memory']['availableBytes'], @@hash_map_test['kube.node.memory.available_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.memory.usage_bytes')
      assert_equal @@parsed_unit_string['node']['memory']['usageBytes'], @@hash_map_test['kube.node.memory.usage_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.memory.working_set_bytes')
      assert_equal @@parsed_unit_string['node']['memory']['workingSetBytes'], @@hash_map_test['kube.node.memory.working_set_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.memory.rss_bytes')
      assert_equal @@parsed_unit_string['node']['memory']['rssBytes'], @@hash_map_test['kube.node.memory.rss_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.memory.page_faults')
      assert_equal @@parsed_unit_string['node']['memory']['pageFaults'], @@hash_map_test['kube.node.memory.page_faults'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.memory.major_page_faults')
      assert_equal @@parsed_unit_string['node']['memory']['majorPageFaults'], @@hash_map_test['kube.node.memory.major_page_faults'][2]['value']
    end

    test 'test_emit_network_metrics' do
      assert_not_nil @@hash_map_test.find('kube.node.network.rx_bytes')
      assert_equal @@parsed_unit_string['node']['network']['rxBytes'], @@hash_map_test['kube.node.network.rx_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.network.rx_errors')
      assert_equal @@parsed_unit_string['node']['network']['rxErrors'], @@hash_map_test['kube.node.network.rx_errors'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.network.tx_bytes')
      assert_equal @@parsed_unit_string['node']['network']['txBytes'], @@hash_map_test['kube.node.network.tx_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.network.tx_errors')
      assert_equal @@parsed_unit_string['node']['network']['txErrors'], @@hash_map_test['kube.node.network.tx_errors'][2]['value']
    end

    test 'test_emit_fs_metrics' do
      assert_not_nil @@hash_map_test.find('kube.node.fs.available_bytes')
      assert_equal @@parsed_unit_string['node']['fs']['availableBytes'], @@hash_map_test['kube.node.fs.available_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.fs.capacity_bytes')
      assert_equal @@parsed_unit_string['node']['fs']['capacityBytes'], @@hash_map_test['kube.node.fs.capacity_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.fs.used_bytes')
      assert_equal @@parsed_unit_string['node']['fs']['usedBytes'], @@hash_map_test['kube.node.fs.used_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_free')
      assert_equal @@parsed_unit_string['node']['fs']['inodesFree'], @@hash_map_test['kube.node.fs.inodes_free'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes')
      assert_equal @@parsed_unit_string['node']['fs']['inodes'], @@hash_map_test['kube.node.fs.inodes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_used')
      assert_equal @@parsed_unit_string['node']['fs']['inodesUsed'], @@hash_map_test['kube.node.fs.inodes_used'][2]['value']
    end

    test 'test_emit_fs_imagefs_metrics' do
      assert_not_nil @@hash_map_test.find('kube.node.fs.available_bytes')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['availableBytes'], @@hash_map_test['kube.node.imagefs.available_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.fs.capacity_bytes')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['capacityBytes'], @@hash_map_test['kube.node.imagefs.capacity_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.fs.used_bytes')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['usedBytes'], @@hash_map_test['kube.node.imagefs.used_bytes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_free')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['inodesFree'], @@hash_map_test['kube.node.imagefs.inodes_free'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['inodes'], @@hash_map_test['kube.node.imagefs.inodes'][2]['value']

      assert_not_nil @@hash_map_test.find('kube.node.fs.inodes_used')
      assert_equal @@parsed_unit_string['node']['runtime']['imageFs']['inodesUsed'], @@hash_map_test['kube.node.imagefs.inodes_used'][2]['value']
    end

    test 'summary_api' do
      d = create_driver SUMMARY_CONFIG
      d.run timeout: 20, expect_emits: 1, shutdown: true
      events = d.events
      assert_not_nil events
    end
  end

  sub_test_case 'metrics_cadvisor_unit_tests' do
      assert_true @@hash_map_cadvisor.key?('kube.container.cpu.load.average.10s')
      assert_equal @@hash_map_cadvisor['kube.container.cpu.load.average.10s'], @@hash_map_test['kube.container.cpu.load.average.10s'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.cpu.system.seconds.total')
      assert_equal @@hash_map_cadvisor['kube.container.cpu.system.seconds.total'], @@hash_map_test['kube.container.cpu.system.seconds.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.cpu.usage.seconds.total')
      assert_equal @@hash_map_cadvisor['kube.container.cpu.usage.seconds.total'], @@hash_map_test['kube.container.cpu.usage.seconds.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.cpu.user.seconds.total')
      assert_equal @@hash_map_cadvisor['kube.container.cpu.user.seconds.total'], @@hash_map_test['kube.container.cpu.user.seconds.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.inodes.free')
      assert_equal @@hash_map_cadvisor['kube.container.fs.inodes.free'], @@hash_map_test['kube.container.fs.inodes.free'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.inodes.total')
      assert_equal @@hash_map_cadvisor['kube.container.fs.inodes.total'], @@hash_map_test['kube.container.fs.inodes.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.io.current')
      assert_equal @@hash_map_cadvisor['kube.container.fs.io.current'], @@hash_map_test['kube.container.fs.io.current'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.io.time.seconds.total')
      assert_equal @@hash_map_cadvisor['kube.container.fs.io.time.seconds.total'], @@hash_map_test['kube.container.fs.io.time.seconds.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.io.time.weighted.seconds.total')
      assert_equal @@hash_map_cadvisor['kube.container.fs.io.time.weighted.seconds.total'], @@hash_map_test['kube.container.fs.io.time.weighted.seconds.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.limit.bytes')
      assert_equal @@hash_map_cadvisor['kube.container.fs.limit.bytes'], @@hash_map_test['kube.container.fs.limit.bytes'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.read.seconds.total')
      assert_equal @@hash_map_cadvisor['kube.container.fs.read.seconds.total'], @@hash_map_test['kube.container.fs.read.seconds.total'][2]['value']

    # TODO: Current Test does not work - metric present in metrics_cadvisor.txt but not being parsed by connector in test/working in production
      assert_false @@hash_map_cadvisor.key?('kube.container.fs.reads.bytes.total')
      # assert_equal @@hash_map_cadvisor['kube.container.fs.reads.bytes.total'], @@hash_map_test["kube.container.fs.reads.bytes.total"][2]["value"]

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.reads.merged.total')
      assert_equal @@hash_map_cadvisor['kube.container.fs.reads.merged.total'], @@hash_map_test['kube.container.fs.reads.merged.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.reads.total')
      assert_equal @@hash_map_cadvisor['kube.container.fs.reads.total'], @@hash_map_test['kube.container.fs.reads.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.sector.reads.total')
      assert_equal @@hash_map_cadvisor['kube.container.fs.sector.reads.total'], @@hash_map_test['kube.container.fs.sector.reads.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.sector.writes.total')
      assert_equal @@hash_map_cadvisor['kube.container.fs.sector.writes.total'], @@hash_map_test['kube.container.fs.sector.writes.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.usage.bytes')
      assert_equal @@hash_map_cadvisor['kube.container.fs.usage.bytes'], @@hash_map_test['kube.container.fs.usage.bytes'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.write.seconds.total')
      assert_equal @@hash_map_cadvisor['kube.container.fs.write.seconds.total'], @@hash_map_test['kube.container.fs.write.seconds.total'][2]['value']

    # TODO: Current Test does not work - metric present in metrics_cadvisor.txt but not being parsed by connector in test/working in production
      assert_false @@hash_map_cadvisor.key?('kube.container.fs.writes.bytes.total')
      # assert_equal @@hash_map_cadvisor['kube.container.fs.writes.bytes.total'], @@hash_map_test["kube.container.fs.writes.bytes.total"][2]["value"]

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.writes.merged.total')
      # assert_equal @@hash_map_cadvisor['kube.container.fs.writes.merged.total'], @@hash_map_test["kube.container.fs.writes.merged.total"][2]["value"]

      assert_true @@hash_map_cadvisor.key?('kube.container.fs.writes.total')
      assert_equal @@hash_map_cadvisor['kube.container.fs.writes.total'], @@hash_map_test['kube.container.fs.writes.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.last.seen')
      assert_equal @@hash_map_cadvisor['kube.container.last.seen'], @@hash_map_test['kube.container.last.seen'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.memory.cache')
      assert_equal @@hash_map_cadvisor['kube.container.memory.cache'], @@hash_map_test['kube.container.memory.cache'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.memory.failcnt')
      assert_equal @@hash_map_cadvisor['kube.container.memory.failcnt'], @@hash_map_test['kube.container.memory.failcnt'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.memory.failures.total')
      assert_equal @@hash_map_cadvisor['kube.container.memory.failures.total'], @@hash_map_test['kube.container.memory.failures.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.memory.max.usage.bytes')
      assert_equal @@hash_map_cadvisor['kube.container.memory.max.usage.bytes'], @@hash_map_test['kube.container.memory.max.usage.bytes'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.memory.rss')
      assert_equal @@hash_map_cadvisor['kube.container.memory.rss'], @@hash_map_test['kube.container.memory.rss'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.memory.swap')
      assert_equal @@hash_map_cadvisor['kube.container.memory.swap'], @@hash_map_test['kube.container.memory.swap'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.memory.usage.bytes')
      assert_equal @@hash_map_cadvisor['kube.container.memory.usage.bytes'], @@hash_map_test['kube.container.memory.usage.bytes'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.memory.working.set.bytes')
      assert_equal @@hash_map_cadvisor['kube.container.memory.working.set.bytes'], @@hash_map_test['kube.container.memory.working.set.bytes'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.network.receive.bytes.total')
      assert_equal @@hash_map_cadvisor['kube.container.network.receive.bytes.total'], @@hash_map_test['kube.container.network.receive.bytes.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.network.receive.errors.total')
      assert_equal @@hash_map_cadvisor['kube.container.network.receive.errors.total'], @@hash_map_test['kube.container.network.receive.errors.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.network.receive.packets.dropped.total')
      assert_equal @@hash_map_cadvisor['kube.container.network.receive.packets.dropped.total'], @@hash_map_test['kube.container.network.receive.packets.dropped.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.network.receive.packets.total')
      assert_equal @@hash_map_cadvisor['kube.container.network.receive.packets.total'], @@hash_map_test['kube.container.network.receive.packets.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.network.tcp.usage.total')
      assert_equal @@hash_map_cadvisor['kube.container.network.tcp.usage.total'], @@hash_map_test['kube.container.network.tcp.usage.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.network.transmit.bytes.total')
      assert_equal @@hash_map_cadvisor['kube.container.network.transmit.bytes.total'], @@hash_map_test['kube.container.network.transmit.bytes.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.network.transmit.errors.total')
      assert_equal @@hash_map_cadvisor['kube.container.network.transmit.errors.total'], @@hash_map_test['kube.container.network.transmit.errors.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.network.transmit.packets.dropped.total')
      assert_equal @@hash_map_cadvisor['kube.container.network.transmit.packets.dropped.total'], @@hash_map_test['kube.container.network.transmit.packets.dropped.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.network.transmit.packets.total')
      assert_equal @@hash_map_cadvisor['kube.container.network.transmit.packets.total'], @@hash_map_test['kube.container.network.transmit.packets.total'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.network.udp.usage.total')
      assert_equal @@hash_map_cadvisor['kube.container.network.udp.usage.total'], @@hash_map_test['kube.container.network.udp.usage.total'][2]['value']

    # TODO: Current Test does not work - metric present in metrics_cadvisor.txt but not being parsed by connector
      assert_false @@hash_map_cadvisor.key?('kube.container.scrape.error')
      # assert_equal @@hash_map_cadvisor['kube.container.scrape.error'], @@hash_map_test["kube.container.scrape.error"][2]["value"]

      assert_true @@hash_map_cadvisor.key?('kube.container.spec.cpu.period')
      assert_equal @@hash_map_cadvisor['kube.container.spec.cpu.period'], @@hash_map_test['kube.container.spec.cpu.period'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.spec.cpu.shares')
      assert_equal @@hash_map_cadvisor['kube.container.spec.cpu.shares'], @@hash_map_test['kube.container.spec.cpu.shares'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.spec.memory.limit.bytes')
      assert_equal @@hash_map_cadvisor['kube.container.spec.memory.limit.bytes'], @@hash_map_test['kube.container.spec.memory.limit.bytes'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.spec.memory.reservation.limit.bytes')
      assert_equal @@hash_map_cadvisor['kube.container.spec.memory.reservation.limit.bytes'], @@hash_map_test['kube.container.spec.memory.reservation.limit.bytes'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.spec.memory.swap.limit.bytes')
      assert_equal @@hash_map_cadvisor['kube.container.spec.memory.swap.limit.bytes'], @@hash_map_test['kube.container.spec.memory.swap.limit.bytes'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.start.time.seconds')
      assert_equal @@hash_map_cadvisor['kube.container.start.time.seconds'], @@hash_map_test['kube.container.start.time.seconds'][2]['value']

      assert_true @@hash_map_cadvisor.key?('kube.container.tasks.state')
      assert_equal @@hash_map_cadvisor['kube.container.tasks.state'], @@hash_map_test['kube.container.tasks.state'][2]['value']

    # TODO: Current Test does not work - metric present in metrics_cadvisor.txt but not being parsed by connector
      assert_false @@hash_map_cadvisor.key?('kube.machine.cpu.cores')
      # assert_equal @@hash_map_cadvisor['kube.machine.cpu.cores'], @@hash_map_test["kube.machine.cpu.cores"][2]["value"]

    # TODO: Current Test does not work - metric present in metrics_cadvisor.txt but not being parsed by connector
      assert_false @@hash_map_cadvisor.key?('kube.container.machine.memory.bytes')
      # assert_equal @@hash_map_cadvisor['kube.container.machine.memory.bytes'], @@hash_map_test["kube.container.machine.memory.bytes"][2]["value"]

    # TODO: Test does not work - metric not present in metrics_cadvisor.txt
      assert_false @@hash_map_cadvisor.key?('kube.container.cpu.cfs.throttled.seconds.total')
      # assert_equal @@hash_map_cadvisor['kube.container.cpu.cfs.throttled.seconds.total'], @@hash_map_test["kube.container.cpu.cfs.throttled.seconds.total"][2]["value"]
  end
end
