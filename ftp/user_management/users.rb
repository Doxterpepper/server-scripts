
FTP_GROUP = 'ftp'
SHELL = '/bin/nologin'
FTPUESRS_PATH = '/var/ftp_users'
PASSWD_PATH = '/etc/passwd'

class ExistsError < StandardError
end

##
# Add a local user to passwd file and make them a FTP user.
def add_local_ftp_user(username, password)
    result = `useradd #{username} -g #{FTP_GROUP} -s #{SHELL}`
    status_code = $?
    if status_code != 0
      puts(result)
    end

end

def user_exists?(username, passwd_file)
  File.open(FTPUSERS_PATH, 'r') do |f|
    f.each_line do |line|
      existing_user = line.split(':').first
      if username.eql?(existing_user)
        return true
      end
    end
  end
  return false
end

def add_nginx_user(username, password)
end

##
# Main function to add a user. Adds users to local linux and adds them to the nginx password file.
def add_ftp_user(username, password)
  if user_exists?(username, FTPUSERS_PATH) 
    puts("User already exists #{username}")
    raise ExistsError
  end

  if user_exists(username, PASSWD_FILE)
    puts("User exists in passwd. #{username}"
    raise ExistsError
  end

  add_local_ftp_user(username, password)
  add_nginx_user(username, password)
end

