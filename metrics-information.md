# Aggregator Metrics

 |Metric Name |Metric Type	|Metric Format	|Metric Description |
| ---	| ---	| ---	| ---	|
| kube.container.cpu.limit | float | millicpu | Container's cpu limit | 
| kube.container.cpu.request| float| millicpu| Container's cpu request |
| kube.container.memory.limit | float | megabyte	| Container's memory limit |
| kube.container.memory.request	| float	| megabyte	| Container's memory request |
| kube.pod.cpu.limit	| float	| millicpu	| Pod's cpu limit |
| kube.pod.cpu.request	| float	| millicpu	| Pod's cpu request |
| kube.pod.memory.limit	| float	| megabyte	| Pod's memory limit |
| kube.pod.memory.request	| float	| megabyte	| Pod's memory request |
| kube.namespace.cpu.limit	| float	| millicpu	|  Namespace's cpu limit |
| kube.namespace.cpu.request	| float	| millicpu	| Namespace's cpu request |
| kube.namespace.memory.limit	| float	| megabyte	| Namespace's memory limit |
| kube.namespace.memory.request	| float	| megabyte	| Namespace's memory request |
| kube.cluster.cpu.limit	| float	| millicpu	| Cluster's cpu limit |
| kube.cluster.cpu.request	| float	| millicpu	| Cluster's cpu request |
| kube.cluster.memory.limit	| float	| megabyte	| Cluster's memory limit |
| kube.cluster.memory.request	| float	| megabyte	| Cluster's memory request |
| kube.node.cpu.capacity|	float	| millicpu | Node's cpu capacity |
| kube.node.cpu.allocatable	| float	| millicpu	| Node's cpu allocatable |
| kube.node.memory.capacity	| float	| megabyte	| Node's memory capacity |
| kube.node.memory.allocatable	| float	| megabyte	 |Node's memory allocatable |
| kube.node.cpu.reservation	| float	| millicpu	| Node's cpu reservation |
| kube.node.cpu.utilization	| float	| millicpu	| Node's cpu utilization |
| kube.node.memory.reservation	| float	| megabyte	| Node's memory reservation |
| kube.node.memory.utilization	| float	| megabyte	| Node's memory utilization |
| kube.namespace.cpu.usage	| float	| millicpu	| Namespace's cpu usage |
| kube.namespace.memory.usage	| float	| megabyte	| Namespace's memory usage |
| kube.cluster.cpu.usage	| float	| millicpu	| Cluster's cpu usage |
| kube.cluster.memory.usage	| float	| bytes	| Cluster's memory usage|
| kube.node.runtime | | | |



 # Summary Metrics 

 | Jargon | Definition |
| ---	| ---	|
| Node | A single machine in a kubernetes cluster |
| imagefs | Stats about the underlying filesystem where container images are stored. Usage here refers 
to the total number of bytes occupied by images on the filesystem. |
| fs | Stats pertaining to total usage of filesystem resources on the rootfs used by node k8s components. |
| sys-container | Stats of system daemons tracked as raw containers. |
| runtime | Stats about the underlying container runtime. |
| volume | Stats pertaining to volume usage of filesystem resources. |
| ephemeral-storage | Reports the total filesystem usage for the containers and emptyDir-backed volumes in the measured Pod. |
| rootfs | Stats pertaining to container rootfs usage of filesystem resources. |

 Reference: https://github.com/kubernetes/kubernetes/blob/master/pkg/kubelet/apis/stats/v1alpha1/types.go


 # Summary Metrics

 | Metric Name	| Metric Type	| Metric Format |	Metric Description|
| --- | --- | --- | --- | 
| kube.node.uptime	| float |	seconds |	Node's uptime	|
| kube.node.cpu.usage_rate	| float |	millicpu	| Total CPU usage (sum of all cores) averaged over the sample window.	|
| kube.node.cpu.usage	| float	| nanocpu	| Total CPU usage (sum of all cores) averaged over the sample window.	|
| kube.node.memory.available_bytes	| float	| bytes	| Node's available memory for use in bytes.	|
| kube.node.memory.usage_bytes	| float	| bytes	| Node's memory in use in bytes. |	
| kube.node.memory.rss_bytes	| float	| bytes	| The amount of anonymous and swap cache memory in bytes in the node.	|
| kube.node.memory.page_faults	| integer | |	Cumulative number of minor page faults in the node.	|
| kube.node.memory.major_page_faults	| integer | |	Cumulative number of major page faults in the node.	|
| kube.node.network.rx_bytes	| float	| bytes	| Cumulative count of bytes received in the node.	|
| kube.node.network.rx_errors	| integer	| | Cumulative count of receive errors encountered in the node.	|
| kube.node.network.tx_bytes |	float |	bytes |	Cumulative count of bytes transmitted in the node.	|
| kube.node.network.tx_errors	| integer | | Cumulative count of transmit errors encountered in the node.	|
 | Metric | Metric Type	| Metric Format	| Metric Descrioption |
