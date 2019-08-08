require 'json'
require 'digest'
require 'rest-client'

install_path = '/srv/minecraft'

mc_current_file = '/srv/minecraft/.mc_current_version.txt'
current_version = '0.0.0'

if File.exists? mc_current_file
  File.open mc_current_file, 'r' do |f|
    current_version = f.read
  end
else
  File.open(mc_current_file, 'w') do |file|
  end
end

latest_metadata = 'https://launchermeta.mojang.com/mc/game/version_manifest.json'
latest_json = JSON.parse(RestClient.get(latest_metadata).body)

latest_version = latest_json['latest']['release']
puts latest_version
if latest_version == current_version
  return 0
end

latest_entry = latest_json['versions'].first {|e| e['id'] == latest_version }
latest_version_metatdata_url = latest_entry['url']

latest_version_metadata = JSON.parse(RestClient.get(latest_version_metatdata_url))

server_downloads_metadata = latest_version_metadata['downloads']['server']
server_sha = server_downloads_metadata['sha1']
server_download_url = server_downloads_metadata['url']

puts 'downloading new server'
file_result = RestClient.get(server_download_url)
puts 'checking hash'
sha_digest = Digest::SHA1.hexdigest file_result.body
if sha_digest != server_sha
  puts 'Downloaded server hash did not match expected!'
  puts "expted: #{server_sha}, actual #{sha_digest}"
  puts 'Aborting!'
  exit 2
end

download_path = "#{install_path}/minecraft_server.#{latest_version}.jar" 
puts "Downloading to #{download_path}"
f = File.open(download_path, 'wb')
f.write(file_result.body)
f.close
link_path = "#{install_path}/minecraft_server.jar"
puts "#{download_path} -> #{link_path}"
File.unlink(link_path)
File.symlink(download_path, link_path)
puts 'restarting server'
`minecraftd restart`
puts 'done'

File.open(mc_current_file, 'w') do |f|
  f.write latest_version
end
