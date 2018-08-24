set :user, 'r3cha'
server '188.166.58.166', user: fetch(:user), roles: %w[app db web]
