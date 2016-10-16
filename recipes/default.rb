include_recipe 'poise-python'
app_name = node['deploy']['app_name']

# sloved "uwsgi: error while loading shared libraries: libiconv.so.2: cannot open shared object file: No such file or directory"
cookbook_file '/etc/ld.so.conf' do
  source 'ld.so.conf'
  mode '0644'
end

execute 'run ldconfig' do
  command 'ldconfig'
end

execute 'devtools' do
  command 'yum -y groupinstall "Development Tools"'
end

deploy_to = node['deploy']['path']

# Create Deploy User & Group
group node['deploy']['deploy_group'] do
  append true
end

user node['deploy']['deploy_user'] do
  comment 'Deploy User'
  gid node['deploy']['deploy_group']
  home "/home/#{node['deploy']['deploy_user']}"
end

directory "/home/#{node['deploy']['deploy_user']}" do
  owner node['deploy']['deploy_user']
  group node['deploy']['deploy_group']
  mode '0755'
end

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

python_virtualenv "#{deploy_to}/.virtualenv" do
  user node['deploy']['deploy_user']
  group node['deploy']['deploy_group']
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

python_package 'jupyter' do
  virtualenv "#{deploy_to}/.virtualenv"
  user node['deploy']['deploy_user']
  group node['deploy']['deploy_group']
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

template "/etc/init/jupyter.conf" do
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

service app_name do
  provider Chef::Provider::Service::Upstart
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end
