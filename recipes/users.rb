include_recipe 'chef-vault'

package 'expect'

users = chef_vault_item(node['nessus']['vault'], node['nessus']['vault_users_item']).dup
users.delete('id') # remove the id key/val

users.each_pair do |user, password|
  log "#{user} - #{password}"

  bash "nessus_add_user_#{user}" do
    user 'root'
    not_if "/opt/nessus/sbin/nessuscli lsuser|grep #{user}"
    code <<-EOF
    USER=$(/usr/bin/expect << 'END'
    spawn /opt/nessus/sbin/nessuscli adduser #{user}
    expect {
    "Login password:" {send "#{password}\n"}
    }
    expect  {
    "Login password (again):" {send "#{password}\n"}
    }
    expect {
    "*(can upload plugins, etc.)? (y/n)*" {send "y\n"}
    }
    expect {
    "*(the user can have an empty rules set)" {send "\n"}
    }
    expect {
    "Is that ok*" {send "y\n"}
    }
    expect eof
    END
    )
    EOF
  end
end
