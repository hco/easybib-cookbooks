include_recipe "couchdb::user"
include_recipe "couchdb::deps"
include_recipe "couchdb::prepare"

couchdb_installed_version = `which couchdb > /dev/null && couchdb -V | grep #{node[:couchdb][:version]}`.strip.gsub(/^.+([0-9.]{5,5})$/, '\1')

couchdb_already_installed = lambda do
  couchdb_installed_version == node[:couchdb][:version]
end

remote_file "/tmp/apache-couchdb-#{node[:couchdb][:version]}.tgz" do
  source "http://apache.easy-webs.de/couchdb/#{node[:couchdb][:version]}/apache-couchdb-#{node[:couchdb][:version]}.tar.gz"
  not_if &couchdb_already_installed
end

execute "unpack CouchDB" do
  command "cd /tmp && tar -xzf apache-couchdb-#{node[:couchdb][:version]}.tgz"
  not_if &couchdb_already_installed
end

execute "Configure CouchDB" do
  cwd "/tmp/apache-couchdb-#{node[:couchdb][:version]}"
  environment "HOME" => "/root"
  command "./configure --sysconfdir=/etc"
  not_if &couchdb_already_installed
end

execute "Compile and install CouchDB" do
  cwd "/tmp/apache-couchdb-#{node[:couchdb][:version]}"
  environment "HOME" => "/root"
  command "make && make install"
  not_if &couchdb_already_installed
end

include_recipe "couchdb::configure"

# we need to make default a template, also for silverline
if node[:couchdb][:port] == 80
  execute "Running on port 80, we require root" do
    command "sed -i 's,COUCHDB_USER=couchdb,COUCHDB_USER=root,g' /etc/default/couchdb"
  end
end

include_recipe "couchdb::service"

template "/etc/logrotate.d/couchdb" do
  source "logrotate.erb"
  mode "0644"
  owner "root"
  group "root"
end

include_recipe "couchdb::backup"
