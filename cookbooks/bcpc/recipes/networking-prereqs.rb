#
# Cookbook Name:: bcpc
# Recipe:: networking-prereqs
#
# Copyright 2016, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "bcpc::default"
include_recipe "bcpc::system"
include_recipe "bcpc::certs"

template "/etc/hosts" do
  source "hosts.erb"
  mode 00644
  variables(
    :servers => get_all_nodes,
    :bootstrap_node => get_bootstrap_node
  )
end

template "/etc/ssh/sshd_config" do
  source "sshd_config.erb"
  mode 00644
  notifies :restart, "service[ssh]", :immediately
end

%w{ ssh cron}.each do |svc|
  service svc do
    action [:enable, :start]
  end
end

package "vlan"

# Enable LLDP - see https://github.com/bloomberg/chef-bcpc/pull/120
package "lldpd"

bash "enable-mellanox" do
  user "root"
  code <<-EOH
    if [ -z "`lsmod | grep mlx4_en`" ]; then
      modprobe mlx4_en
    fi
    if [ -z "`grep mlx4_en /etc/modules`" ]; then
      echo "mlx4_en" >> /etc/modules
    fi
  EOH
  only_if "lspci | grep Mellanox"
end

directory "/etc/network/interfaces.d" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

# changed to be *.cfg to align this with what Vagrant does
bash "setup-interfaces-source" do
  user "root"
  code <<-EOH
    echo "source /etc/network/interfaces.d/*.cfg" >> /etc/network/interfaces
  EOH
  not_if "grep '^source /etc/network/interfaces.d/*.cfg' /etc/network/interfaces"
end

bash "enable-8021q" do
  user "root"
  code <<-EOH
    modprobe 8021q
    sed --in-place '/^8021q/d' /etc/modules
    echo '8021q' >> /etc/modules
  EOH
  not_if "grep -e '^8021q' /etc/modules"
end

if node['bcpc']['enabled']['neutron']
  template "/etc/network/interfaces.d/iface-#{node['bcpc']['management']['interface']}.cfg" do
    source "network.iface.erb"
    owner "root"
    group "root"
    mode 00644
    variables(
      :interface => node['bcpc']['management']['interface'],
      :type => 'static',
      :ip => node['bcpc']['management']['ip'],
      :netmask => node['bcpc']['management']['netmask'],
      :gateway => node['bcpc']['management']['gateway'],
      :mtu => node['bcpc']['management']['mtu'],
      :metric => 100
    )
  end

  # storage interface split from above while tinkering with whether it should have a gateway
  template "/etc/network/interfaces.d/iface-#{node['bcpc']['storage']['interface']}.cfg" do
    source "network.iface.erb"
    owner "root"
    group "root"
    mode 00644
    variables(
      :interface => node['bcpc']['storage']['interface'],
      :type => 'static',
      :ip => node['bcpc']['storage']['ip'],
      :netmask => node['bcpc']['storage']['netmask'],
      :gateway => node['bcpc']['storage']['gateway'],
      :mtu => node['bcpc']['storage']['mtu'],
      :metric => 300
    )
  end

  # storage interface split from above while tinkering with whether it should have a gateway
  template "/etc/network/interfaces.d/iface-#{node['bcpc']['floating']['interface']}.cfg" do
    source "network.iface.erb"
    owner "root"
    group "root"
    mode 00644
    variables(
      :interface => node['bcpc']['floating']['interface'],
      :type => 'static',
      :ip => node['bcpc']['floating']['ip'],
      :netmask => node['bcpc']['floating']['netmask'],
      :gateway => node['bcpc']['floating']['gateway'],
      :mtu => node['bcpc']['floating']['mtu'],
      :metric => 300
    )
  end

  # for Neutron, configure eth4 as a manual interface (so that it can be up but
  # does not get an address)
  #template "/etc/network/interfaces.d/iface-eth4.cfg" do
#    source "network.iface.erb"
#    owner "root"
#    group "root"
#    mode 00644
#    variables(
#      :interface => 'eth4',
#      :type => 'manual',
#      :mtu => node['bcpc']['floating']['mtu'],
#    )
#  end

#  bash 'ifup-eth4' do
#    code 'ifup eth4'
#  end
else
  [['management', 100], ['storage', 300]].each do |net, metric|
    template "/etc/network/interfaces.d/iface-#{node['bcpc'][net]['interface']}.cfg" do
      source "network.iface.erb"
      owner "root"
      group "root"
      mode 00644
      variables(
        :interface => node['bcpc'][net]['interface'],
        :ip => node['bcpc'][net]['ip'],
        :netmask => node['bcpc'][net]['netmask'],
        :gateway => node['bcpc'][net]['gateway'],
        :mtu => node['bcpc'][net]['mtu'],
        :metric => metric
      )
    end
  end
end

%w{ storage floating }.each do |net|
  unless node['bcpc'][net]['interface-parent'].nil?
    template "/etc/network/interfaces.d/iface-#{node['bcpc'][net]['interface-parent']}.cfg" do
      source "network.iface-parent.erb"
      owner "root"
      group "root"
      mode 00644
      variables(
        :interface => node['bcpc'][net]['interface-parent'],
        :mtu => node['bcpc'][net]['mtu'],
      )
    end
  end
end

# set up the DNS resolvers
# we want the VIP which will be running powerdns to be first on the list
# but the first entry in our master list is also the only one in pdns,
# so make that the last entry to minimize double failures when upstream dies.
resolvers=node['bcpc']['dns_servers'].dup
resolvers.push resolvers.shift
resolvers.unshift node['bcpc']['management']['vip']

