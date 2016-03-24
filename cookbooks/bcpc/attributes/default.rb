###########################################
#
#  General configuration for this cluster
#
###########################################
default['bcpc']['country'] = "US"
default['bcpc']['state'] = "NY"
default['bcpc']['location'] = "New York"
default['bcpc']['organization'] = "Bloomberg"
default['bcpc']['openstack_release'] = "liberty"
# Can be "updates" or "proposed"
default['bcpc']['openstack_branch'] = "proposed"
# Should be kvm (or qemu if testing in VMs that don't support VT-x)
default['bcpc']['virt_type'] = "kvm"
# Define the kernel to be installed. By default, track latest LTS kernel
default['bcpc']['preseed']['kernel'] = "linux-image-generic-lts-trusty"
# ulimits for libvirt-bin
default['bcpc']['libvirt-bin']['ulimit']['nofile'] = 4096
# Region name for this cluster
default['bcpc']['region_name'] = node.chef_environment
# Domain name for this cluster (used in many configs)
default['bcpc']['cluster_domain'] = "bcpc.example.com"
# Hypervisor domain (domain used by actual machines)
default['bcpc']['hypervisor_domain'] = "hypervisor-bcpc.example.com"
# Key if Cobalt+VMS is to be used
default['bcpc']['vms_key'] = nil
# custom SSL certificate (specify filename).
# certificate files should be stored under 'files/default' directory
default['bcpc']['ssl_certificate'] = nil
default['bcpc']['ssl_private_key'] = nil
default['bcpc']['ssl_intermediate_certificate'] = nil
# custom SSL certificate for Rados Gateway (S3)
default['bcpc']['s3_ssl_certificate'] = nil
default['bcpc']['s3_ssl_private_key'] = nil
default['bcpc']['s3_ssl_intermediate_certificate'] = nil

###########################################
#
#  Flags to enable/disable BCPC cluster features
#
###########################################
# This will enable elasticsearch & kibana on head nodes and fluentd on all nodes
default['bcpc']['enabled']['logging'] = true
# This will enable graphite web and carbon on head nodes and diamond on all nodes
default['bcpc']['enabled']['metrics'] = true
# This will enable zabbix server on head nodes and zabbix agent on all nodes
default['bcpc']['enabled']['monitoring'] = true
# This will enable powerdns on head nodes
default['bcpc']['enabled']['dns'] = true
# This will enable iptables firewall on all nodes
# TODO: make this work with Calico
default['bcpc']['enabled']['host_firewall'] = false
# This will enable of encryption of the chef data bag
default['bcpc']['enabled']['encrypt_data_bag'] = false
# These will enable automatic dist-upgrade/upgrade at the start of a Chef run
# (not recommended for stability)
default['bcpc']['enabled']['apt_dist_upgrade'] = false
default['bcpc']['enabled']['apt_upgrade'] = false
# This will enable running apt-get update at the start of every Chef run
default['bcpc']['enabled']['always_update_package_lists'] = true
# This will enable the extra healthchecks for keepalived (VIP management)
default['bcpc']['enabled']['keepalived_checks'] = true
# This will enable the networking test scripts
default['bcpc']['enabled']['network_tests'] = true
# This will enable using TPM-based hwrngd
default['bcpc']['enabled']['tpm'] = false
# This will block VMs from talking to the management network
default['bcpc']['enabled']['secure_fixed_networks'] = true
# Toggle to enable/disable swap memory
default['bcpc']['enabled']['swap'] = true
# Toggle to enable/disable Heat (OpenStack Cloud Formation)
default['bcpc']['enabled']['heat'] = false
# Toggle to switch between Neutron and Nova networking
default['bcpc']['enabled']['neutron'] = true

###########################################
#
#  Host-specific defaults for the cluster
#
###########################################
default['bcpc']['ceph']['hdd_disks'] = ["sdb", "sdc"]
default['bcpc']['ceph']['ssd_disks'] = ["sdd", "sde"]
default['bcpc']['ceph']['enabled_pools'] = ["ssd", "hdd"]
default['bcpc']['management']['interface'] = "eth0"
default['bcpc']['storage']['interface'] = "eth1"
default['bcpc']['floating']['interface'] = "eth2"
default['bcpc']['fixed']['vlan_interface'] = node['bcpc']['floating']['interface']

