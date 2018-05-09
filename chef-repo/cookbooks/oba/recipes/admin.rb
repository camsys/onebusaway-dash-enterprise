log "Downloading wars"

## admin properties
tomcat_instance_name = node[:oba][:tomcat][:instance_name]
tomcat_stop_command = "systemctl #{tomcat_instance_name} stop"
tomcat_start_command = "systemctl #{tomcat_instance_name} start"

tomcat_webapp_dir = "/var/lib/#{tomcat_instance_name}/webapps"
tomcat_lib_dir = "/var/lib/#{tomcat_instance_name}/lib"


## watchdog properties
tomcat_w_instance_name = "tomcat8-watchdog"

tomcat_w_stop_command = "systemctl stop #{tomcat_w_instance_name}"
tomcat_w_start_command = "systemctl start #{tomcat_w_instance_name}"

tomcat_w_webapp_dir = "/var/lib/#{tomcat_w_instance_name}/webapps"
tomcat_w_temp_dir = "/var/cache/#{tomcat_w_instance_name}/temp"
tomcat_w_work_dir = "/var/cache/#{tomcat_w_instance_name}/work"

# setup directories
["/var/lib/oba", "/var/lib/oba/bundle","/var/lib/oba/bundles/staged", "/var/lib/oba/bundles/active", "/var/lib/oba/bundles/builder"].each do |path|
  directory path do
    owner node[:tomcat][:user]
    group node[:tomcat][:group]
    action :create
    recursive true
  end
end

["/var/lib/oba/logs"].each do |path|
  directory path do
    owner "ubuntu"
    group "ubuntu"
    action :create
    recursive true
  end
end

# get admin from maven
mvn_admin_version = node[:oba][:mvn][:version_admin]
mvn_admin_dest_file = "/tmp/war/onebusaway-admin-webapp-#{mvn_admin_version}.war"
log "maven dependency installed at #{mvn_admin_dest_file}"
maven "onebusaway-admin-webapp" do
  group_id "org.onebusaway"
  dest "/tmp/war"
  version mvn_admin_version
  packaging "war"
  owner node[:tomcat][:user]
  repositories node[:oba][:mvn][:repositories]
end

# get watchdog from maven
mvn_version = node[:oba][:mvn][:version_app]
mvn_watchdog_dest_file = "/tmp/war/onebusaway-watchdog-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_watchdog_dest_file}"
maven "onebusaway-watchdog-webapp" do
  group_id "org.onebusaway"
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner node[:tomcat][:user]
  repositories node[:oba][:mvn][:repositories]
end


### ADMIN SERVER

# template context.xml adding datasource
template "/var/lib/#{tomcat_instance_name}/conf/context.xml" do
  source "admin/context.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

template "/var/lib/oba/config.json" do
  source "admin/config.json.erb"
  owner 'root'
  group 'root'
  mode '0644'
end

# template apache sites-available
template "/etc/apache2/sites-available/default.conf" do
  source "admin/default.erb"
  owner 'root'
  group 'root'
  mode '0644'
end

# deploy onebusaway-admin-webapp
log "war file is #{mvn_admin_dest_file}"
script "deploy_admin" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "admin version is #{mvn_version}"
  code <<-EOH
  #{tomcat_stop_command}
  rm -rf #{tomcat_webapp_dir}/*
  rm -rf /var/cache/#{tomcat_instance_name}/temp/*
  rm -rf /var/cache/#{tomcat_instance_name}/work/Catalina/localhost/
  if [ ! -e /usr/bin/python2.5 ]
  then
    ln -s /usr/bin/python /usr/bin/python2.5
  fi
  unzip #{mvn_admin_dest_file} -d #{tomcat_webapp_dir}/ROOT || exit 1
  rm -f #{tomcat_webapp_dir}/ROOT/WEB-INF/lib/mysql-connector-java-5.1.17.jar
  EOH
end

# install tomcat-user support
script "install_tomcat_user" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  apt-get install -y tomcat8-user
  cd /var/lib
  /usr/bin/tomcat8-instance-create -p 7070 -c 7005 #{tomcat_w_instance_name} || exit 1
  # the policy scripts are not created above sadly
  cp -r /var/lib/#{tomcat_instance_name}/conf/policy.d /var/lib/#{tomcat_w_instance_name}/conf/
  # bin dir is missing a well
  cp -r /usr/share/#{tomcat_instance_name} /usr/share/#{tomcat_w_instance_name}
  mkdir -p /var/lib/#{tomcat_w_instance_name}/work/Catalina/localhost
  chown -R #{node[:tomcat][:user]}:#{node[:tomcat][:group]} #{tomcat_w_instance_name}
  EOH
