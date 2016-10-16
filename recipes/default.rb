include_recipe 'poise-python'
include_recipe 'monit'

execute 'devtools' do
  command 'yum -y groupinstall "Development Tools"'
end

%w(uwsgi jupyter).each do |package|
  python_package 'uwsgi' do
    virtualenv 'my_flask_app_env'
    user node['deploy']['deploy_user']
    group node['deploy']['deploy_group']
  end
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
  virtualenv
  pip_requirements

  directory "#{deploy_to}/log" do
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
