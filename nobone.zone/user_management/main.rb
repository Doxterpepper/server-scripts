require 'sinatra'
require 'sinatra/json'
require_relative 'users/nginx_users'
require_relative 'users/local_users'

configure do
  set :bind => '0.0.0.0'
end

get '/:token' do
  access_token = params['token']
  access_token
end

post '/:token' do
  access_token = params['token']
  return 'yes'
end
