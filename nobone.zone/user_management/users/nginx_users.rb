require 'open3'
require_relative 'users'
require_relative 'exceptions'

module UserManagement
  class NginxUsers < UserControls
    FTPUSERS_PATH = '/var/ftp_users'

    def add_user(username, password)
      if exists?(username)
        raise ExistsError
      end

      add_nginx_user(username, password)
    end

    ##
    # Delete a user from the password file
    def delete_user(username)
      file_buffer = ''
      File.open(FTPUSERS_PATH, 'r') do |password_file|
        file_buffer = password_file.read
      end

      file_buffer.gsub!(/^#{username}.*$\n/, '')

      File.open(FTPUSERS_PATH, 'w') do |password_file|
        password_file.write(file_buffer)
      end
    end

    # Update a user's password
    def update_user(username, password)
      file_buffer = ''
      File.open(FTPUSERS_PATH, 'r') do |password_file|
        file_buffer = password_file.read
      end

      new_entry = password_file_entr(username, password)

      file_buffer.gsub!(/^#{username}.*$\n/, new_entry)

      File.open(FTPUSERS_PATH, 'w') do |password_file|
        password_file.write(file_buffer)
      end
    end

    # Does the user already exist?
    def exists?(username)
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
      user_entry = password_file_entry(username, password)

      File.open(FTPUSERS_PATH, "a") do |password_file|
        password_file.write(user_entry)
      end
    end

    # Builds an entry to the password file in the form {username}:{HashedPassword}
    def password_file_entry(username, password)
      return [username, hash_password(password)].join(':')
    end

    # Builds a pashword hash using `openssl passwd -apr1`
    def hash_password(password)
      puts "Password: #{password}"
      stdout, result = Open3.capture2('openssl', 'passwd', '-apr1', password)
      puts stdout
      puts result
      if result.success?
        return stdout
      else
        raise ShellError
      end
    end
  end
end
