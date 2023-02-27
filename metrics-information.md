# Metrics Information

## The following table describes common terminology used in this topic.

| Terminology | Definition |
| ---	| ---	|
| Node | A single machine in a kubernetes cluster. |
| imagefs | Stats for the underlying filesystem where container images are stored. Usage here refers to the total number of bytes occupied by images on the filesystem. |
| fs | Stats pertaining to total usage of filesystem resources on the rootfs used by node Kubernetes components. |
| sys-container | Stats for system daemons tracked as raw containers. |
| runtime | Stats for the underlying container runtime. |
| volume | Stats for volume usage of filesystem resources. |
| ephemeral-storage | Reports the total filesystem usage for the containers and emptyDir-backed volumes in the measured Pod. |
| rootfs | Stats pertaining to container rootfs usage of filesystem resources. |

 Reference: https://github.com/kubernetes/kubelet/blob/master/pkg/apis/stats/v1alpha1/types.go


## Aggregated Metrics

Metrics based on values extracted from aggregated files and field data. 

| Metric Name | Metric Type	| Metric Format	| Metric Description |
| ---	| ---	| ---	| ---	|
| kube.container.cpu.limit | float | millicpu | The container's CPU limit. | 
| kube.container.cpu.request| float| millicpu| Container's CPU request. |
| kube.container.memory.limit | float | megabyte	| The container's memory limit. |
| kube.container.memory.request	| float	| megabyte	| The container's memory request. |
| kube.pod.cpu.limit	| float	| millicpu	| The pod's CPU limit. |
| kube.pod.cpu.request	| float	| millicpu	| The pod's CPU request. |
| kube.pod.memory.limit	| float	| megabyte	| The pod's memory limit. |
| kube.pod.memory.request	| float	| megabyte	| The pod's memory request. |
| kube.namespace.cpu.limit	| float	| millicpu	|  The namespace's CPU limit. |
| kube.namespace.cpu.request	| float	| millicpu	| The namespace's CPU request. |
| kube.namespace.memory.limit	| float	| megabyte	| The namespace's memory limit. |
| kube.namespace.memory.request	| float	| megabyte	| The namespace's memory request. |
| kube.cluster.cpu.limit	| float	| millicpu	| The cluster's CPU limit. |
| kube.cluster.cpu.request	| float	| millicpu	| The cluster's CPU request. |
| kube.cluster.memory.limit	| float	| megabyte	| The cluster's memory limit. |
| kube.cluster.memory.request	| float	| megabyte	| The cluster's memory request. |
| kube.node.cpu.capacity|	float	| millicpu | The node's CPU capacity. |
| kube.node.cpu.allocatable	| float	| millicpu	| The node's allocatable CPU . |
| kube.node.memory.capacity	| float	| megabyte	| The node's memory capacity. |
| kube.node.memory.allocatable	| float	| megabyte	 | The node's allocatable memory.  |
| kube.node.cpu.reservation	| float	| millicpu	| The node's CPU reservation. |
| kube.node.cpu.utilization	| float	| millicpu	| The node's CPU utilization. |
| kube.node.memory.reservation	| float	| megabyte	| The node's memory reservation. |
| kube.node.memory.utilization	| float	| megabyte	| The node's memory utilization. |
| kube.namespace.cpu.usage	| float	| millicpu	| The namespace's CPU usage. |
| kube.namespace.memory.usage	| float	| megabyte	| The namespace's memory usage. |
| kube.cluster.cpu.usage	| float	| millicpu	| The cluster's CPU usage. |
| kube.cluster.memory.usage	| float	| bytes	| The cluster's memory usage. |
| kube.node.runtime | | | |

## Summary Metrics

Provides metrics as a sum of all observed values.

