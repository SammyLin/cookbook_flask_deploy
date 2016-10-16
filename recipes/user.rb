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
