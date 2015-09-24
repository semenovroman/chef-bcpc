#
# Cookbook Name:: bcpc
# Recipe:: diamond
#
# Copyright 2013, Bloomberg Finance L.P.
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

if node['bcpc']['enabled']['metrics'] then

    include_recipe "bcpc::default"

    cookbook_file "/tmp/diamond.deb" do
        source "bins/diamond.deb"
        owner "root"
        mode 00444
    end

    %w{python-support python-configobj python-pip python-httplib2}.each do |pkg|
        package pkg do
            action :upgrade
        end
    end

    package "diamond" do
        provider Chef::Provider::Package::Dpkg
        source "/tmp/diamond.deb"
        action :upgrade
        options "--force-confold --force-confdef"
    end

    if node['bcpc']['virt_type'] == "kvm"
        package "ipmitool" do
            action :upgrade
        end
        package "smartmontools" do
            action :upgrade
        end
    end

    cookbook_file "/tmp/pyrabbit-1.0.1.tar.gz" do
        source "bins/pyrabbit-1.0.1.tar.gz"
        owner "root"
        mode 00444
    end

    bash "install-pyrabbit" do
        code <<-EOH
            pip install /tmp/pyrabbit-1.0.1.tar.gz
        EOH
        not_if "pip freeze|grep pyrabbit"
    end

    bash "diamond-set-user" do
        user "root"
        code <<-EOH
            sed --in-place '/^DIAMOND_USER=/d' /etc/default/diamond
            echo 'DIAMOND_USER="root"' >> /etc/default/diamond
        EOH
        not_if "grep -e '^DIAMOND_USER=\"root\"' /etc/default/diamond"
        notifies :restart, "service[diamond]", :delayed
    end

    template "/etc/diamond/diamond.conf" do
        source "diamond.conf.erb"
        owner "diamond"
        group "root"
        mode 00600
        variables(:servers => get_head_nodes)
        notifies :restart, "service[diamond]", :delayed
    end

    template "/etc/diamond/collectors/ElasticSearchCollector.conf" do
        source "diamond-collector-elasticsearch.conf.erb"
        owner "diamond"
        group "root"
        mode 00600
        notifies :restart, "service[diamond]", :delayed
        only_if "test -f /etc/init.d/elasticsearch"
    end

    # required by diamond openstack collector
    package "python-mysql.connector" do
        action :upgrade
    end

    directory '/usr/share/diamond/collectors/BC2/' do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
    end

    cookbook_file "/usr/share/diamond/collectors/BC2/BC2.py" do
        source "diamond-collector-BC2-openstack.py"
        owner "root"
        mode 00644
    end

    service "diamond" do
        action [:enable, :start]
    end

end