###########################################
#
# RabbitMQ settings
#
###########################################
# if changing this setting, you will need to reset Mnesia
# on all RabbitMQ nodes in the cluster
default['bcpc']['rabbitmq']['durable_queues'] = true
# ulimits for RabbitMQ server
default['bcpc']['rabbitmq']['ulimit']['nofile'] = 4096
# Heartbeat timeout to detect dead RabbitMQ brokers
default['bcpc']['rabbitmq']['heartbeat'] = 60

###########################################
#
#  Network settings for the cluster
#
###########################################
default['bcpc']['management']['vip'] = "10.17.1.15"
default['bcpc']['management']['netmask'] = "255.255.255.0"
default['bcpc']['management']['cidr'] = "10.17.1.0/24"
default['bcpc']['management']['gateway'] = "10.17.1.1"
default['bcpc']['management']['interface'] = nil
# if 'interface' is a VLAN interface, specifying a parent allows MTUs
# to be set properly
default['bcpc']['management']['interface-parent'] = nil
# list of TCP ports that should be open on the management interface
# (generally stuff served via HAProxy)
default['bcpc']['management']['firewall_tcp_ports'] = [
  80,443,8088,7480,5000,35357,9292,8776,8773,8774,8004,8000,8777,6080,9696
]

default['bcpc']['metadata']['ip'] = "169.254.169.254"

default['bcpc']['storage']['vip'] = "100.100.0.5"
default['bcpc']['storage']['netmask'] = "255.255.255.0"
default['bcpc']['storage']['cidr'] = "100.100.0.0/24"
default['bcpc']['storage']['gateway'] = "100.100.0.1"
default['bcpc']['storage']['interface'] = nil
# if 'interface' is a VLAN interface, specifying a parent allows MTUs
# to be set properly
default['bcpc']['storage']['interface-parent'] = nil

default['bcpc']['floating']['vip'] = "192.168.43.15"
default['bcpc']['floating']['netmask'] = "255.255.255.0"
default['bcpc']['floating']['cidr'] = "192.168.43.0/24"
default['bcpc']['floating']['gateway'] = "192.168.43.2"
default['bcpc']['floating']['available_subnet'] = "192.168.43.128/25"
default['bcpc']['floating']['interface'] = nil
# if 'interface' is a VLAN interface, specifying a parent allows MTUs
# to be set properly
default['bcpc']['floating']['interface-parent'] = nil

default['bcpc']['fixed']['cidr'] = "1.127.0.0/16"
default['bcpc']['fixed']['vlan_start'] = "1000"
default['bcpc']['fixed']['num_networks'] = "100"
default['bcpc']['fixed']['network_size'] = "256"
default['bcpc']['fixed']['dhcp_lease_time'] = "120"

default['bcpc']['ntp_servers'] = ["pool.ntp.org"]
default['bcpc']['dns_servers'] = ["8.8.8.8", "8.8.4.4"]

# Proxy server URL for recipes to use
# Example: http://proxy-hostname:port
default['bcpc']['proxy_server_url'] = nil

###########################################
#
#  Repos for things we rely on
#
###########################################
default['bcpc']['repos']['rabbitmq'] = "http://www.rabbitmq.com/debian"
default['bcpc']['repos']['mysql'] = "http://repo.percona.com/apt"
default['bcpc']['repos']['haproxy'] = "http://ppa.launchpad.net/vbernat/haproxy-1.5/ubuntu"
default['bcpc']['repos']['openstack'] = "http://ubuntu-cloud.archive.canonical.com/ubuntu"
default['bcpc']['repos']['hwraid'] = "http://hwraid.le-vert.net/ubuntu"
default['bcpc']['repos']['fluentd'] = "http://packages.treasure-data.com/2/ubuntu/#{node['lsb']['codename']}"
default['bcpc']['repos']['gridcentric'] = "http://downloads.gridcentric.com/packages/%s/%s/ubuntu"
default['bcpc']['repos']['elasticsearch'] = "http://packages.elasticsearch.org/elasticsearch/1.5/debian"
default['bcpc']['repos']['kibana'] = "http://packages.elasticsearch.org/kibana/4.1/debian"
default['bcpc']['repos']['erlang'] = "http://packages.erlang-solutions.com/ubuntu"
default['bcpc']['repos']['ceph'] = "http://download.ceph.com/debian-hammer"
default['bcpc']['repos']['zabbix'] = "http://repo.zabbix.com/zabbix/2.4/ubuntu"
default['bcpc']['repos']['calico'] = "http://ppa.launchpad.net/project-calico/stable/ubuntu"
default['bcpc']['repos']['bird'] = "http://ppa.launchpad.net/cz.nic-labs/bird/ubuntu"

