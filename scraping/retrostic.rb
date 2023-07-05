require 'fileutils'
require 'set'

require 'rest-client'
require 'nokogiri'
require 'thread/pool'

URL = 'https://www.retrostic.com'

CACHE_DIR = './cache'

pool = Thread.pool(10)

def get_html(path)
  cache_filename = CACHE_DIR + path + '/index.html'

  if File.exist?(cache_filename)
    puts "Using cached version of #{path}"
    FileUtils.mkdir_p(CACHE_DIR + path)
    # If the file exists, read the file instead of hitting the website.
    File.open(cache_filename, 'r') do |cache_file|
      return cache_file.read
    end
  else
    puts "Cache for #{path} doesn't exist, retrieving"
    # If the file doesn't exist yet, read it from the website then write it to a cache file.
    response = RestClient.get(URL + path)
    if response.code != 200
      raise Exception
    end

    puts "Writing body to #{cache_filename}"
    FileUtils.mkdir_p(CACHE_DIR + path)
    File.open(cache_filename, 'w+') do |cache_file|
      cache_file.write(response.body)
    end

    return response.body
  end
end

def get_rom_links(url)
  links = []
  page1 = get_html(url)
  nav = Nokogiri::HTML(page1).css('nav ul li:last-child a.page-link')
  puts nav
  puts
  return links
end

home_body = get_html('/roms')
html_body = Nokogiri::HTML(home_body)
rows = html_body.css('div.table-responsive tbody tr td a')
hrefs = rows.map do |row|
  row['href']
end

hrefs = hrefs.uniq

for href in hrefs do
  puts href
  rom_links = get_rom_links(href)
end
