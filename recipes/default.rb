#
# Cookbook Name:: nessus
# Recipe:: default
#
# Copyright 2014, Risk I/O
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
#
installer_filename = Dir.glob(node.nessus.installer_file).first

case File.extname(installer_filename)
when '.deb'
  dpkg_package 'Nessus' do
    source installer_filename
    notifies :restart, 'service[nessusd]', :delayed
  end
when '.rpm'
  rpm_package 'Nessus' do
    source installer_filename
    notifies :restart, 'service[nessusd]', :delayed
  end
else
  log 'Nessus installer file not usable' do
    level :fatal
  end
end

service 'nessusd' do
  action %i(enable start)
  only_if { node.nessus.enable }
end

# Activate Nessus subscription
include_recipe 'nessus::activate' if node.nessus.enable && node.nessus.activate

# Add users if vault is defined
include_recipe 'nessus::users' unless node.nessus.vault_users_item.nil?
