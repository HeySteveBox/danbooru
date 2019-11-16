set :user, "danbooru"
set :rails_env, "production"
append :linked_files, ".env.production"

server "192.168.254.185", :roles => %w(web app cron), :primary => true
#server "shima", :roles => %w(web app)
#server "saitou", :roles => %w(web app)
server "192.168.254.185", :roles => %w(worker)

set :newrelic_appname, "Danbooru"
#after "deploy:finished", "newrelic:notice_deployment"
