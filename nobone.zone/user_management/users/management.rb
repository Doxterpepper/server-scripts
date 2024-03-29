require_relative 'local_users'
require_relative 'nginx_users'
require_relative 'users'

module UserManagement
  @local_users = LocalUsers.new
  @nginx_users = NginxUsers.new
  
  @user_management = [
    @local_users,
    @nginx_users,
  ]

  def self.get_user_info(username)
    info = {}
    if @local_users.exists?(username)
      info['local_ftp'] = true
    end

    if @nginx_users.exists?(username)
      info['nginx_web'] = true
    end

    return info
  end

  def self.create_user(username, password)
    begin
      @user_management.each do |user_type|
        user_type.add_user(username, password)
      end
    rescue StandardError => error
      puts error
      puts("Failed to create user #{username}, rolling back")
      @user_management.each do |user_type|
        user_type.delete_user(username) if user_type.exists?(username)
      end
      raise
    end
  end

  def self.delete_user(username)
    begin
      @user_management.each do |user_type|
        user_type.delete_user(username)
      end
    rescue
      puts("Failed to delete a user account! Partial user exists!")
    end
  end

  def self.update_password(username, password)
    begin
      @user_management.each do |user_type|
        user_type.update_user(username, password)
      end
    rescue
      puts("Failed to update password! #{username}")
    end
  end
end
