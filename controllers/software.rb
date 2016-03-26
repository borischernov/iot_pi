get '/software' do
  @updates_available = `cd #{APP_ROOT} && git remote show origin`.include?("local out of date")
  erb :'software/index'
end

post '/software' do
  Dir.chdir(APP_ROOT)
  `git pull`
  ActiveRecord::Migrator.migrate("db/migrate")
  `reboot`
  "System is rebooting ..."
end