| Metric Name	| Metric Type	| Metric Format |	Metric Description |
| --- | --- | --- | --- | 
| kube.node.uptime	| float |	seconds |	The node uptime.	|
| kube.node.cpu.usage_rate	| float |	millicpu	| Total CPU usage (sum of all cores) averaged over the sample window.	|
| kube.node.cpu.usage	| float	| nanocpu	| Total CPU usage (sum of all cores) averaged over the sample window.	|
| kube.node.memory.available_bytes	| float	| bytes	| The node available memory for use in bytes.	|
| kube.node.memory.usage_bytes	| float	| bytes	| The node memory in use in bytes. |	
| kube.node.memory.rss_bytes	| float	| bytes	| The amount of anonymous and swap cache memory in bytes in the node.	|
| kube.node.memory.page_faults	| integer | |	The cumulative number of minor page faults in the node.	|
| kube.node.memory.major_page_faults	| integer | |	The cumulative number of major page faults in the node.	|
| kube.node.network.rx_bytes	| float	| bytes	| The cumulative count of bytes received in the node.	|
| kube.node.network.rx_errors	| integer	| | The cumulative count of receive errors encountered in the node.	|
| kube.node.network.tx_bytes |	float |	bytes |	The cumulative count of bytes transmitted in the node.	|
| kube.node.network.tx_errors	| integer | | The cumulative count of transmit errors encountered in the node.	|
| kube.node.fs.available_bytes | float	| bytes	| The storage space available, in bytes, for the filesystem on the node.	|
| kube.node.fs.capacity_bytes	| float	| bytes	| The total capacity, in bytes, of the filesystem's underlying storage on the node.	|
| kube.node.fs.used_bytes	| float	| bytes	| The bytes used for a specific task on the filesystem on the node.	|
| kube.node.fs.inodes_free	| integer	| | The free inodes in the filesystem on the node.	|
| kube.node.fs.inodes	| integer |  |	The total inodes in the filesystem on the node.	|
| kube.node.fs.inodes_used |	integer |  	| The inodes used by the filesystem on the node.	|
| kube.node.imagefs.available_bytes	| float	| bytes	| The storage space available, in bytes, for the filesystem on the node.	|
| kube.node.imagefs.capacity_bytes	| float	| bytes	| The total capacity, in bytes, of the filesystems underlying storage on the node.	|
| kube.node.imagefs.used_bytes	| float	| bytes	| The bytes used for a specific task on the filesystem on the node.	|
| kube.node.imagefs.inodes_free	| integer |  |	The free inodes in the filesystem on the node.	|
| kube.node.imagefs.inodes	| integer	|  | The free inodes in the filesystem on the node.	|
| kube.node.imagefs.inodes_used	| integer |  |	The free inodes in the filesystem on the node.	|
| kube.node.runtime.imagefs.maxpid	| integer | |	The max PID for the OS.	|
| kube.node.runtime.imagefs.curproc | integer |  |	The number of running process in the OS.	|
| kube.sys-container.uptime	| float	| seconds	| The sys-container uptime. |	
| kube.sys-container.cpu.usage_rate	| float	| millicpu	| Total CPU usage (sum of all cores) averaged over the sample window for sys-container.	|
| kube.sys-container.cpu.usage	| float	| millicpu	| Total CPU usage rate (sum of all cores) averaged over the sample window for sys-container.	|
| kube.sys-container.memory.available_bytes	| float	| bytes	| The storage space available, in bytes, for the filesystem for sys-container.	|
| kube.sys-container.memory.usage_bytes	| float	| bytes	| The node memory, in bytes, in use for the sys-container.	|
| kube.sys-container.memory.rss_bytes	| float	| bytes	| The amount of anonymous and swap cache memory, in bytes, for the sys-container. |	
| kube.sys-container.memory.rss_bytes	| float	| bytes	| The amount of anonymous and swap cache memory, in bytes, for the sys-container.	|
| kube.sys-container.memory.page_faults | integer 	|   | The cumulative number of minor page faults for the sys-container.	|
| kube.sys-container.memory.major_page_faults	| integer 	|  | The cumulative number of major page faults for the sys-container. |
| kube.pod.uptime	| float	| seconds	| The pod's uptime. |	
| kube.pod.cpu.usage_rate	| float	| millicpu	| Total CPU usage (sum of all cores), averaged over the sample window for the pod. |	
| kube.pod.cpu.usage	| float | nanocpu	| Total CPU usage rate (sum of all cores), averaged over the sample window for the pod. |
| kube.pod.memory.available_bytes	| float	| bytes	| Represents the storage space available, in bytes, for the filesystem on the pod.	|
| kube.pod.memory.usage_bytes	| float	| bytes	| The bytes used for a specific task in the filesystem on the pod.	|
| kube.pod.memory.rss_bytes	| float	| bytes	| The amount of anonymous and swap cache memory, in bytes, in the pod.	|
| kube.pod.memory.page_faults	| integer	|  | The cumulative number of minor page faults in the pod.	|
| kube.pod.memory.major_page_faults	| integer	| | The cumulative number of minor page faults in the pod.	|
| kube.pod.network.rx_bytes	| float	| bytes	| The cumulative count of bytes received in the pod.	|
| kube.pod.network.rx_errors	| integer	|  | The cumulative count of receive errors encountered in the pod.	|
| kube.pod.network.tx_bytes	| float	| bytes	| The cumulative count of bytes transmitted in the pod.	|
| kube.pod.network.tx_errors	| integer | | The cumulative count of transmit errors in the pod.	|
| kube.pod.ephemeral-storage.available_bytes	| float	| bytes	| The node's available memory for use, in bytes, in the pod's ephemeral storage.	|
| kube.pod.ephemeral-storage.capacity_bytes	| float	| bytes	| The total capacity, in bytes, of the filesystem's underlying storage in the pod's ephemeral storage.	|
| kube.pod.ephemeral-storage.used_bytes	| float	| bytes	| The bytes used for a specific task on the filesystem in the pod's ephemeral storage.	|
| kube.pod.ephemeral-storage.inodes_free	|integer	|  | The free inodes in the filesystem in the pod's ephemeral storage.	|
| kube.pod.ephemeral-storage.inodes	| integer |   | The inodes in the filesystem in the pod's ephemeral storage.	|
| kube.pod.ephemeral-storage.inodes_used	| integer |  |	The inodes used in the filesystem in the pod's ephemeral storage.	|
| kube.pod.volume.available_bytes	| float	| bytes	| The storage space available, in bytes, for the filesystem in the pod's volume.	|
| kube.pod.volume.capacity_bytes	| float	| bytes	| The total capacity, in bytes, of the filesystems underlying storage for the pod's volume.	|
| kube.pod.volume.used_bytes	| float	| bytes	| The bytes used for a specific task on the filesystem for the pod's volume.	|
| kube.pod.volume.inodes_free	| integer |  |	The free inodes in the filesystem for the pod's volume.	|
| kube.pod.volume.inodes	| integer |   | The inodes in the filesystem for the pod's volume.	|
| kube.pod.volume.inodes_used	| integer	|   | The used inodes in the filesystem for the pod's volume.	|
| kube.container.uptime	| float	| seconds	| The container's uptime.	|
| kube.container.cpu.usage_rate	| float	| millicpu	| Total CPU usage rate (sum of all cores) averaged over the sample window for the container.	|
| kube.container.cpu.usage	| float	| nanocpu	| Total CPU usage rate (sum of all cores) averaged over the sample window 
for the container.	|
| kube.container.memory.available_bytes	| float	| bytes	| The storage space available, in bytes, for the filesystem in the container.	|
| kube.container.memory.usage_bytes	| float	| bytes	| The bytes used for a specific task on the filesystem in the container. |
| kube.container.memory.rss_bytes	| float	| bytes	| The amount of anonymous and swap cache memory in bytes in the container.	|
| kube.container.memory.page_faults	| integer	|  | The cumulative number of minor page faults in the container.	|
| kube.container.memory.major_page_faults	| integer	|  | The cumulative number of major page faults in the container.	|
| kube.container.rootfs.available_bytes	| float	| bytes	| The storage space available, in bytes, in the filesystem in the container's rootfs.	|
| kube.container.rootfs.capacity_bytes	| float	| bytes	| The total capacity, in bytes, of the filesystem's underlying storage in the container's rootfs.	|
| kube.container.rootfs.used_bytes	| float	| bytes	| The bytes used for a specific task in the filesystem on the container's rootfs.	|
| kube.container.rootfs.inodes_free	| integer | |	The free inodes in the filesystem on the container's rootfs. |	
| kube.container.rootfs.inodes	| integer	| | The inodes in the filesystem on the container's rootfs.	|
| kube.container.rootfs.inodes_used	| integer	| | Represents the used inodes in the filesystem on the container's rootfs.	|
| kube.container.logs.available_bytes	| float |	bytes	| The storage space available, in bytes, for the filesystem on the container's logs.	|
| kube.container.logs.capacity_bytes	| float	| bytes	 | The total capacity, in bytes, of the filesystem's underlying storage in the container's logs.	|
| kube.container.logs.used_bytes	| float	| bytes	| The bytes used for a specific task on the filesystem in the container's logs.	|
| kube.container.logs.inodes_free	| integer | |	The free inodes in the filesystem in the container's logs.	|
| kube.container.logs.inodes	| integer	| | The inodes in the filesystem in the container's logs.	|
| kube.container.logs.inodes_used	| integer | |	The used inodes in the filesystem in the container's logs.	|