| --- | --- | --- | --- |
| kube.node.fs.available_bytes | float	| bytes	| Represents the storage space 
available, in bytes, for the filesystem on the node.	|
| kube.node.fs.capacity_bytes	| float	| bytes	| Represents the total capacity, 
in bytes, of the filesystems underlying storage on the node.	|
| kube.node.fs.used_bytes	| float	| bytes	| Represents the bytes used for a specific 
task on the filesystem on the node.	|
| kube.node.fs.inodes_free	| integer	| | InodesFree represents the free inodes in the filesystem on the node.	|
| kube.node.fs.inodes	| integer |  |	Inodes represents the total inodes in the filesystem on the node.	|
| kube.node.fs.inodes_used |	integer |  	| Represents the inodes used by the filesystem on the node.	|
| kube.node.imagefs.available_bytes	| float	| bytes	| Represents the storage space available, in 
bytes, for the filesystem on the node.	|
| kube.node.imagefs.capacity_bytes	| float	| bytes	| Represents the total capacity, in bytes, of 
the filesystems underlying storage on the node.	|
| kube.node.imagefs.used_bytes	| float	| bytes	| Represents the bytes used for a specific task 
on the filesystem on the node.	|
| kube.node.imagefs.inodes_free	| integer |   |	InodesFree represents the free inodes in the filesystem on the node.	
| kube.node.imagefs.inodes	| integer	|  | Inodes represents the free inodes in the filesystem on the node.	|
| kube.node.imagefs.inodes_used	| integer |   |	Inodes represents the free inodes in the filesystem on the node.	|
| kube.node.runtime.imagefs.maxpid	| integer | |	The max PID of OS	|
| kube.node.runtime.imagefs.curproc | integer |  |	The number of running process in the OS	|
| kube.sys-container.uptime	| float	| seconds	| Sys container's uptime |	
| kube.sys-container.cpu.usage_rate	| float	| millicpu	| Total CPU usage (sum of all cores) averaged over the 
sample window for sys-container.	|
| kube.sys-container.cpu.usage	| float	| millicpu	| Total CPU usage rate (sum of all cores) averaged over the 
sample window for sys-container.	|
| kube.sys-container.memory.available_bytes	| float	| bytes	| Represents the storage space 
available, in bytes, for the filesystem for sys-container.	|
| kube.sys-container.memory.usage_bytes	|float	|bytes	|Node's memory in use in bytes for sys-container.	|
| kube.sys-container.memory.rss_bytes	| float	| bytes	| The amount of anonymous and swap cache memory.
in bytes, for sys-container. |	
| kube.sys-container.memory.rss_bytes	| float	| bytes	| The amount of anonymous and swap cache memory, 
in bytes, for sys-container.	
| kube.sys-container.memory.page_faults | integer	|   | Cumulative number of minor page faults for sys-container.	|
| kube.sys-container.memory.major_page_faults	| integer	|  | Cumulative number of major page faults for sys-container.	|
| kube.pod.uptime	|float	|seconds	|Pod's uptime. |	
| kube.pod.cpu.usage_rate	| float	| millicpu	| Total CPU usage (sum of all cores) averaged over the sample window 
for the pod. |	
| kube.pod.cpu.usage	| float | nanocpu	| Total CPU usage rate (sum of all cores) averaged over the sample window 
for the pod.	|
| kube.pod.memory.available_bytes	| float	| bytes	| Represents the storage space 
available, in bytes, for the filesystem for the pod.	|
| kube.pod.memory.usage_bytes	| float	| bytes	| Represents the bytes used for a specific 
task on the filesystem for the pod.	|
| kube.pod.memory.rss_bytes	| float	| bytes	| The amount of anonymous and swap cache memory. in bytes, for the pod.	|
| kube.pod.memory.page_faults	| integer	|  | Cumulative number of minor page faults for the pod.	|
| kube.pod.memory.major_page_faults	| integer	| | Cumulative number of minor page faults for the pod.	|
| kube.pod.network.rx_bytes	| float	| bytes	| Cumulative count of bytes received for the pod.	|
| kube.pod.network.rx_errors	| integer	|  | Cumulative count of receive errors encountered for the pod.	|
| kube.pod.network.tx_bytes	| float	| bytes	| Cumulative count of bytes transmitted for the pod.	|
| kube.pod.network.tx_errors	| integer | | Cumulative count of transmit errors encountered for the pod.	|
| kube.pod.ephemeral-storage.available_bytes	| float	| bytes	| Node's available memory for use in bytes for 
the pod's ephemeral storage.	|
| kube.pod.ephemeral-storage.capacity_bytes	| float	| bytes	| Represents the total capacity,
in bytes, of the filesystems underlying storage for the pod's ephemeral storage.	|
| kube.pod.ephemeral-storage.used_bytes	| float	| bytes	| Represents the bytes used for a specific 
task on the filesystem for the pod's ephemeral storage.	|
| kube.pod.ephemeral-storage.inodes_free	|integer	|  |InodesFree represents the free inodes in the filesystem 
for the pod's ephemeral storage.	|
| kube.pod.ephemeral-storage.inodes	| integer |   | Represents the inodes in the filesystem for 
the pod's ephemeral storage.	|
| kube.pod.ephemeral-storage.inodes_used	| integer |  |	Represents the used inodes in the filesystem 
for the pod's ephemeral storage.	|
| kube.pod.volume.available_bytes	| float	| bytes	| Represents the storage space available,
In bytes, for the filesystem for the pod's volume.	|
| kube.pod.volume.capacity_bytes	| float	| bytes	| Represents the total capacity, in bytes, of 
the filesystems underlying storage for the pod's volume.	|
| kube.pod.volume.used_bytes	| float	| bytes	| UsedBytes represents the bytes used for a specific task on the 
filesystem for the pod's volume.	|
| kube.pod.volume.inodes_free	| integer |  |	InodesFree represents the free inodes in the filesystem for the pod's volume.	|
| kube.pod.volume.inodes	| integer |   | Represents the inodes in the filesystem for the pod's volume.	|
| kube.pod.volume.inodes_used	| integer	|   | Represents the used inodes in the filesystem for the pod's volume.	|
| kube.container.uptime	| float	| seconds	| Container's uptime	|
| kube.container.cpu.usage_rate	| float	| millicpu	| Total CPU usage rate (sum of all cores) averaged over the sample 
window for the container.	|
| kube.container.cpu.usage	| float	| nanocpu	| Total CPU usage rate (sum of all cores) averaged over the sample window 
for the container.	|
| kube.container.memory.available_bytes	| float	| bytes	| AvailableBytes represents the storage space available, in bytes,
for the filesystem for the container.	|
| kube.container.memory.usage_bytes	| float	| bytes	| UsedBytes represents the bytes used for a specific task 
on the filesystem for the container.	|
| kube.container.memory.rss_bytes	| float	| bytes	| The amount of anonymous and swap cache memory in bytes for the container.	|
| kube.container.memory.page_faults	| integer	|  |Cumulative number of minor page faults for the container.	|
| kube.container.memory.major_page_faults	|integer	|  |Cumulative number of major page faults for the container.	|
| kube.container.rootfs.available_bytes	|float	|bytes	|Represents the storage space available, in bytes, for 
the filesystem for the container's rootfs.	|
| kube.container.rootfs.capacity_bytes	| float	| bytes	| Represents the total capacity (bytes) of the filesystems 
underlying storage for the container's rootfs.	|
| kube.container.rootfs.used_bytes	| float	| bytes	| UsedBytes represents the bytes used for a specific task on 
the filesystem for the container's rootfs.	|
| kube.container.rootfs.inodes_free	| integer | |	Represents the free inodes in the filesystem for the container's rootfs. |	
| kube.container.rootfs.inodes	| integer	| | Inodes represents the inodes in the filesystem for the container's rootfs.	|
| kube.container.rootfs.inodes_used	| integer	| | Represents the used inodes in the filesystem for the container's rootfs.	|
| kube.container.logs.available_bytes	| float |	bytes	AvailableBytes represents the storage space available, in bytes,
for the filesystem for the container's logs.	|
| kube.container.logs.capacity_bytes	| float	| bytes	 | Represents the total capacity (bytes) of the filesystems 
underlying storage for the container's logs.	|
| kube.container.logs.used_bytes	| float	| bytes	| UsedBytes represents the bytes used for a specific task on the 
filesystem for the container's logs.	|
| kube.container.logs.inodes_free	| integer | |	Represents the free inodes in the filesystem for the container's logs.	|
| kube.container.logs.inodes	| integer	| | Represents the inodes in the filesystem for the container's logs.	|
| kube.container.logs.inodes_used	| integer | |	Represents the used inodes in the filesystem for the container's logs.	|


 Stats Metrics
