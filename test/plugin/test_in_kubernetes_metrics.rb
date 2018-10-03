require "helper"
require "fluent/plugin/in_kubernetes_metrics.rb"

class KubernetesMetricsInputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

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
  
  setup do
    Fluent::Test.setup
    node_string = '{
                     "node": {
                      "nodeName": "ip-XXX-XX-XX-XXX.us-west-2.compute.internal",
                      "startTime": "2018-09-19T06:40:05Z",
                      "cpu": {
                       "time": "2018-09-27T22:09:59Z",
                       "usageNanoCores": 71501818,
                       "usageCoreNanoSeconds": 68824254091816
                      },
                      "memory": {
                       "time": "2018-09-27T22:09:59Z",
                       "availableBytes": 30164504576,
                       "usageBytes": 10132713472,
                       "workingSetBytes": 3576983552,
                       "rssBytes": 517582848,
                       "pageFaults": 498847843,
                       "majorPageFaults": 1999
                      },
                      "network": {
                       "time": "2018-09-27T22:09:59Z",
                       "name": "eth0",
                       "rxBytes": 8480164820,
                       "rxErrors": 0,
                       "txBytes": 5416875722,
                       "txErrors": 0,
                       "interfaces": [
                        {
                         "name": "cbr0",
                         "rxBytes": 4677862821,
                         "rxErrors": 0,
                         "txBytes": 5067375443,
                         "txErrors": 0
                        },
                        {
                         "name": "eth0",
                         "rxBytes": 8480164820,
                         "rxErrors": 0,
                         "txBytes": 5416875722,
                         "txErrors": 0
                        }
                       ]
                      },
                      "fs": {
                       "time": "2018-09-27T22:09:59Z",
                       "availableBytes": 112741339136,
                       "capacityBytes": 128701009920,
                       "usedBytes": 10359861248,
                       "inodesFree": 33124287,
                       "inodes": 33554432,
                       "inodesUsed": 430145
                      },
                      "runtime": {
                       "imageFs": {
                        "time": "2018-09-27T22:09:59Z",
                        "availableBytes": 112741339136,
                        "capacityBytes": 128701009920,
                        "usedBytes": 6439798904,
                        "inodesFree": 33124287,
                        "inodes": 33554432,
                        "inodesUsed": 430145
                       }
                      }
                     },
                     "pods": [
                      {
                       "podRef": {
                        "name": "kube-system-logging-splunk-kubernetes-logging-4kbsb",
                        "namespace": "generic_namespace",
                        "uid": "6a83cdc1-c055-11e8-bbee-02dfc7c54d24"
                       },
                       "startTime": "2018-09-24T23:56:13Z",
                       "containers": [
                        {
                         "name": "splunk-fluentd-k8s-logs",
                         "startTime": "2018-09-24T23:56:14Z",
                         "cpu": {
                          "time": "2018-09-27T22:10:03Z",
                          "usageNanoCores": 3117227,
                          "usageCoreNanoSeconds": 856491349907
                         },
                         "memory": {
                          "time": "2018-09-27T22:10:03Z",
                          "usageBytes": 71749632,
                          "workingSetBytes": 71749632,
                          "rssBytes": 71430144,
                          "pageFaults": 204802,
                          "majorPageFaults": 0
                         },
                         "rootfs": {
                          "time": "2018-09-27T22:10:03Z",
                          "availableBytes": 112741339136,
                          "capacityBytes": 128701009920,
                          "usedBytes": 263282688,
                          "inodesFree": 33124287,
                          "inodes": 33554432,
                          "inodesUsed": 32
                         },
                         "logs": {
                          "time": "2018-09-27T22:10:03Z",
                          "availableBytes": 112741339136,
                          "capacityBytes": 128701009920,
                          "usedBytes": 61440,
                          "inodesFree": 33124287,
                          "inodes": 33554432,
                          "inodesUsed": 430145
                         },
                         "userDefinedMetrics": null
                        }
                       ],
                       "cpu": {
                        "time": "2018-09-27T22:10:02Z",
                        "usageNanoCores": 3126718,
                        "usageCoreNanoSeconds": 856492340119
                       },
                       "memory": {
                        "time": "2018-09-27T22:10:02Z",
                        "usageBytes": 71917568,
                        "workingSetBytes": 71917568,
                        "rssBytes": 71471104,
                        "pageFaults": 0,
                        "majorPageFaults": 0
                       },
                       "network": {
                        "time": "2018-09-27T22:10:02Z",
                        "name": "eth0",
                        "rxBytes": 22482186,
                        "rxErrors": 0,
                        "txBytes": 357450663,
                        "txErrors": 0,
                        "interfaces": [
                         {
                          "name": "eth0",
                          "rxBytes": 22482186,
                          "rxErrors": 0,
                          "txBytes": 357450663,
                          "txErrors": 0
                         }
                        ]
                       },
                       "volume": [
                        {
                         "time": "2018-09-24T23:57:04Z",
                         "availableBytes": 16870731776,
                         "capacityBytes": 16870744064,
                         "usedBytes": 12288,
                         "inodesFree": 4118825,
                         "inodes": 4118834,
                         "inodesUsed": 9,
                         "name": "default-token-phqbm"
                        },
                        {
                         "time": "2018-09-24T23:57:05Z",
                         "availableBytes": 16870739968,
                         "capacityBytes": 16870744064,
                         "usedBytes": 4096,
                         "inodesFree": 4118829,
                         "inodes": 4118834,
                         "inodesUsed": 5,
                         "name": "secrets"
                        }
                       ],
                       "ephemeral-storage": {
                        "time": "2018-09-27T22:10:03Z",
                        "availableBytes": 112741339136,
                        "capacityBytes": 128701009920,
                        "usedBytes": 263344128,
                        "inodesFree": 33124287,
                        "inodes": 33554432,
                        "inodesUsed": 32
                       }
                      }
                     ]
                    }'

    @@parsed_string = JSON.parse(node_string)
    stub_request(:get, "http://generics-aws-node-name:10255/stats/summary").
        with(
            headers: {
                'Accept'=>'*/*',
                'Accept-Encoding'=>'gzip, deflate',
                'Host'=>'generics-aws-node-name:10255',
                'User-Agent'=>'rest-client/2.0.2 (darwin17.3.0 x86_64) ruby/2.5.1p57'
            }).
        to_return(status: 200, body: node_string, headers: {})

    @@driver = create_driver
    @@driver.run(timeout:20,  expect_emits: 1, shutdown: true)

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

      assert_not_nil @@hash_map_test.find('kube.node.cpu.usage')
      assert_equal @@parsed_string['node']['cpu']['usageNanoCores'], @@hash_map_test['kube.node.cpu.usage'][2]["value"]

      assert_not_nil @@hash_map_test.find('kube.node.cpu.usage_rate')
      assert_equal @@parsed_string['node']['cpu']['usageNanoCores']/ 1_000_000, @@hash_map_test['kube.node.cpu.usage_rate'][2]["value"]

    end

    test 'test_emit_memory_metrics' do

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

  end

end