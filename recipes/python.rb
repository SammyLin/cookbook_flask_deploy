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

python_virtualenv "#{deploy_to}/.virtualenv" do
  user node['deploy']['deploy_user']
  group node['deploy']['deploy_group']
end
