include_recipe 'poise-python'

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
      app_name:    node['deploy']['app_name'],
      deploy_path: deploy_to
      )
  end
end


python_virtualenv "#{deploy_to}/.virtualenv" do
  user node['deploy']['deploy_user']
  group node['deploy']['deploy_group']
end

# bash 'create virtualenv' do
#   user node['deploy']['deploy_user']
#   group node['deploy']['deploy_group']
#   cwd deploy_to
#   code 'virtualenv .virtualenv'
#   environment({ LANG:     'en_US.UTF-8',
#                 LANGUAGE: 'en_US.UTF-8',
#                 LC_ALL:   'en_US.UTF-8',
#                 RUBYOPTS: '-E utf-8'
#                 })
# end

# bash 'modify owner' do
#   user 'root'
#   cwd deploy_to
#   code <<-EOH
# chown #{node['deploy']['deploy_user']}:#{node['deploy']['deploy_group']} -R #{deploy_to}/.virtualenv
#   EOH
# end

# bash 'pip install requirements' do
#   user node['deploy']['deploy_user']
#   group node['deploy']['deploy_group']
#   cwd deploy_to
#   code <<-EOH
# . .virtualenv/bin/activate
# pip install -r requirements.txt
#   EOH
#   environment({ LANG:     'en_US.UTF-8',
#                 LANGUAGE: 'en_US.UTF-8',
#                 LC_ALL:   'en_US.UTF-8',
#                 RUBYOPTS: '-E utf-8'
#                 })
# end

pip_requirements "requirements.txt" do
  cwd deploy_to
  user node['deploy']['deploy_user']
  group node['deploy']['deploy_group']
  virtualenv "#{deploy_to}/.virtualenv"
end

# execute 'pip install' do
#   user node['deploy']['deploy_user']
#   cwd deploy_to
#   command <<-EOH
# export HOME=/home/deploy
# if [ ! -d .virtualenv ]; then
#   su - deploy -c "cd /opt/app && virtualenv .virtualenv"

# fi
# source .virtualenv/bin/activate
# su pip install -r requirements.txt
# su - deploy -c "cd /opt/app && source .virtualenv/bin/activate && pip install -r requirements.txt"
# su - deploy -c "cd /opt/app && source .virtualenv/bin/activate && pip install jupyter"
# pip install http://projects.unbit.it/downloads/uwsgi-latest.tar.gz
# pip install jupyter
#   EOH
#   action :run
# end

# bash 'pip install' do
#   user node['deploy']['deploy_user']
#   cwd deploy_to
#   code <<-EOH
# export HOME=/home/deploy
# if [ ! -d .virtualenv ]; then
#   virtualenv .virtualenv
# fi
# source .virtualenv/bin/activate
# env
# pip install -r requirements.txt
# pip install http://projects.unbit.it/downloads/uwsgi-latest.tar.gz
# pip install jupyter
#   EOH
#   action :run
# end

# bash 'pip install jupyter' do
#   user node['deploy']['deploy_user']
#   group node['deploy']['deploy_group']
#   cwd deploy_to
#   code <<-EOH
# . .virtualenv/bin/activate
# pip install jupyter
#   EOH
# end

template "/etc/init/#{node['deploy']['app_name']}.conf" do
  source 'uwsgi.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
    app_name:    node['deploy']['app_name'],
    deploy_path: deploy_to
    )
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

# cookbook_file "/etc/init/#{node['deploy']['app_name']}.conf" do
#   source "#{node['deploy']['app_name']}.conf"
#   owner 'root'
#   group 'root'
#   mode 0644
# end

# # start my_flask_app uWSGI service
# service node['deploy']['app_name'] do
#   provider Chef::Provider::Service::Upstart
#   supports status: true, restart: true, reload: true
#   action [:enable, :start]
# end

