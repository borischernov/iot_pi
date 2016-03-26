get '/software' do
  @updates_available = `cd #{APP_ROOT} && git remote show origin`.include?("local out of date")
  erb :'software/index'
end

post '/software' do
  update_software
  "System is rebooting ..."
end


def update_software
  Dir.chdir(APP_ROOT)
  `git pull`
  `bundle install`
  ActiveRecord::Migrator.migrate("db/migrate")
  `reboot`
end