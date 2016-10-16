default['deploy']['source_git_url'] = 'https://github.com/SammyLin/my_first_python.git'
default['deploy']['app_name']           = 'app'
default['deploy']['deploy_prefix_path'] = '/opt'
default['deploy']['path'] = node['deploy']['path'] || "#{node['deploy']['deploy_prefix_path']}/#{node['deploy']['app_name']}"
