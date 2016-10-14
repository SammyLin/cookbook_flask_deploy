include_recipe 'poise-python'

application node['deploy']['path'] do
  git node['deploy']['source_url']
  pip_requirements
  gunicorn do
    port 9001
  end
end