# do not give the instance traffic interface an IP under the Neutron model
unless node['bcpc']['enabled']['neutron']
  template "/etc/network/interfaces.d/iface-#{node['bcpc']['floating']['interface']}" do
    source "network.iface.erb"
    owner "root"
    group "root"
    mode 00644
    variables(
      :interface => node['bcpc']['floating']['interface'],
      :ip => node['bcpc']['floating']['ip'],
      :netmask => node['bcpc']['floating']['netmask'],
      :gateway => node['bcpc']['floating']['gateway'],
      :dns => resolvers,
      :mtu => node['bcpc']['floating']['mtu'],
      :metric => 200
    )
  end
end

dhcp_resolvconf_hook="/etc/dhcp/dhclient-enter-hooks.d/resolvconf"
bash "disable-dhclient-resolvconf-enter-hook" do
  user "root"
  code <<-EOH
    gzip #{dhcp_resolvconf_hook}
    resolvconf --enable-updates
    resolvconf -d #{node['bcpc']['management']['interface']}.dhclient
  EOH
  only_if { ::File.exists?(dhcp_resolvconf_hook) }
end

bash "interface-mgmt-make-static-if-dhcp" do
  user "root"
  code <<-EOH
    sed --in-place '/\\(.*#{node['bcpc']['management']['interface']}.*\\)/d' /etc/network/interfaces
    resolvconf -d #{node['bcpc']['management']['interface']}.dhclient
  EOH
  only_if "cat /etc/network/interfaces | grep #{node['bcpc']['management']['interface']} | grep dhcp"
end

ifs_to_bring_up = node['bcpc']['enabled']['neutron'] ? %w{ management storage } : %w{ management storage floating }

ifs_to_bring_up.each do |iface|
  unless node['bcpc'][iface]['interface-parent'].nil?
    bash "#{iface} up" do
      user "root"
      code <<-EOH
        ifup #{node['bcpc'][iface]['interface-parent']}
      EOH
      not_if "ip link show up | grep #{node['bcpc'][iface]['interface-parent']} | grep -v #{node['bcpc'][iface]['interface']}"
    end
    if node['bcpc'][iface]['mtu']
      execute "set-#{iface}-mtu" do
        command "ifconfig #{node['bcpc'][iface]['interface-parent']} mtu #{node['bcpc'][iface]['mtu']} up"
        not_if  "ifconfig #{node['bcpc'][iface]['interface-parent']} | grep MTU:#{node['bcpc'][iface]['mtu']}"
      end
    end
  end

  bash "#{iface} up" do
    user "root"
    code <<-EOH
      ifup #{node['bcpc'][iface]['interface']}
    EOH
    not_if "ip link show up | grep #{node['bcpc'][iface]['interface']}"
  end

  if node['bcpc'][iface]['mtu']
    execute "set-#{iface}-mtu" do
      command "ifconfig #{node['bcpc'][iface]['interface']} mtu #{node['bcpc'][iface]['mtu']} up"
      not_if  "ifconfig #{node['bcpc'][iface]['interface']} | grep MTU:#{node['bcpc'][iface]['mtu']}"
    end
  end
end

unless node['bcpc']['enabled']['neutron']
  bash "routing-management" do
    user "root"
    code "echo '1 mgmt' >> /etc/iproute2/rt_tables"
    not_if "grep -e '^1 mgmt' /etc/iproute2/rt_tables"
  end

  bash "routing-storage" do
    user "root"
    code "echo '2 storage' >> /etc/iproute2/rt_tables"
    not_if "grep -e '^2 storage' /etc/iproute2/rt_tables"
  end

  %w{ routing firewall }.each do |function|
    template "/etc/network/if-up.d/bcpc-#{function}" do
      mode 00775
      source "bcpc-#{function}.erb"
      notifies :run, "execute[run-#{function}-script-once]", :immediately
    end

    execute "run-#{function}-script-once" do
      action :nothing
      command "/etc/network/if-up.d/bcpc-#{function}"
    end
  end
end

# for the moment, explode on the confluence of Neutron and monitoring
if node['roles'].include?('BCPC-Monitoring') and node['bcpc']['enabled']['neutron']
  raise Exception, "BCPC-Monitoring role and Neutron are mutually exclusive for the time being"
end

if node["roles"].include? "BCPC-Monitoring"
  # ipset is used to maintain largish block(s) of IP addresses to be referred to
  # by iptables
  package "ipset"

  bash "create-ipset-lists" do
    user "root"
    code <<-EOH
      ipset list monitoring-clients >/dev/null || ipset create monitoring-clients hash:ip
    EOH
  end

  # Stage monitoring-clients ipset, and swap if lists have changed
  template "/tmp/ipset-monitoring-clients" do
    mode 00600
    source "ipset-monitoring-clients.erb"
    variables(
      :clients => node['bcpc']['monitoring']['external_clients'].sort
    )
    notifies :run, "bash[apply-ipset-monitoring-clients]", :immediately
  end

  bash "apply-ipset-monitoring-clients" do
    action :nothing
    user "root"
    code <<-EOH
        ipset restore -f /tmp/ipset-monitoring-clients
        ipset swap monitoring-clients-staging monitoring-clients
        ipset destroy monitoring-clients-staging
    EOH
  end
end

bash "disable-noninteractive-pam-logging" do
    user "root"
    code "sed --in-place 's/^\\(session\\s*required\\s*pam_unix.so\\)/#\\1/' /etc/pam.d/common-session-noninteractive"
    only_if "grep -e '^session\\s*required\\s*pam_unix.so' /etc/pam.d/common-session-noninteractive"
end
