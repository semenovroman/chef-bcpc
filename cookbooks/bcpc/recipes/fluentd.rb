#
# Cookbook Name:: bcpc
# Recipe:: fluentd
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

if node['bcpc']['enabled']['logging'] then

    include_recipe "bcpc::default"

    apt_repository "fluentd" do
        uri node['bcpc']['repos']['fluentd']
        distribution node['lsb']['codename']
        components ["contrib"]
        arch "amd64"
        key "fluentd.key"
    end

    package "td-agent-v1" do
        package_name "td-agent"
        version "1.1.21-1"
        action :purge
    end

    bash "clean-up-old-fluentd" do
        code <<-EOH
          rm -rf /usr/lib/fluent
        EOH
        only_if 'test -d /usr/lib/fluent'
    end

    # Run td-agent as root
    cookbook_file "/etc/default/td-agent" do
        source "td-agent-default"
        owner "root"
        mode 00644
    end

    package "td-agent" do
        action :upgrade
    end

    fluentd_gems = %w{
      excon-0.45.3
      multi_json-1.11.2
      multipart-post-2.0.0
      faraday-0.9.1
      elasticsearch-transport-1.0.12
      elasticsearch-api-1.0.12
      elasticsearch-1.0.12
      fluent-plugin-elasticsearch-0.9.0
    }

    fluentd_gems.each do |pkg|
      cookbook_file "/tmp/#{pkg}.gem" do
        source "bins/#{pkg}.gem"
        owner "root"
        mode 00444
      end

      bash "install-#{pkg}" do
        code "/opt/td-agent/embedded/bin/fluent-gem install --local --no-ri --no-rdoc /tmp/#{pkg}.gem"
        not_if "/opt/td-agent/embedded/bin/fluent-gem list --local --no-versions | grep #{pkg}$"
      end
    end

    template "/etc/td-agent/td-agent.conf" do
        source "fluentd-td-agent.conf.erb"
        owner "root"
        group "root"
        mode 00644
        notifies :restart, "service[td-agent]", :immediately
    end

    service "td-agent" do
        action [:enable, :start]
    end

end
