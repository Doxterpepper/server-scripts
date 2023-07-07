require 'active_support/all'
require_relative 'one_time'
require 'date'

expiration = DateTime.now + 8.hours
token = UserManagement::get_one_time('testuser', expiration)

puts "created token #{token}"
puts UserManagement::ot_exists?(token)
#token = UserManagement::get_one_time('testuser', expiration)

valid = UserManagement::check_token(token)
puts "token valid: #{valid}"

