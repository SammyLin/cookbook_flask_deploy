default['deploy']['path'] = '/opt/my_first_python'
default['deploy']['source_git_url'] = 'https://github.com/SammyLin/my_first_python.git'

default['deploy']['gunicorn'] = {}
default['deploy']['gunicorn']['syslog_enable'] = true
default['deploy']['gunicorn']['syslog_prefix'] = 'gunicorn'
default['deploy']['gunicorn']['syslog_facility'] = 'daemon'
default['deploy']['gunicorn']['loglevel'] = 'info'
default['deploy']['gunicorn']['errorlog'] = '/var/log/gunicorn_error.log'
default['deploy']['gunicorn']['accesslog'] = '/var/log/gunicorn_access.log'