| Metric Name |	Metric Type	| Metric Format	| Metric Description |
| --- | --- | --- | --- | 
| kube.node.cpu.cfs.periods | ThrottlingData | uint64 | Cpu Completely Fair Scheduler statistics;
Total number of elapsed enforcement intervals. |
| kube.node.cpu.cfs.throttled_periods | ThrottlingData | uint64 | Cpu Completely Fair Scheduler statistics; Total 
number of times tasks in the cgroup have been throttled. |
| kube.node.cpu.cfs.throttled_time | ThrottlingData | uint64 | Cpu Completely Fair Scheduler statistics; Total time 
duration, in nanoseconds, for which tasks in the cgroup have been throttled. |
| kube.node.cpu.usage.total | CPUUsage | uint64 | CPU usage time statistics in nanoseconds. |
| per_cpu_usage | CPUUsage | []uint64 | CPU usage time statistics. Per CPU/core usage of the container in nanoseconds. |
| kube.node.cpu.usage.user | CPUUsage | uint64 | CPU usage time statistics. Time spent in user space in nanoseconds. |
| kube.node.cpu.usage.system | CPUUsage | uint64 | CPU usage time statistics. Time spent in kernel space in nanoseconds. |
| kube.node.cpu.load_average | | | Smoothed average of number of runnable threads x 1000. Splunk software multiplies by 
a thousand to avoid using floats while preserving precision. Load is smoothed over the last 10 seconds. Instantaneous value can be read from LoadStats.NrRunning. |
| kube.node.cpu.schedstat.run_time | | | Cpu Aggregated scheduler statistics; time spent on the cpu. |
| kube.node.cpu.schedstat.runqueue_time | | | Cpu Aggregated scheduler statistics; time spent waiting on a runqueue. |
| kube.node.cpu.schedstat.run_periods | | | Cpu Aggregated scheduler statistics; # of timeslices run on this cpu reservation
| kube.node.diskio.<disk_category>.stats.Async | | | No Description in code |
| kube.node.diskio.<disk_category>.stats.Read	| | | No Description in code |
| kube.node.diskio.<disk_category>.Sync	| | | No Description in code |
| kube.node.diskio.<disk_category>.stats.Total	| | | No Description in code |
| kube.node.diskio.<disk_category>.stats.Write| | | No Description in code |
| kube.node.diskio.<disk_category>.minor | | | No Description in code |
| kube.node.diskio.<disk_category>.major	| | | No Description in code |
| kube.node.filesystem.available | | | Number of bytes available for non-root user. |
| kube.node.filesystem.base_usage	| | | Base Usage that is consumed by the container's writable layer. This field is 
only applicable for docker container's as of now. |
| kube.node.filesystem.capacity	| | | Number of bytes that can be consumed by the container on this filesystem. |
| kube.node.filesystem.inodes	| | | Number of Inodes |
| kube.node.filesystem.inodes_free | | | Number of available Inodes |
| kube.node.filesystem.io_in_progress | | | Number of I/Os currently in progress. It is the only field that 
should go to zero. Value is incremented as requests are given to appropriate struct request_queue and decremented 
as they finish. |
| kube.node.filesystem.io_time | | | Number of milliseconds spent doing I/Os. This field increases so long as field 
9 is nonzero. |
| kube.node.filesystem.read_time | | | Number of milliseconds spent reading - total number of milliseconds spent 
by all reads (as measured from __make_request() to end_that_request_last()). |
| kube.node.filesystem.reads_completed	| | | The total number of reads completed successfully. |
| kube.node.filesystem.reads_merged	| | | Number of reads merged; Reads and writes which are adjacent to each other 
and may be merged for efficiency. For example, two 4K reads may become one 8K read before it is ultimately handed to 
the disk, and so it will be counted (and queued) as only one I/O. This field lets you know how often this was done. |
| kube.node.filesystem.sectors_read	| | | Total number of sectors successfully read. |
| kube.node.filesystem.sectors_written | | | This is the total number of sectors successfully written. |
| kube.node.filesystem.usage | | | Number of bytes that is consumed by the container on this filesystem. |
| kube.node.filesystem.weighted_io_time	| | | Weighted number of milliseconds spent doing I/Os. This field is 
incremented at each I/O start, I/O completion, I/O merge. Or the field can read of these stats by the number of I/Os in progress (field 9) times the number of milliseconds spent doing I/O since the last update of this field. This can provide an 
easy measure of both I/O completion time and the backlog that may be accumulating. |
| kube.node.filesystem.write_time	| | | Total number of milliseconds spent by all writes, as measured 
from __make_request() to end_that_request_last(). |
| kube.node.filesystem.writes_completed	| | | Total number of writes completed successfully. |
| kube.node.filesystem.writes_merged	| | | Number of writes merged. |
| kube.node.memory.cache	| | | Number of bytes of page cache memory in bytes. |
| kube.node.memory.container_data.pgfault	| | | No Description in code. |
| kube.node.memory.container_data.pgmajfault	| | | No Description in code |
| kube.node.memory.failcnt	| | | No Description in code |
| kube.node.memory.hierarchical_data.pgfault	| | | No Description in code |
| kube.node.memory.hierarchical_data.pgmajfault	| | | No Description in code |
| kube.node.memory.max_usage	| | | Maximum memory usage recorded in bytes. |
| kube.node.memory.rss	| | | The amount of anonymous and swap cache memory (includes transparent
hugepages) in bytes.
| kube.node.memory.swap	| | | The amount of swap, in bytes, currently used by the processes in this cgroup. |
| kube.node.memory.usage	| | | Current memory usage, in bytes. This includes all memory regardless of when it was accessed. |
| kube.node.memory.working_set	| | | The amount of working set memory in bytes. This includes recently accessed memory, 
dirty memory, and kernel memory. Working set is <= "usage". |
| kube.node.memory.mapped_file	| | | |
| kube.node.tasks_stats.nr_io_wait | | | Number of tasks waiting on IO. |
| kube.node.tasks_stats.nr_running	| | | Number of running tasks. |
| kube.node.tasks_stats.nr_sleeping	| | | Number of sleeping tasks. |
| kube.node.tasks_stats.nr_stopped	| | | Number of tasks in stopped state. |
| kube.node.tasks_stats.nr_uninterruptible | | | Number of tasks in uninterruptible state. | 
| kube.node.network.<interface_id>.rx_bytes	| | | Cumulative count of bytes received. |
| kube.node.network.<interface_id>.rx_dropped	| | | Cumulative count of packets dropped while receiving. |
| kube.node.network.<interface_id>.rx_errors	| | | Cumulative count of receive errors encountered. |
| kube.node.network.<interface_id>.rx_packets	| | | Cumulative count of packets received. |
| kube.node.network.<interface_id>.tx_bytes	| | | Cumulative count of bytes transmitted. |
| kube.node.network.<interface_id>.tx_dropped	| | | Cumulative count of packets dropped while transmitting. |
| kube.node.network.<interface_id>.tx_errors	| | | Cumulative count of transmit errors encountered. |
| kube.node.network.<interface_id>.tx_packets	| | |  Cumulative count of packets transmitted. |




 # Cadvisor Metrics

 | Metric Name	| Metric Description |
