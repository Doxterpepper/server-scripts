require 'date'

require 'sinatra'
require 'sinatra/json'
require 'active_support/all'

require_relative '../users/management'
require_relative '../one_time'

token = UserManagement::get_one_time('default', DateTime.now + 8.hours)
puts "http://localhost:4567/#{token}"

configure do
  set :bind => '0.0.0.0'
end

get '/:token' do
  access_token = params['token']

  valid_token = UserManagement::check_token(access_token)
  
  if valid_token
    return File.read('web/html/create_user.html')
  else
    halt 401, "Not authorized\n"
  end
end

post '/:token' do
  access_token = params['token']
  
  valid_token = UserManagement::check_token(access_token)

  if valid_token
    request_payload = JSON.parse request.body.read

    required_keys = [
      'username',
      'password',
      'repassword'
    ]

    required_keys.each do |key|
      if !request_payload.key?(key)
        halt 400, 'Bad Request\n'
      end
    end

    if request_payload['password'] != request_payload['repassword']
      halt 400, 'Bad Request\n'
    end

    if request_payload['password'].length < 5
      halt 400, 'Bad request\n'
    end

    username = request_payload['username']
    password = request_payload['password']

    begin
      UserManagement::create_user(username, password)
      UserManagement::delete_token(access_token)
      return 201
    rescue
      raise
      halt 500, "Failed to create user"
    end
  else
    halt 401, "Not Authorized\n"
  end
end
