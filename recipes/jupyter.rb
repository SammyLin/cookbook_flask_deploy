python_package 'jupyter' do
  virtualenv "#{deploy_to}/.virtualenv"
  user node['deploy']['deploy_user']
  group node['deploy']['deploy_group']
end

template '/etc/init/jupyter.conf' do
  source 'jupyter.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(deploy_path: deploy_to)
end

service 'jupyter' do
  provider Chef::Provider::Service::Upstart
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end