end unless ::File.exists?("/var/lib/#{tomcat_w_instance_name}")


### WATCH DOG

# install tomcat for watchdog
tomcat_install tomcat_w_instance_name do
  install_path "/var/lib/#{tomcat_w_instance_name}"
  exclude_manager true
  exclude_hostmanager true
  tomcat_user node[:tomcat][:user]
  tomcat_group node[:tomcat][:group]
end

tomcat_service "#{tomcat_w_instance_name}" do
  action :start
  install_path "/var/lib/#{tomcat_w_instance_name}"
  env_vars [{'CATALINA_HOME' => "/var/lib/#{tomcat_w_instance_name}"},
            {'CATALINA_OUT' => "/var/lib/#{tomcat_w_instance_name}/logs/catalina.out"}]
  tomcat_user node[:tomcat][:user]
  tomcat_group node[:tomcat][:group]
end

template "/etc/default/#{tomcat_w_instance_name}" do
  source "watchdog/#{tomcat_w_instance_name}.default.erb"
  owner 'root'
  group 'root'
  mode '0644'
end

# template context.xml adding datasource
template "/var/lib/#{tomcat_w_instance_name}/conf/context.xml" do
  source "admin/context.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

script "stop_watchdog" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
#{tomcat_w_stop_command}
  EOH
end unless ::File.exists?("/var/lib/#{tomcat_w_instance_name}")

script "deploy_watchdog" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "watchdog version is #{mvn_version}"
  code <<-EOH
  rm -rf #{tomcat_w_webapp_dir}/*
  rm -rf #{tomcat_w_temp_dir}/*
  rm -rf #{tomcat_w_work_dir}/Catalina/localhost/
  unzip #{mvn_watchdog_dest_file} -d /var/lib/#{tomcat_w_instance_name}/webapps/onebusaway-watchdog-webapp || exit 1
  sed -i /etc/passwd -e 's!/usr/share/{tomcat_instance_name}:/bin/false!/usr/share/#{tomcat_instance_name}:/bin/bash!'
  EOH
end

# template data-sources
template "#{tomcat_webapp_dir}/ROOT/WEB-INF/classes/data-sources.xml" do
  source "admin/data-sources.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end
template "#{tomcat_w_webapp_dir}/onebusaway-watchdog-webapp/WEB-INF/classes/data-sources.xml" do
  source "watchdog/data-sources.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end


# TODO fix build dependency
%w{mysql-connector-java-5.1.35.jar mail-1.4.jar}.each do |jar_file|
  cookbook_file ["#{tomcat_lib_dir}", jar_file].compact.join("/") do
    owner node[:tomcat][:user]
    group node[:tomcat][:group]
    source ["admin", jar_file].compact.join("/")
    mode  '0444'
  end
end

script "start_tomcats" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "admin version is #{mvn_version}"
  code <<-EOH
  #{tomcat_start_command}
  #{tomcat_w_start_command}
  # somewhere along the way ROOT owns this dir, fix it
  sudo chown -R #{node[:tomcat][:user]}:#{node[:tomcat][:group]} /var/lib/oba/bundles
  EOH
end

# monitoring directory
directory '/var/lib/oba/monitoring' do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

# apt-get install s3cmd
%w{s3cmd}.each do |p|
  package p do
    action :install
  end
end

# template s3cfg to ~/.s3cfg
template "/home/ubuntu/.s3cfg" do
  source "admin/s3cfg.erb"
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
end

# in case we decide to run logrotate on these files
logfiles = []
cron "bundle-sync" do
  minute "0"
  logfile = "/var/lib/oba/logs/bundle_sync.log"
  command "/usr/bin/s3cmd --config /home/ubuntu/.s3cfg --no-progress --recursive --rexclude \"/$\" --skip-existing sync /var/lib/oba/bundles s3://obawmata-bundle/#{node[:oba][:env]}/ > #{logfile} 2>&1"
  user "ubuntu"
  logfiles << logfile
end

## synch bundles
script "sync-bundles-now" do
  interpreter "bash"
  user node[:tomcat][:user]
  cwd node[:oba][:home]
  puts "syncing bundles"
  code <<-EOH
  /usr/bin/s3cmd --config /home/ubuntu/.s3cfg --no-progress --recursive --rexclude "/$" --skip-existing get s3://obawmata-bundle/#{node[:oba][:env]}/ /var/lib/oba/ >/tmp/bundle_sync.log 2>&1
  EOH
end

# now that the bundle is present restart watchdog
script "restart watchdog" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "restart watchdog"
  code <<-EOH
  #{tomcat_w_stop_command}
  #{tomcat_w_start_command}
  EOH
end