| cadvisor_version_info | A metric with a constant '1' value labeled by kernel version, OS version, docker version, 
cadvisor version & cadvisor revision.	|
| container_cpu_load_average_10s	| Value of container cpu load average over the last 10 seconds.	|
| container_cpu_system_seconds_total	| Cumulative system cpu time consumed in seconds.	|
| container_cpu_usage_seconds_total	| Cumulative cpu time consumed in seconds.	|
| container_cpu_user_seconds_total	| Cumulative user cpu time consumed in seconds.	|
| container_fs_inodes_free	| Number of available Inodes. |	
| container_fs_inodes_total	| Number of Inodes in use. |	
| container_fs_io_current	| Number of I/Os currently in progress. |	      
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
| container_network_udp_usage_total	| udp connection usage statistic for container. |	
| container_scrape_error	| 1 if there was an error while getting container metrics, 0 otherwise. |	
| container_spec_cpu_period	| CPU period of the container.	|
| container_spec_cpu_shares	| CPU share of the container.	|
| container_spec_memory_limit_bytes	| Memory limit for the container.	|
| container_spec_memory_reservation_limit_bytes	| Memory reservation limit for the container.	|
| container_spec_memory_swap_limit_bytes	| Memory swap limit for the container.	|
| container_start_time_seconds	| Start time of the container since unix epoch in seconds.	|
| container_tasks_state	| Number of tasks in given state.	|
| machine_cpu_cores	| Number of CPU cores on the machine.	|
| machine_memory_bytes	| Amount of memory installed on the machine.	|
| container_cpu_cfs_throttled_seconds_total	| Total time duration the container has been throttled.	|

