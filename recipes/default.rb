include_recipe 'poise-python'

application node['deploy']['path'] do
  git node['deploy']['source_git_url']
  pip_requirements

  template '/etc/gunicorn/gunicorn_config.py' do
    source 'gunicorn_config.py.erb'
    mode '0644'
    variables(gunicorn:  node['deploy']['gunicorn'])
  end

  gunicorn do
    port 9001
    config '/etc/gunicorn/gunicorn_config.py'
  end
end

