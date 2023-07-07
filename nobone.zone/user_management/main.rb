require 'date'

require 'sinatra'
require 'sinatra/json'
require 'active_support/all'

require_relative 'users/management'
require_relative 'one_time'

token = UserManagement::get_one_time('default', DateTime.now + 8.hours)
puts "http://192.168.2.13:4567/#{token}"

configure do
  set :bind => '0.0.0.0'
end

get '/:token' do
  access_token = params['token']

  valid_token = UserManagement::check_token(access_token)
  
  if valid_token
    return File.read('html/create_user.html')
  else
    halt 401, "Not authorized\n"
  end
end

post '/:token' do
  access_token = params['token']
  return 'yes'
end
