#
# Copyright 2018- Splunk Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'time'
require 'fluent/plugin/input'
require 'kubeclient'
require 'multi_json'

module Fluent
  module Plugin
    class KubernetesMetricsInput < Fluent::Plugin::Input
      Fluent::Plugin.register_input('kubernetes_metrics', self)

      helpers :timer

      desc 'The tag of the event.'
      config_param :tag, :string, default: 'kubernetes.metrics.*'

      desc 'How often it pulls metrcs.'
      config_param :interval, :time, default: '15s'

      desc 'Path to a kubeconfig file points to a cluster the plugin should collect metrics from. Mostly useful when running fluentd outside of the cluster. When `kubeconfig` is set, `kubernetes_url`, `client_cert`, `client_key`, `ca_file`, `insecure_ssl`, `bearer_token_file`, and `secret_dir` will all be ignored.'
      config_param :kubeconfig, :string, default: nil

      desc 'URL of the kubernetes API server.'
      config_param :kubernetes_url, :string, default: nil

      desc 'Path to the certificate file for this client.'
      config_param :client_cert, :string, default: nil

      desc 'Path to the private key file for this client.'
      config_param :client_key, :string, default: nil

      desc 'Path to the CA file.'
      config_param :ca_file, :string, default: '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'

      desc "If `insecure_ssl` is set to `true`, it won't verify apiserver's certificate."
      config_param :insecure_ssl, :bool, default: false

      desc 'Path to the file contains the API token. By default it reads from the file "token" in the `secret_dir`.'
      config_param :bearer_token_file, :string, default: nil

      desc "Path of the location where pod's service account's credentials are stored."
      config_param :secret_dir, :string, default: '/var/run/secrets/kubernetes.io/serviceaccount'

      desc 'Name of the node that this plugin should collect metrics from.'
      config_param :node_name, :string, default: nil

      desc 'Name of the nodes that this plugin should collect metrics from.'
      config_param :node_names, :array, default: [], value_type: :string

      desc 'The hostname or IP address that kubelet will use to connect to. If not supplied, status.hostIP of the node is used to fetch metrics from the Kubelet API (via the $KUBERNETES_NODE_IP environment variable)'
      config_param :kubelet_address, :string, default: "#{ENV['KUBERNETES_NODE_IP']}"

      desc 'The port that kubelet is listening to.'
      config_param :kubelet_port, :integer, default: 10_250

      desc 'Use the rest client to get the metrics from summary api on each kubelet'
      config_param :use_rest_client, :bool, default: true

      desc 'Use SSL for rest client.'
      config_param :use_rest_client_ssl, :bool, default: true

      def configure(conf)
        super

        if @use_rest_client
          raise Fluentd::ConfigError, 'node_name is required' if @node_name.nil? || @node_name.empty?
        else
          raise Fluentd::ConfigError, 'node_names is required' if @node_names.nil? || @node_names.empty?
        end

        parse_tag
        initialize_client
      end

      def start
        super

        timer_execute :metric_scraper, @interval, &method(:scrape_metrics)
        timer_execute :cadvisor_metric_scraper, @interval, &method(:scrape_cadvisor_metrics)
        # It is done to optionally fetch from 'stats' for k8s version <1.21
        if is_stats_endpoint_available?
          timer_execute :stats_metric_scraper, @interval, &method(:scrape_stats_metrics)
        else
          log.info "'/stats' endpoint is not available. It has been deprecated since k8s v1.15, disabled since v1.18, and removed in v1.21 and onwards"
        end
      end

      def close
        @watchers.each &:finish if @watchers

        super
      end

      private

      def parse_tag
        @tag_prefix, @tag_suffix = @tag.split('*') if @tag.include?('*')
      end

      def generate_tag(item_name)
        return @tag unless @tag_prefix

        [@tag_prefix, item_name, @tag_suffix].join
      end

      def init_with_kubeconfig(options = {})
        config = Kubeclient::Config.read @kubeconfig
        current_context = config.context

        @client = Kubeclient::Client.new(
          current_context.api_endpoint,
          current_context.api_version,
          options.merge(
            ssl_options: current_context.ssl_options,
            auth_options: current_context.auth_options
          )
        )
      end

      def init_without_kubeconfig(_options = {})
        # mostly borrowed from Fluentd Kubernetes Metadata Filter Plugin
        if @kubernetes_url.nil?
          # Use Kubernetes default service account if we're in a pod.
          env_host = ENV['KUBERNETES_SERVICE_HOST']
          env_port = ENV['KUBERNETES_SERVICE_PORT']
          if env_host && env_port
            @kubernetes_url = "https://#{env_host}:#{env_port}/api/"
          end
        end

        raise Fluent::ConfigError, 'kubernetes url is not set' unless @kubernetes_url

        # Use SSL certificate and bearer token from Kubernetes service account.
        if Dir.exist?(@secret_dir)
          secret_ca_file = File.join(@secret_dir, 'ca.crt')
          secret_token_file = File.join(@secret_dir, 'token')

          if @ca_file.nil? && File.exist?(secret_ca_file)
            @ca_file = secret_ca_file
          end

          if @bearer_token_file.nil? && File.exist?(secret_token_file)
            @bearer_token_file = secret_token_file
          end
        end

        ssl_options = {
          client_cert: @client_cert && OpenSSL::X509::Certificate.new(File.read(@client_cert)),
          client_key:  @client_key && OpenSSL::PKey::RSA.new(File.read(@client_key)),
          ca_file:     @ca_file,
          verify_ssl:  @insecure_ssl ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
        }

        auth_options = {}
        auth_options[:bearer_token] = File.read(@bearer_token_file) if @bearer_token_file

        @client = Kubeclient::Client.new(
          @kubernetes_url, 'v1',
          ssl_options: ssl_options,
          auth_options: auth_options
        )

        begin
          @client.api_valid?
        rescue KubeException => kube_error
          raise Fluent::ConfigError, "Invalid Kubernetes API #{@api_version} endpoint #{@kubernetes_url}: #{kube_error.message}"
        end
      end

      def initialize_client
        if @use_rest_client
          initialize_rest_client
        else
          options = {
            timeouts: {
              open: 10,
              read: nil
            }
          }

          if @kubeconfig.nil?
            init_without_kubeconfig options
          else
            init_with_kubeconfig options
          end
        end
      end

      def initialize_rest_client
        env_host = @kubelet_address
        env_port = @kubelet_port

        if env_host && env_port
          if @use_rest_client_ssl
            @kubelet_url = "https://#{env_host}:#{env_port}/stats/summary"
            @kubelet_url_stats = "https://#{env_host}:#{env_port}/stats"
            @cadvisor_url = "https://#{env_host}:#{env_port}/metrics/cadvisor"
          else
            @kubelet_url = "http://#{env_host}:#{env_port}/stats/summary"
            @kubelet_url_stats = "http://#{env_host}:#{env_port}/stats"
            @cadvisor_url = "http://#{env_host}:#{env_port}/metrics/cadvisor"
          end
        end

        if Dir.exist?(@secret_dir)
          secret_ca_file = File.join(@secret_dir, 'ca.crt')
          secret_token_file = File.join(@secret_dir, 'token')
          if @ca_file.nil? && File.exist?(secret_ca_file)
            @ca_file = secret_ca_file
          end
          if @bearer_token_file.nil? && File.exist?(secret_token_file)
            @bearer_token_file = secret_token_file
          end
        end
        log.info("Use URL #{@kubelet_url} for creating client to query kubelet summary api")
        log.info("Use URL #{@kubelet_url_stats} for creating client to query kubelet stats api")
        log.info("Use URL #{@cadvisor_url} for creating client to query cadvisor metrics api")
      end

      def set_ssl_options
        if @use_rest_client_ssl
          ssl_options = {
            ssl_ca_file: @ca_file,
            verify_ssl: @insecure_ssl ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER,
            headers: { Authorization: 'Bearer ' + File.read(@bearer_token_file) }
          }
        else
          ssl_options = {}
        end
        ssl_options
      end

      # This method is used to set the options for sending a request to the kubelet api
      def request_options
        options = { method: 'get', url: @kubelet_url }
        options = options.merge(set_ssl_options)
        options
      end

      # This method is used to set the options for sending a request to the stats api
      def request_options_stats
        options = { method: 'get', url: @kubelet_url_stats }
        options = options.merge(set_ssl_options)
        options
      end

      # This method is used to set the options for sending a request to the cadvisor api
      def cadvisor_request_options
        options = { method: 'get', url: @cadvisor_url }
        options = options.merge(set_ssl_options)
        options
      end

      # @client.proxy_url only returns the url, but we need the resource, not just the url
      def summary_proxy_api(node)
        @summary_api =
          begin
            @client.discover unless @client.discovered
            @client.rest_client["/nodes/#{node}:#{@kubelet_port}/proxy/stats/summary"].tap do |endpoint|
              log.info("Use URL #{endpoint.url} for scraping metrics")
            end
          end
      end

      def stats_proxy_api(node)
        @stats_api =
          begin
            @client.discover unless @client.discovered
            @client.rest_client["/nodes/#{node}:#{@kubelet_port}/proxy/stats"].tap do |endpoint|
              log.info("Use URL #{endpoint.url} for scraping stats metrics")
            end
          end
      end

      def cadvisor_proxy_api(node)
        @cadvisor_api =
          begin
            @client.discover unless @client.discovered
            @client.rest_client["/nodes/#{node}:#{@kubelet_port}/proxy/metrics/cadvisor"].tap do |endpoint|
              log.info("Use URL #{endpoint.url} for scraping metrics")
            end
          end
      end

      def parse_time(metric_time)
        Fluent::EventTime.from_time Time.iso8601(metric_time)
      end

      def underscore(camlcase)
        camlcase.gsub(/[A-Z]/) { |c| "_#{c.downcase}" }
      end

      def emit_uptime(tag:, start_time:, labels:)
        unless start_time.nil?
          uptime = @scraped_at - Time.iso8601(start_time)
          router.emit generate_tag("#{tag}.uptime"), Fluent::EventTime.from_time(@scraped_at), labels.merge('value' => uptime)
        end
      end

      def emit_cpu_metrics(tag:, metrics:, labels:)
        unless metrics['time'].nil?
          time = parse_time metrics['time']
          if usage_rate = metrics['usageNanoCores']
            router.emit generate_tag("#{tag}.cpu.usage_rate"), time, labels.merge('value' => usage_rate / 1_000_000)
          end
          if usage = metrics['usageNanoCores']
            router.emit generate_tag("#{tag}.cpu.usage"), time, labels.merge('value' => usage)
          end
        end
      end

      def emit_memory_metrics(tag:, metrics:, labels:)
        unless metrics['time'].nil?
          time = parse_time metrics['time']
          %w[availableBytes usageBytes workingSetBytes rssBytes pageFaults majorPageFaults].each do |name|
            if value = metrics[name]
              router.emit generate_tag("#{tag}.memory.#{underscore name}"), time, labels.merge('value' => value)
            end
          end
        end
      end

      def emit_network_metrics(tag:, metrics:, labels:)
        unless metrics['time'].nil?
          time = parse_time metrics['time']
          Array(metrics['interfaces']).each do |it|
            it_name = it['name']
            %w[rxBytes rxErrors txBytes txErrors].each do |metric_name|
              if value = it[metric_name]
                router.emit generate_tag("#{tag}.network.#{underscore metric_name}"), time, labels.merge('value' => value, 'interface' => it_name)
              end
            end
          end
        end
      end

      def emit_fs_metrics(tag:, metrics:, labels:)
        unless metrics['time'].nil?
          time = parse_time metrics['time']
          %w[availableBytes capacityBytes usedBytes inodesFree inodes inodesUsed].each do |metric_name|
            if value = metrics[metric_name]
              router.emit generate_tag("#{tag}.#{underscore metric_name}"), time, labels.merge('value' => value)
            end
          end
        end
      end

      def emit_node_rlimit_metrics(node_name, rlimit)
        unless rlimit['time'].nil?
          time = parse_time rlimit['time']
          %w[maxpid curproc].each do |metric_name|
            next unless value = rlimit[metric_name]

            router.emit(generate_tag("node.runtime.imagefs.#{metric_name}"), time,
                        'value' => value,
                        'node' => node_name)
          end
        end
      end

      def emit_system_container_metrics(node_name, container)
        tag = 'sys-container'
        labels = { 'node' => node_name, 'name' => container['name'] }
        unless container['startTime'].nil?
          emit_uptime tag: tag, start_time: container['startTime'], labels: labels
          emit_cpu_metrics tag: tag, metrics: container['cpu'], labels: labels unless container['cpu'].nil?
          emit_memory_metrics tag: tag, metrics: container['memory'], labels: labels unless container['memory'].nil?
        end
      end

      def emit_stats_breakdown(stats)
        stats_latest = stats[-1]
        tag = 'node'
        labels = { 'node' => @node_name }
        unless stats_latest['timestamp'].nil?
          stats_timestamp = parse_time stats_latest['timestamp']
          unless stats_latest['cpu'].nil?
            emit_cpu_metrics_stats tag: tag, metrics: stats_latest['cpu'], labels: labels, time: stats_timestamp
          end

          unless stats_latest['diskio'].nil?
            emit_diskio_metrics_stats tag: tag, metrics: stats_latest['diskio'], labels: labels, time: stats_timestamp
          end

          unless stats_latest['memory'].nil?
            emit_memory_metrics_stats tag: tag, metrics: stats_latest['memory'], labels: labels, time: stats_timestamp
          end

          unless stats_latest['network'].nil?
            emit_network_metrics_stats tag: tag, metrics: stats_latest['network'], labels: labels, time: stats_timestamp
          end

          unless stats_latest['filesystem'].nil?
            emit_filesystem_metrics_stats tag: tag, metrics: stats_latest['filesystem'], labels: labels, time: stats_timestamp
          end

          unless stats_latest['task_stats'].nil?
            emit_tasks_stats_metrics_stats tag: tag, metrics: stats_latest['task_stats'], labels: labels, time: stats_timestamp
          end
        end
      end

      def emit_cpu_metrics_stats(tag:, metrics:, labels:, time:)
        if cpu_usage_total = metrics['usage']['total']
          router.emit generate_tag("#{tag}.cpu.usage.total"), time, labels.merge('value' => cpu_usage_total / 1_000_000)
        end
        if cpu_usage_user = metrics['usage']['user']
          router.emit generate_tag("#{tag}.cpu.usage.user"), time, labels.merge('value' => cpu_usage_user / 1_000_000)
        end
        if cpu_usage_system = metrics['usage']['system']
          router.emit generate_tag("#{tag}.cpu.usage.system"), time, labels.merge('value' => cpu_usage_system / 1_000_000)
        end

        if cpu_cfs_periods = metrics['cfs']['periods']
          router.emit generate_tag("#{tag}.cpu.cfs.periods"), time, labels.merge('value' => cpu_cfs_periods)
        end
        if cpu_cfs_throttled_periods = metrics['cfs']['throttled_periods']
          router.emit generate_tag("#{tag}.cpu.cfs.throttled_periods"), time, labels.merge('value' => cpu_cfs_throttled_periods)
        end
        if cpu_cfs_throttled_time = metrics['cfs']['throttled_time']
          router.emit generate_tag("#{tag}.cpu.cfs.throttled_time"), time, labels.merge('value' => cpu_cfs_throttled_time)
        end
        if cpu_load_average = metrics['load_average']
          router.emit generate_tag("#{tag}.cpu.load_average"), time, labels.merge('value' => cpu_load_average)
        end
      end

      def emit_diskio_metrics_stats(tag:, metrics:, labels:, time:)
        %w[io_service_bytes io_serviced io_queued sectors io_service_time io_wait_time io_merged io_time].each do |metric_name|
          next unless current_io_metric = metrics[metric_name]

          current_io_metric.each do |device|
            if diskio_io_service_bytes_major = device['major']
              router.emit generate_tag("#{tag}.diskio".concat(metric_name).concat('.major.')), time, labels.merge('device' => device['device'], 'value' => diskio_io_service_bytes_major)
            end
            if diskio_io_service_bytes_minor = device['minor']
              router.emit generate_tag("#{tag}.diskio".concat(metric_name).concat('.minor.')), time, labels.merge('device' => device['device'], 'value' => diskio_io_service_bytes_minor)
            end
            device_stats = device['stats'] unless device['stats'].nil?
            device_stats.each do |device_stat|
              device_key, device_value = device_stat unless device_stat.nil?
              router.emit generate_tag("#{tag}.diskio.".concat(metric_name).concat('.stats.').concat(device_key)), time, labels.merge('device' => device['device'], 'value' => device_value)
            end
          end
        end
      end

      def emit_memory_metrics_stats(tag:, metrics:, labels:, time:)
        %w[usage max_usage cache rss swap working_set failcnt].each do |metric_name|
          if current_memory_metric = metrics[metric_name]
            router.emit generate_tag("#{tag}.memory.".concat(metric_name)), time, labels.merge('value' => current_memory_metric)
          end
        end
        %w[container_data hierarchical_data].each do |metric_name_group|
          next unless current_memory_metric_group = metrics[metric_name_group]

          current_memory_metric_group.each do |metric_name|
            metric_key, metric_value = metric_name unless metric_name.nil?
            router.emit generate_tag("#{tag}.memory.".concat(metric_name_group).concat('.').concat(metric_key)), time, labels.merge('value' => metric_value)
          end
        end
      end

      def emit_network_metrics_stats(tag:, metrics:, labels:, time:)
        network_name = metrics['name']
        %w[rx_bytes rx_packets rx_errors rx_dropped tx_bytes tx_packets tx_errors tx_dropped].each do |metric_name|
          if current_network_metric = metrics[metric_name]
            router.emit generate_tag("#{tag}.network.".concat(network_name).concat('.').concat(metric_name)), time, labels.merge('value' => current_network_metric)
          end
        end

        if network_interfaces = metrics['interfaces']
          network_interfaces.each do |current_interface|
            name = current_interface['name']
            %w[rx_bytes rx_packets rx_errors rx_dropped tx_bytes tx_packets tx_errors tx_dropped].each do |current_metric|
              if metric_value = current_interface[current_metric]
                router.emit generate_tag("#{tag}.network.".concat(name).concat('.').concat(current_metric)), time, labels.merge('value' => metric_value)
              end
            end
          end
        end

        %w[tcp tcp6 udp udp6].each do |metric_name_group|
          next unless metric_group = metrics[metric_name_group]

          metric_group.each do |current_metric|
            metric_key, metric_value = current_metric unless current_metric.nil?
            router.emit generate_tag("#{tag}.network.".concat(metric_name_group).concat('.').concat(metric_key)), time, labels.merge('value' => metric_value)
          end
        end
      end

      def emit_filesystem_metrics_stats(tag:, metrics:, labels:, time:)
        metrics.each do |file_system|
          device = file_system['device']
          type = file_system['type']
          file_system.each do |file_metric|
            file_key, file_value = file_metric unless file_metric.nil?
            unless %w[device type has_inodes].include? file_key
              router.emit generate_tag("#{tag}.filesystem.".concat(file_key)), time, labels.merge('device' => device, 'type' => type, 'value' => file_value)
            end
          end
        end
      end

      def emit_tasks_stats_metrics_stats(tag:, metrics:, labels:, time:)
        metrics.each do |task_stats|
          task_key, task_value = task_stats unless task_stats.nil?
          router.emit generate_tag("#{tag}.tasks_stats.".concat(task_key)), time, labels.merge('value' => task_value)
        end
      end

      def emit_node_metrics(node)
        node_name = node['nodeName']
        tag = 'node'
        labels = { 'node' => node_name }

        unless node['startTime'].nil?
          emit_uptime tag: tag, start_time: node['startTime'], labels: labels
          unless node['cpu'].nil?
            emit_cpu_metrics tag: tag, metrics: node['cpu'], labels: labels
          end
          unless node['memory'].nil?
            emit_memory_metrics tag: tag, metrics: node['memory'], labels: labels
          end
          unless node['network'].nil?
            emit_network_metrics tag: tag, metrics: node['network'], labels: labels
          end
          unless node['fs'].nil?
            emit_fs_metrics tag: "#{tag}.fs", metrics: node['fs'], labels: labels
          end
          unless node['runtime']['imageFs'].nil?
            emit_fs_metrics tag: "#{tag}.imagefs", metrics: node['runtime']['imageFs'], labels: labels
          end
          unless node['rlimit'].nil?
            emit_node_rlimit_metrics node_name, node['rlimit']
          end
          unless node['systemContainers'].nil?
            node['systemContainers'].each do |c|
              emit_system_container_metrics node_name, c unless c.nil?
            end
          end
        end
      end

      def emit_container_metrics(pod_labels, container)
        tag = 'container'
        labels = pod_labels.merge 'container-name' => container['name']
        unless container['startTime'].nil?
          emit_uptime tag: tag, start_time: container['startTime'], labels: labels
          emit_cpu_metrics tag: tag, metrics: container['cpu'], labels: labels unless container['cpu'].nil?
          emit_memory_metrics tag: tag, metrics: container['memory'], labels: labels unless container['memory'].nil?
          emit_fs_metrics tag: "#{tag}.rootfs", metrics: container['rootfs'], labels: labels unless container['rootfs'].nil?
          emit_fs_metrics tag: "#{tag}.logs", metrics: container['logs'], labels: labels unless container['logs'].nil?
        end
      end

      def emit_pod_metrics(node_name, pod)
        tag = 'pod'
        labels = pod['podRef'].transform_keys &'pod-'.method(:+)
        labels['node'] = node_name

        unless pod['startTime'].nil?
          emit_uptime tag: tag, start_time: pod['startTime'], labels: labels
          emit_cpu_metrics tag: tag, metrics: pod['cpu'], labels: labels if pod['cpu'] unless pod['cpu'].nil?
          emit_memory_metrics tag: tag, metrics: pod['memory'], labels: labels if pod['memory'] unless pod['memory'].nil?
          emit_network_metrics tag: tag, metrics: pod['network'], labels: labels unless pod['network'].nil?
          emit_fs_metrics tag: "#{tag}.ephemeral-storage", metrics: pod['ephemeral-storage'], labels: labels unless pod['ephemeral-storage'].nil?
          unless pod['volume'].nil?
            Array(pod['volume']).each do |volume|
              emit_fs_metrics tag: "#{tag}.volume", metrics: volume, labels: labels.merge('name' => volume['name'])  unless volume.nil?
            end
          end
          unless pod['containers'].nil?
            Array(pod['containers']).each do |container|
              emit_container_metrics labels, container unless container.nil?
            end
          end
        end
      end

      def emit_metrics(metrics)
        emit_node_metrics(metrics['node']) unless metrics['node'].nil?
        Array(metrics['pods']).each &method(:emit_pod_metrics).curry.call(metrics['node']['nodeName']) unless metrics['pods'].nil?
      end

      def emit_stats_metrics(metrics)
        emit_stats_breakdown(metrics['stats']) unless metrics['stats'].nil?
      end

      # Make sure regex has only one capturing group
      def grep_using_regex(metric, regex)
        match = metric.match(regex)
        return nil if match.nil?
        match[1]
      end

      def emit_cadvisor_metrics(metrics)
        metrics = metrics.split("\n")
        metrics.each do |metric|
          
          next if metric[0] == '#' or not container_name = grep_using_regex(metric, /container(?:_name)?="([^"]*)"/)
          
          metric_str, metric_val = metric.split(' ')
          metric_val = metric_val.to_f if metric_val.is_a? String
          first_occur = metric_str.index('{')
          metric_name = metric_str[0..first_occur - 1]
          pod_name = grep_using_regex(metric, /pod(?:_name)?="([^"]*)"/).to_s
          image_name = grep_using_regex(metric, /image="([^"]*)"/).to_s
          namespace = grep_using_regex(metric, /namespace="([^"]*)"/).to_s
          metric_labels = { 'pod_name' => pod_name, 'image' => image_name, 'namespace' => namespace, 'value' => metric_val, 'node' => @node_name }
          if container_name=="POD"
            tag = 'pod'
            tag = generate_tag("#{tag}#{metric_name.tr('_', '.')}")
            tag = tag.gsub('container', '')
          else
            container_label = { 'container_name' => container_name }
            metric_labels.merge!(container_label)
            tag = generate_tag(metric_name.tr('_', '.').to_s)
          end
          router.emit tag, @scraped_at_cadvisor, metric_labels
        end
      end

      def scrape_metrics
        if @use_rest_client
          response = RestClient::Request.execute request_options
          handle_response(response)
        else
          @node_names.each do |node|
            response = summary_proxy_api(node).get(@client.headers)
            handle_response(response)
          end
        end
      end

      def is_stats_endpoint_available?
        if @use_rest_client
          response_stats = RestClient::Request.execute request_options_stats
        else
          @node_names.each do |node|
            @node_name = node
            response_stats = stats_proxy_api(node).get(@client.headers)
          end
        end
        true
        rescue RestClient::NotFound
          false
      end

      def scrape_stats_metrics
        if @use_rest_client
          response_stats = RestClient::Request.execute request_options_stats
          handle_stats_response(response_stats)
        else
          @node_names.each do |node|
            @node_name = node
            response_stats = stats_proxy_api(node).get(@client.headers)
            handle_stats_response(response_stats)
          end
        end
      end

      def scrape_cadvisor_metrics
        if @use_rest_client
          response_cadvisor = RestClient::Request.execute cadvisor_request_options
          handle_cadvisor_response(response_cadvisor)
        else
          @node_names.each do |node|
            response_cadvisor = cadvisor_proxy_api(node).get(@client.headers)
            handle_cadvisor_response(response_cadvisor)
          end
        end
      end

      # This method is used to handle responses from the kubelet summary api
      def handle_response(response)
        # Checking response codes only for a successful GET request viz., 2XX codes
        if (response.code < 300) && (response.code > 199)
          @scraped_at = Time.now
          emit_metrics MultiJson.load(response.body)
        else
          log.error "ExMultiJson.load(response.body) expected 2xx from summary API, but got #{response.code}. Response body = #{response.body}"
        end
      rescue StandardError => error
        log.error "Failed to scrape metrics, error=#{error.inspect}"
        log.error_backtrace
      end

      # This method is used to handle responses from the kubelet stats api
      def handle_stats_response(response)
        # Checking response codes only for a successful GET request viz., 2XX codes
        if (response.code < 300) && (response.code > 199)
          @scraped_at = Time.now
          emit_stats_metrics MultiJson.load(response.body)
        else
          log.error "ExMultiJson.load(response.body) expected 2xx from stats API, but got #{response.code}. Response body = #{response.body}"
        end
      rescue StandardError => error
        log.error "Failed to scrape metrics, error=#{error.inspect}"
        log.error_backtrace
      end

      # This method is used to handle responses from the cadvisor  api
      def handle_cadvisor_response(response)
        # Checking response codes only for a successful GET request viz., 2XX codes
        if (response.code < 300) && (response.code > 199)
          @scraped_at_cadvisor = Time.now
          emit_cadvisor_metrics response.body
        else
          log.error "Expected 2xx from cadvisor metrics API, but got #{response.code}. Response body = #{response.body}"
        end
      rescue StandardError => e
        log.error "Failed to scrape metrics, error=#{$ERROR_INFO}, #{e.inspect}"
        log.error_backtrace
      end
    end
  end
end
