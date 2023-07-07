require 'open3'
require_relative 'users'
require_relative 'exceptions'

module UserManagement
  FTP_GROUP = 'ftp'
  SHELL = '/bin/bash'
  PASSWD_PATH = '/etc/passwd'

  class LocalUsers < UserControls

    def add_user(username, password)
      if !exists?(username)
        raise ExistsError
      end

      add_local_ftp_user(username, password)
    end

    def delete_user(username)
      if !exists?(username)
        return
      end

      delete_local_user(username)
    end

    def update_user(username, password)
      if !exists?(username)
        raise ExistsError
      end

      change_password(username, password)
    end

    def exists?(new_username)
      File.open(PASSWD_PATH, 'r') do |passwd_file|
        passwd_file.each_line do |user_entry|
          username = user_entry.split(':').first
          if username.eql?(new_username)
            return true
          end # if
        end # each
      end # file
    end # exists

    def add_local_ftp_user(username, password)
      result = system('useradd', username, '-g', FTP_GROUP, '-s', SHELL)
      if !result
        puts(result)
        raise ShellError
      end
  
      change_password(username, password)
    end

    def change_password(username, password)
      result = Open3.pipeline(['echo', [username, password].join(':')], 'chpasswd')

      if !result.last.success?
        raise ShellError
      end
    end

    def delete_local_user(username)
      system('userdel', username)
      if $? != 0
        raise ShellError
      end
    end
  end # class
end # module
