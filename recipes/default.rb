app_name = node['deploy']['app_name']
deploy_to = node['deploy']['path']

include_recipe 'python'
include_recipe 'user'
include_recipe 'jupyter'

application deploy_to do
  owner node['deploy']['deploy_user']
  group node['deploy']['deploy_group']
  git node['deploy']['source_git_url']

  directory "#{deploy_to}/log" do
    owner node['deploy']['deploy_user']
    group node['deploy']['deploy_group']
    mode '0755'
  end

  template "#{deploy_to}/uwsgi.ini" do
    source 'uwsgi.ini.erb'
    mode '0644'
    variables(
      app_name:    app_name,
      deploy_path: deploy_to
      )
  end
end

pip_requirements "requirements.txt" do
  cwd deploy_to
  user node['deploy']['deploy_user']
  group node['deploy']['deploy_group']
  virtualenv "#{deploy_to}/.virtualenv"
end

python_package 'uwsgi' do
  user node['deploy']['deploy_user']
  group node['deploy']['deploy_group']
  virtualenv "#{deploy_to}/.virtualenv"
end

template "/etc/init/#{app_name}.conf" do
  source 'uwsgi.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
    app_name:    app_name,
    deploy_path: deploy_to
    )
end

service app_name do
  provider Chef::Provider::Service::Upstart
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end
