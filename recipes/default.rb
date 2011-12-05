case node[:platform]
when 'centos'
  service "syslog" do
    action [:disable, :stop]
  end

  yum_key "CLASSDO-INC-GPG-KEY" do
    url "http://kagachan.next.classdo.com/centos/CLASSDO-INC-GPG-KEY"
    action :add
  end

  yum_repository "classdo" do
    repo_name "ClassDo"
    url "http://kagachan.next.classdo.com/centos/5.5/$basearch"
    key "CLASSDO-INC-GPG-KEY"
    action :add
  end

  execute "replace sysklogd with syslog-ng" do
    command <<-CMD
      rpm -qv syslog-ng > /dev/null || \
      echo "
      remove sysklogd
      install syslog-ng
      run
      " | yum shell -y
    CMD
  end
when 'gentoo'
  portage_package_unmask "=app-admin/syslog-ng-3.3.1"
  portage_package_keywords "=app-admin/syslog-ng-3.3.1"
  package "app-admin/syslog-ng" do
    version '3.3.1'
  end
else
  package "syslog-ng"
end

directory "/etc/syslog-ng/conf.d" do
  owner "root"
  group "root"
  mode "0755"
end

service "syslog-ng" do
  action [:enable, :start]
end

template "/etc/syslog-ng/syslog-ng.conf" do
  source "syslog-ng.conf"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, "service[syslog-ng]"
end

syslog_config "00-local" do
  template "local.conf"
end

include_recipe "syslog::logrotate"

cookbook_file "/etc/logrotate.d/syslog-ng" do
  owner "root"
  group "root"
  mode "0644"
  source "syslog-ng.logrotate"
end

monit_config "syslog-ng" do
  cookbook "syslog"
  source "monit.erb"
end