###########################################
#
# [Optional] If using apt-mirror to pull down repos, we use these settings.
#
###########################################
# Note - us.archive.ubuntu.com tends to rate-limit pretty hard.
# If you are on East Coast US, we recommend Columbia University in env file:
# "mirror" : {
#  "ubuntu": "mirror.cc.columbia.edu/pub/linux/ubuntu/archive"
# }
# For a complete list of Ubuntu mirrors, please see:
# https://launchpad.net/ubuntu/+archivemirrors
default['bcpc']['mirror']['ubuntu'] = "us.archive.ubuntu.com/ubuntu"
default['bcpc']['mirror']['ubuntu-dist'] = ['trusty']
default['bcpc']['mirror']['ceph-dist'] = ['hammer']
default['bcpc']['mirror']['os-dist'] = ['kilo']
default['bcpc']['mirror']['elasticsearch-dist'] = '1.5'
default['bcpc']['mirror']['kibana-dist'] = '4.1'

###########################################
#
#  Default names for db's, pools, and users
#
###########################################
default['bcpc']['dbname']['nova'] = "nova"
default['bcpc']['dbname']['cinder'] = "cinder"
default['bcpc']['dbname']['glance'] = "glance"
default['bcpc']['dbname']['horizon'] = "horizon"
default['bcpc']['dbname']['keystone'] = "keystone"
default['bcpc']['dbname']['neutron'] = "neutron"
default['bcpc']['dbname']['heat'] = "heat"
default['bcpc']['dbname']['ceilometer'] = "ceilometer"
default['bcpc']['dbname']['graphite'] = "graphite"
default['bcpc']['dbname']['pdns'] = "pdns"
default['bcpc']['dbname']['zabbix'] = "zabbix"

default['bcpc']['admin_tenant'] = "AdminTenant"
default['bcpc']['admin_role'] = "Admin"
default['bcpc']['member_role'] = "Member"
default['bcpc']['admin_email'] = "admin@localhost.com"

default['bcpc']['zabbix']['user'] = "zabbix"
default['bcpc']['zabbix']['group'] = "adm"

# General ports for Civetweb backend and HAProxy frontend
default['bcpc']['ports']['radosgw'] = 8088
default['bcpc']['ports']['radosgw_https'] = 443
default['bcpc']['ports']['haproxy']['radosgw'] = 80
default['bcpc']['ports']['haproxy']['radosgw_https'] = 443

# Can be set to 'http' or 'https'
default['bcpc']['protocol']['keystone'] = "https"
default['bcpc']['protocol']['glance'] = "https"
default['bcpc']['protocol']['nova'] = "https"
default['bcpc']['protocol']['cinder'] = "https"
default['bcpc']['protocol']['neutron'] = "https"
default['bcpc']['protocol']['heat'] = "https"


###########################################
#
#  Horizon Settings
#
###########################################
#
# List panels to remove from the Horizon interface here
# (if the last panel in a group is removed, the group will also be removed)
default['bcpc']['horizon']['disable_panels'] = ['containers']