## Stats Metrics

Metrics based on measures and recording of data points and views.


| Metric Name |	Metric Type	| Metric Format	| Metric Description |
| --- | --- | --- | --- | 
| kube.node.cpu.cfs.periods | ThrottlingData | uint64 | CPU Completely Fair Scheduler statistics. Total number of elapsed enforcement intervals. |
| kube.node.cpu.cfs.throttled_periods | ThrottlingData | uint64 | CPU Completely Fair Scheduler statistics. Total number of times tasks in the cgroup have been throttled. |
| kube.node.cpu.cfs.throttled_time | ThrottlingData | uint64 | CPU Completely Fair Scheduler statistics. Total time duration, in nanoseconds, for which tasks in the cgroup have been throttled. |
| kube.node.cpu.usage.total | CPUUsage | uint64 | CPU usage time statistics in nanoseconds. |
| per_cpu_usage | CPUUsage | uint64 | CPU usage time statistics. Per CPU/core usage of the container in nanoseconds. |
| kube.node.cpu.usage.user | CPUUsage | uint64 | CPU usage time statistics. Time spent in user space in nanoseconds. |
| kube.node.cpu.usage.system | CPUUsage | uint64 | CPU usage time statistics. Time spent in kernel space in nanoseconds. |
| kube.node.cpu.load_average | | | Smoothed average of number of runnable threads x 1000. Splunk software multiplies by a thousand to avoid using floats while preserving precision. Load is smoothed over the last 10 seconds. Instantaneous value can be read from LoadStats.NrRunning. |
| kube.node.cpu.schedstat.run_time | | | The CPU Aggregated scheduler statistics, time spent on the CPU. |
| kube.node.cpu.schedstat.runqueue_time | | | The CPU Aggregated scheduler statistics, time spent waiting on a runqueue. |
| kube.node.cpu.schedstat.run_periods | | | The CPU Aggregated scheduler statistics, number of timeslices run on the CPU reservation. |
| kube.node.diskio.<disk_category>.stats.Async | | | |
| kube.node.diskio.<disk_category>.stats.Read	| | | |
| kube.node.diskio.<disk_category>.Sync	| | | |
| kube.node.diskio.<disk_category>.stats.Total	| | | |
| kube.node.diskio.<disk_category>.stats.Write | | | |
| kube.node.diskio.<disk_category>.minor | | | |
| kube.node.diskio.<disk_category>.major	| | | |
| kube.node.filesystem.available | | bytes | The bytes available for non-root user. |
| kube.node.filesystem.base_usage	| integer |  | Base usage consumed by the container's writable layer. At this time, this value is only applicable for Docker containers. |
| kube.node.filesystem.capacity	| | bytes | Bytes that can be consumed by the container on this filesystem. |
| kube.node.filesystem.inodes	| integer |  | Number of inodes. |
| kube.node.filesystem.inodes_free | integer |  | Number of available inodes. |
| kube.node.filesystem.io_in_progress | integer |  | Number of I/Os currently in progress. It is the only field that should go to zero. Value is incremented as requests are given to appropriate struct request_queue and decremented as they finish. |
| kube.node.filesystem.io_time | | | Number of milliseconds spent doing I/Os. This field increases so long as field 9 is nonzero. |
| kube.node.filesystem.read_time | | | Number of milliseconds spent reading, total number of milliseconds spent by all reads (as measured from make_request() to end_that_request_last()). |
| kube.node.filesystem.reads_completed	| | integer | The total number of reads completed successfully. |
| kube.node.filesystem.reads_merged	| | integer | Number of reads merged. Reads and writes which are adjacent to each other and may be merged for efficiency. For example, two 4K reads may become one 8K read before it is ultimately handed to the disk, and so it will be counted (and queued) as only one I/O. This field lets you know how often this was done. |
| kube.node.filesystem.sectors_read	| | integer | Total number of successfully read sectors. |
| kube.node.filesystem.sectors_written | | integer| The total number of successfully written sectors. |
| kube.node.filesystem.usage | | bytes | Number of bytes consumed by the container on this filesystem. |
| kube.node.filesystem.weighted_io_time	| | | Weighted number of milliseconds spent doing I/Os. This field is incremented at each I/O start, I/O completion, I/O merge. Or the field can read these stats by the number of I/Os in progress (field 9) times the number of milliseconds spent doing I/O since the last update of this field. This can provide an easy measure of both I/O completion time and of the backlog that may be accumulating. |
| kube.node.filesystem.write_time	| | | Total number of milliseconds spent by all writes, as measured from make_request() to end_that_request_last(). |
| kube.node.filesystem.writes_completed	| integer | | Total number of writes completed successfully. |
| kube.node.filesystem.writes_merged	| integer | | Number of writes merged. |
| kube.node.memory.cache	| | bytes | Number of bytes of page cache memory in bytes. |
| kube.node.memory.container_data.pgfault	| | | |
| kube.node.memory.container_data.pgmajfault	| | | |
| kube.node.memory.failcnt	| | | |
| kube.node.memory.hierarchical_data.pgfault	| | | |
| kube.node.memory.hierarchical_data.pgmajfault	| | | |
| kube.node.memory.max_usage	| | bytes | Maximum memory usage recorded in bytes. |
| kube.node.memory.rss	| | bytes | The amount of anonymous and swap cache memory, including transparent hugepages, in bytes. |
| kube.node.memory.swap	| | bytes | The amount of swap, in bytes, currently used by the processes in this cgroup. |
| kube.node.memory.usage	| | bytes | Current memory usage, in bytes. This includes all memory regardless of when it was accessed. |
| kube.node.memory.working_set	| | | The amount of working set memory, in bytes. This includes recently accessed memory, dirty memory, and kernel memory. Working set is <= "usage". |
| kube.node.memory.mapped_file	| | | |
| kube.node.tasks_stats.nr_io_wait | integer | | Number of tasks waiting on IO. |
| kube.node.tasks_stats.nr_running	| integer | | Number of running tasks. |
| kube.node.tasks_stats.nr_sleeping	| integer | | Number of sleeping tasks. |
| kube.node.tasks_stats.nr_stopped	| integer |  | Number of tasks in stopped state. |
| kube.node.tasks_stats.nr_uninterruptible | integer |  | Number of tasks in uninterruptible state. | 
| kube.node.network.<interface_id>.rx_bytes	| | bytes | Cumulative count of bytes received. |
| kube.node.network.<interface_id>.rx_dropped	| | | Cumulative count of packets dropped while receiving. |
| kube.node.network.<interface_id>.rx_errors	| | | Cumulative count of receive errors encountered. |
| kube.node.network.<interface_id>.rx_packets	| | | Cumulative count of packets received. |
| kube.node.network.<interface_id>.tx_bytes	| | | Cumulative count of bytes transmitted. |
| kube.node.network.<interface_id>.tx_dropped	| | | Cumulative count of packets dropped while transmitting. |
| kube.node.network.<interface_id>.tx_errors	| | | Cumulative count of transmit errors encountered. |
| kube.node.network.<interface_id>.tx_packets	| | |  Cumulative count of packets transmitted. |

 ## cAdvisor Metrics
 
 Performance and usage information for running containers. 

