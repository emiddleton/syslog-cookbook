include_recipe "syslog"
include_recipe "syslog::tlsbase"

server_nodes = node.run_state[:nodes].select do |n|
  n[:tags].include?("syslog-server")
end

syslog_config "00-remote" do
  template "remote.conf"
  variables :server_nodes => server_nodes
end