###########################################
#
#  Keystone Settings
#
###########################################
#
# Defaut log file
default['bcpc']['keystone']['log_file'] = '/var/log/keystone/keystone.log'
# Eventlet server is deprecated in Kilo, so by default we
# serve Keystone via Apache now.
default['bcpc']['keystone']['eventlet_server'] = false
# Turn caching via memcached on or off.
default['bcpc']['keystone']['enable_caching'] = true
# Enable debug logging (also caching debug logging).
default['bcpc']['keystone']['debug'] = false
# Enable verbose logging.
default['bcpc']['keystone']['verbose'] = false
# Set the timeout for how long we will wait for Keystone to become operational
# before failing (configures timeout on the wait-for-keystone-to-be-operational
# spinlock guard).
default['bcpc']['keystone']['wait_for_keystone_timeout'] = 120
# Set the number of Keystone WSGI processes and threads to use by default on the
# public API (experimentally threads > 1 may cause problems with the service
# catalog, for now we recommend scaling only in the processes dimension)
default['bcpc']['keystone']['wsgi']['processes'] = 5
default['bcpc']['keystone']['wsgi']['threads'] = 1
# The driver section below allows either 'sql' or 'ldap' (or 'templated' for catalog)
# Note that not all drivers may support SQL/LDAP, only tinker if you know what you're getting into
default['bcpc']['keystone']['drivers']['assignment'] = 'sql'
default['bcpc']['keystone']['drivers']['catalog'] = 'sql'
default['bcpc']['keystone']['drivers']['credential'] = 'sql'
default['bcpc']['keystone']['drivers']['domain_config'] = 'sql'
default['bcpc']['keystone']['drivers']['endpoint_filter'] = 'sql'
default['bcpc']['keystone']['drivers']['endpoint_policy'] = 'sql'
default['bcpc']['keystone']['drivers']['federation'] = 'sql'
default['bcpc']['keystone']['drivers']['identity'] = 'sql'
default['bcpc']['keystone']['drivers']['identity_mapping'] = 'sql'
default['bcpc']['keystone']['drivers']['oauth1'] = 'sql'
default['bcpc']['keystone']['drivers']['policy'] = 'sql'
default['bcpc']['keystone']['drivers']['revoke'] = 'sql'
default['bcpc']['keystone']['drivers']['role'] = 'sql'
default['bcpc']['keystone']['drivers']['trust'] = 'sql'
# Notifications driver
default['bcpc']['keystone']['drivers']['notification'] = 'log'
# Notifications format. See: http://docs.openstack.org/developer/keystone/event_notifications.html
default['bcpc']['keystone']['notification_format'] = 'cadf'
# LDAP credentials used by Keystone
default['bcpc']['ldap']['admin_user'] = nil
default['bcpc']['ldap']['admin_pass'] = nil
default['bcpc']['ldap']['config'] = {}

###########################################
#
#  Nova Settings
#
###########################################
#
# Over-allocation settings. Set according to your cluster
# SLAs. Default is to not allow over allocation of memory
# a slight over allocation of CPU (x2).
default['bcpc']['nova']['ram_allocation_ratio'] = 1.0
default['bcpc']['nova']['reserved_host_memory_mb'] = 1024
default['bcpc']['nova']['cpu_allocation_ratio'] = 2.0
# select from between this many equally optimal hosts when launching an instance
default['bcpc']['nova']['scheduler_host_subset_size'] = 3
# "workers" parameters in nova are set to number of CPUs
# available by default. This provides an override.
default['bcpc']['nova']['workers'] = 5
# Patch toggle for https://github.com/bloomberg/chef-bcpc/pull/493
default['bcpc']['nova']['live_migration_patch'] = false
# frequency of syncing power states between hypervisor and database
default['bcpc']['nova']['sync_power_state_interval'] = 600
# automatically restart guests that were running when hypervisor was rebooted
default['bcpc']['nova']['resume_guests_state_on_host_boot'] = false
# Verbose logging (level INFO)
default['bcpc']['nova']['verbose'] = false
# Nova debug toggle
default['bcpc']['nova']['debug'] = false
# Nova default log levels
default['bcpc']['nova']['default_log_levels'] = nil
# Nova scheduler default filters
default['bcpc']['nova']['scheduler_default_filters'] = ['AggregateInstanceExtraSpecsFilter', 'RetryFilter', 'AvailabilityZoneFilter', 'RamFilter', 'ComputeFilter', 'ComputeCapabilitiesFilter', 'ImagePropertiesFilter', 'ServerGroupAntiAffinityFilter', 'ServerGroupAffinityFilter']

