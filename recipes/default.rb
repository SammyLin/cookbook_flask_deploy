include_recipe 'poise-python'

%w(uwsgi jupyter).each do |package|
  python_package package
end

deploy_to = node['deploy']['path']

application deploy_to do
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
