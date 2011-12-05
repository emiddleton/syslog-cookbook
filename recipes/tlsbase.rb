include_recipe "ssl"

directory "/etc/ssl/syslog-ng/ca.d" do
  owner "root"
  group "root"
  mode "0750"
  recursive true
end

ssl_ca "/etc/ssl/syslog-ng/ca.d/ca" do
  symlink true
  notifies :restart, "service[syslog-ng]", :delayed
end

ssl_certificate "/etc/ssl/syslog-ng/machine" do
  cn node[:fqdn]
  notifies :restart, "service[syslog-ng]", :delayed
end