# configure optional Nova notification system
default['bcpc']['nova']['notifications']['enabled'] = false
default['bcpc']['nova']['notifications']['notification_topics'] = 'notifications'
default['bcpc']['nova']['notifications']['notification_driver'] = 'messagingv2'
default['bcpc']['nova']['notifications']['notify_on_state_change'] = 'vm_state'

# settings pertaining to ephemeral storage via mdadm/LVM
# (software RAID settings are here for logical grouping)
default['bcpc']['software_raid']['enabled'] = false
# define devices to RAID together in the hardware role for a type (e.g., BCPC-Hardware-Virtual)
default['bcpc']['software_raid']['devices'] = []
default['bcpc']['software_raid']['md_device'] = '/dev/md/md0'
default['bcpc']['software_raid']['chunk_size'] = 512
default['bcpc']['nova']['ephemeral'] = false
default['bcpc']['nova']['ephemeral_vg_name'] = 'nova_disk'
default['bcpc']['nova']['ephemeral_disks'] = [default['bcpc']['software_raid']['md_device']]

default['bcpc']['nova']['quota'] = {
  "cores" => 4,
  "floating_ips" => 10,
  "gigabytes"=> 1000,
  "instances" => -1,
  "ram" => 8192
}
# load a custom vendor driver,
# e.g. "nova.api.metadata.bcpc_metadata.BcpcMetadata",
# comment out to use default
#default['bcpc']['vendordata_driver'] = "nova.api.metadata.bcpc_metadata.BcpcMetadata"

###########################################
#
#  Cinder Settings
#
###########################################
# Verbose logging (level INFO)
default['bcpc']['cinder']['verbose'] = false
default['bcpc']['cinder']['debug'] = false
default['bcpc']['cinder']['workers'] = 5
default['bcpc']['cinder']['allow_az_fallback'] = true
default['bcpc']['cinder']['rbd_flatten_volume_from_snapshot'] = true
# NOTE: rbd_max_clone_depth is not honored in Kilo
# see https://bugs.launchpad.net/cinder/+bug/1477706
default['bcpc']['cinder']['rbd_max_clone_depth'] = 5
default['bcpc']['cinder']['quota'] = {
  "volumes" => -1,
  "snapshots" => 10,
  "gigabytes" => 1000
}

###########################################
#
# Routemon settings
#
###########################################
#

# numfixes is how many times to try and fix default routes in the mgmt
# and storage networks when they disappear. If numfixes starts off at
# 0, or after 'numfixes' attempts have been made, then routemon
# subsequently only monitors and reports
#
default['bcpc']['routemon']['numfixes'] = 0

###########################################
#
# MySQL settings
#
###########################################
#
# If set to 0, max_connections for MySQL on heads will default to an
# auto-calculated value.
default['bcpc']['mysql-head']['max_connections'] = 0

###########################################
#
# BCPC system (sysctl) settings
#
###########################################
#
# Use this to *add* more reserved ports; i.e. modify value of
# net.ipv4.ip_local_reserved_ports
default['bcpc']['system']['additional_reserved_ports'] = []
# Any other sysctl parameters (register under parameters)
default['bcpc']['system']['parameters']['kernel.pid_max'] = 4194303

###########################################
#
# CPU governor settings
#
###########################################
#
# Available options: conservative, ondemand, userspace, powersave, performance
# Review documentation at https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt
default['bcpc']['cpupower']['governor'] = "ondemand"
default['bcpc']['cpupower']['ondemand_ignore_nice_load'] = nil
default['bcpc']['cpupower']['ondemand_io_is_busy'] = nil
default['bcpc']['cpupower']['ondemand_powersave_bias'] = nil
default['bcpc']['cpupower']['ondemand_sampling_down_factor'] = nil
default['bcpc']['cpupower']['ondemand_sampling_rate'] = nil
default['bcpc']['cpupower']['ondemand_up_threshold'] = nil

