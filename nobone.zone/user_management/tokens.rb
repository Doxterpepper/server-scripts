require 'optparse'
require 'date'

require 'active_support/all'

require_relative 'one_time'

URL = 'https://signup.nobone.zone/'

options = {
  :timeout => 24
}

OptionParser.new do |opt|
  opt.banner = "Usage: gen_onetime [options]"
  opt.on('-eTIMEOUT', 'Set manual timeout, default 24 hours') { |timeout| options[:timeout] = timeout }
  opt.on('-l', 'List all issued links') { |list| options[:list] = true }
  opt.on('-dTOKEN_ID', 'Delete token') { |token_id| options[:delete] = token_id }
end.parse!

if options.key?(:list)
  puts 'listing onetime links'
  UserManagement::list_tokens.each do |token|
    puts([token['username'], token['token'], token['expiration']].join(' ')
  end
  return
end

if options.key?(:delete)
  puts "deleting key #{options[:delete]}"
  return
end

timeout = options[:timeout]
puts("creating key with #{timeout}h durration")

expiration_date = DateTime.now + timeout.hours

puts(URL + UserManagement::get_one_time('default', expiration_date))
