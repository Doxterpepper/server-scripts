require 'fileutils'
require 'set'
require 'gci'

#require 'erb'
require 'rest-client'
require 'nokogiri'
require 'thread/pool'

URL = 'https://www.retrostic.com'

CACHE_DIR = './cache'
DOWNLOAD_URL = 'https://downloads.retrostic.com/roms/'

LOCAL_SAVE_PATH = './downloads/'

pool = Thread.pool(10)
Random.new_seed

def read_cached(path)
  File.open(path, 'r') do |cache_file|
    return cache_file.read
  end
end

def random_wait
  wait_time = Random.new(5..60)
  puts "Waiting #{wait_time}"
  sleep(wait_time)
end

def cache_page(path, body)
  puts "Writing body to #{path}"
  File.open(path, 'w+') do |cache_file|
    cache_file.write(body)
  end
end

def get_remote(path)
  response = RestClient.get(URL + path)
  if response.code != 200
    raise Exception
  end
  return response.body
end

def get_html(path)
  cache_filename = CACHE_DIR + path + '/index.html'

  if File.exist?(cache_filename)
    puts "Using cached version of #{path}"
    return read_cached(cache_filename)
  else
    puts "Cache for #{path} doesn't exist, retrieving"
    page = get_remote(path)
    FileUtils.mkdir_p(CACHE_DIR + path)
    cache_page(cache_filename, page)
    return page
  end
end

def get_rom_links(url)
  links = []
  page1 = get_html(url)
  nav = Nokogiri::HTML(page1).css('nav ul li:last-child a.page-link')
  nav_link = nav.first['href']

  page1_links = Nokogiri::HTML(page1).css('table tr td a').map {|anchor| anchor['href']}.uniq
  links.concat(page1_links)

  return links
  if !nav_link.nil?
    max_pages = nav_link.split('/').last
    (1..max_pages.to_i).each do |index|
      paged_url = url + "/page/#{index}"
      #puts paged_url
      page_html = get_html(paged_url)
      page_links = Nokogiri::HTML(page_html).css('table tr td a').map {|anchor| anchor['href']}.uniq
      links.concat(page_links)
    end
  end

  return links
end

def get_filename(path)
  details_page_html = get_html(path)
  filename = Nokogiri::HTML(details_page_html).css('.table tr:first-child td').last
  return filename.inner_html
end

def download(rom_type, filename)
    puts "downloading #{filename}"
    url_encoded_name = GCI::escape(filename)
    puts(DOWNLPAD_URL + url_encoded_name)
    rom_file = RestClient.get(DOWNLOAD_URL + url_encoded_name)
    File.open(LOCAL_SAVE_PATH + "/#{rom_type}/#{filename}", 'w+') do |save_file|
      save_file.write(rom_file.body)
    end
end

def already_has?(rom_type, filename)
  File.exists?(LOCAL_SAVE_PATH + "/#{rom_type}/#{filename}")
end

home_body = get_html('/roms')
html_body = Nokogiri::HTML(home_body)
rows = html_body.css('div.table-responsive tbody tr td a')
hrefs = rows.map do |row|
  row['href']
end

hrefs = hrefs.uniq

#for href in hrefs do
  #puts href
  href = hrefs[1]
  rom_type = href.split('/').last

  rom_links = get_rom_links(hrefs[1])
  filename = get_filename(rom_links[0])
  if !already_has?(rom_type, filename)
    download(rom_type, filename)
  end
#end

