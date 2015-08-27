# setup id_rsa for github
cookbook_file ["home", node[:oba][:user], ".ssh", "id_rsa"].compact.join('/') do
    owner node['oba']['user']
    group node['oba']['group']
    source "id_rsa"
    mode '0600'
end
cookbook_file ["home", node[:oba][:user], ".ssh", "id_rsa.pub"].compact.join('/') do
    owner node['oba']['user']
    group node['oba']['group']
    source "id_rsa.pub"
    mode '0600'
end