###########################################
#
# defaults for the bcpc.bootstrap settings
#
###########################################
#
# A value of nil means to let the Ubuntu installer work it out - it
# will try to find the nearest one. However the selected mirror is
# often slow.
default['bcpc']['bootstrap']['mirror'] = nil
#
# if you do specify a mirror, you can adjust the file path that comes
# after the hostname in the URL here
default['bcpc']['bootstrap']['mirror_path'] = "/ubuntu"
#
# worked example for the columbia mirror mentioned above which has a
# non-standard path
#default['bcpc']['bootstrap']['mirror']      = "mirror.cc.columbia.edu"
#default['bcpc']['bootstrap']['mirror_path'] = "/pub/linux/ubuntu/archive"

###########################################
#
# Rally settings
#
###########################################
#
# Package versions
# None needed at this time
default['bcpc']['rally']['user'] = 'ubuntu'

###########################################
#
# Openstack Flavors
#
###########################################

default['bcpc']['flavors'] = {
    "m1.tiny" => {
      "extra_specs" => { "aggregate_instance_extra_specs:general_compute" => "yes"}
    },
    "m1.small" => {
      "extra_specs" => { "aggregate_instance_extra_specs:general_compute" => "yes"}
    },
    "m1.medium" => {
      "extra_specs" => { "aggregate_instance_extra_specs:general_compute" => "yes"}
    },
    "m1.large" => {
      "extra_specs" => { "aggregate_instance_extra_specs:general_compute" => "yes"}
    },
    "m1.xlarge" => {
      "extra_specs" => { "aggregate_instance_extra_specs:general_compute" => "yes"}
    },
    "e1.tiny" => {
      "vcpus" => 1,
      "memory_mb" => 512,
      "disk_gb" => 1,
      "ephemeral_gb" => 5,
      "extra_specs" => { "aggregate_instance_extra_specs:ephemeral_compute" => "yes"}
    },
    "e1.small" => {
      "vcpus" => 1,
      "memory_mb" => 2048,
      "disk_gb" => 20,
      "ephemeral_gb" => 20,
      "extra_specs" => { "aggregate_instance_extra_specs:ephemeral_compute" => "yes"}
    },
    "e1.medium" => {
      "vcpus" => 2,
      "memory_mb" => 4096,
      "disk_gb" => 40,
      "ephemeral_gb" => 40,
      "extra_specs" => { "aggregate_instance_extra_specs:ephemeral_compute" => "yes"}
    },
    "e1.large" => {
      "vcpus" => 4,
      "memory_mb" => 8192,
      "disk_gb" => 40,
      "ephemeral_gb" => 80,
      "extra_specs" => { "aggregate_instance_extra_specs:ephemeral_compute" => "yes"}
    },
    "e1.xlarge" => {
      "vcpus" => 8,
      "memory_mb" => 16384,
      "disk_gb" => 40,
      "ephemeral_gb" => 160,
      "extra_specs" => { "aggregate_instance_extra_specs:ephemeral_compute" => "yes"}
    },
    "e1.2xlarge" => {
      "vcpus" => 8,
      "memory_mb" => 32768,
      "disk_gb" => 40,
      "ephemeral_gb" => 320,
      "extra_specs" => { "aggregate_instance_extra_specs:ephemeral_compute" => "yes"}
    }
}

###########################################
#
# Openstack Host Aggregates
#
###########################################

default['bcpc']['host_aggregates'] = {
    "general_compute" => {
      "general_compute" => "yes"
    },
    "ephemeral_compute" => {
      "general_compute" => "no",
      "ephemeral_compute" => "yes"
    }
}

default['bcpc']['aggregate_membership'] = []

###########################################
#
# RadosGW Quotas
#
###########################################
default['bcpc']['rgw_quota'] = {
    'user' => {
        'default' => {
           'max_size' => 10737418240
        }
    }
}

###########################################
#
# Openstack Project Quotas
#
###########################################
default['bcpc']['quota'] = {
    'nova' => {
        'AdminTenant' => {
           'cores' => -1
        }
    }
}

###########################################
#
#  Getty settings
#
###########################################
default['bcpc']['getty']['ttys'] = %w( ttyS0 ttyS1 )
###########################################
#
#  VNC settings
#
###########################################
#
# VNC uses cluster domain name by default
# for proxy base url. Set to 'true' to use vip
default['bcpc']['vnc']['proxy_use_vip'] = true