| Metric Name	| Metric Description |
| --- | --- |
| cadvisor_version_info | A metric with a constant "1" value labeled by kernel version, OS version, Docker version, cAdvisor version and cAdvisor revision.	|
| container_cpu_load_average_10s	| Value of container CPU load average over the last 10 seconds.	|
| container_cpu_system_seconds_total	| Cumulative system CPU time consumed in seconds.	|
| container_cpu_usage_seconds_total	| Cumulative CPU time consumed in seconds.	|
| container_cpu_user_seconds_total	| Cumulative user CPU time consumed in seconds.	|
| container_fs_inodes_free	| Number of available inodes. |	
| container_fs_inodes_total	| Number of inodes in use. |	
| container_fs_io_current	| Number of in progress I/Os. |	      
| container_fs_io_time_seconds_total	| Cumulative count of seconds spent doing I/Os. |	
| container_fs_io_time_weighted_seconds_total	| Cumulative weighted I/O time in seconds.	|
| container_fs_limit_bytes	| Number of bytes that can be consumed by the container on this filesystem.	|
| container_fs_read_seconds_total	| Cumulative count of seconds spent reading. |	
| container_fs_reads_bytes_total	| Cumulative count of bytes read. |	      
| container_fs_reads_merged_total	| Cumulative count of reads merged. |	
| container_fs_reads_total	| Cumulative count of reads completed.	|
| container_fs_sector_reads_total	| Cumulative count of sector writes completed.	|
| container_fs_sector_writes_total	| Number of bytes that are consumed by the container on this filesystem.	|
| container_fs_usage_bytes	| Cumulative count of seconds spent writing.	|
| container_fs_write_seconds_total	| Cumulative count of bytes written.	|
| container_fs_writes_bytes_total	| Cumulative count of writes merged.	|
| container_fs_writes_merged_total	| Cumulative count of writes completed. |	
| container_fs_writes_total	| Last time a container was seen by the exporter. |	
| container_last_seen	| Last time a container was seen by the exporter. |	      
| container_memory_cache	| Number of bytes of page cache memory.	|
| container_memory_failcnt	| Number of memory usage hits limits.	|
| container_memory_failures_total	| Cumulative count of memory allocation failures.	|
| container_memory_max_usage_bytes	| Maximum memory usage recorded in bytes. |	
| container_memory_rss	| Size of RSS in bytes.	|
| container_memory_swap	| Container swap usage in bytes.	|
| container_memory_usage_bytes	| Current memory usage in bytes, including all memory regardless of when it was accessed. |	
| container_memory_working_set_bytes	| Current working set in bytes.	|
| container_network_receive_bytes_total	| Cumulative count of bytes received. |
| container_network_receive_errors_total	| Cumulative count of errors encountered while receiving. |
| container_network_receive_packets_dropped_total	| Cumulative count of packets dropped while receiving.	|
| container_network_receive_packets_total	| Cumulative count of packets received. |	
| container_network_tcp_usage_total	| tcp connection usage statistic for container.	|
| container_network_transmit_bytes_total	| Cumulative count of bytes transmitted.	|
| container_network_transmit_errors_total	| Cumulative count of errors encountered while transmitting.	|
| container_network_transmit_packets_dropped_total	| Cumulative count of packets dropped while transmitting.	|
| container_network_transmit_packets_total	| Cumulative count of packets transmitted. |	
| container_network_udp_usage_total	| UDP connection usage statistic for container. |	
| container_scrape_error	| "1" indicates an error while getting container metrics, "0" indicates no error. |	
| container_spec_cpu_period	| CPU period of the container.	|
| container_spec_cpu_shares	| CPU share of the container.	|
| container_spec_memory_limit_bytes	| Memory limit for the container.	|
| container_spec_memory_reservation_limit_bytes	| Memory reservation limit for the container.	|
| container_spec_memory_swap_limit_bytes	| Memory swap limit for the container.	|
| container_start_time_seconds	| Start time of the container since Unix epoch in seconds.	|
| container_tasks_state	| Number of tasks in given state.	|
| machine_cpu_cores	| Number of CPU cores on the machine.	|
| machine_memory_bytes	| Amount of memory installed on the machine.	|
| container_cpu_cfs_throttled_seconds_total	| Total time that the container has been throttled.	|

