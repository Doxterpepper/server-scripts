require 'digest'
require 'date'
require 'sqlite3'

module UserManagement
  def self.list_tokens
    query = "SELECT username, token, expiration FROM Tokens"
    tokens = []
    begin
      db = SQLite3::Database.open('tokens.db')
      db.results_as_hash = true
      db.execute(query) do |row|
        tokesn << row
      end
    ensure
      db.close
    end

    return tokens
  end

  def self.delete_token(token)
    query = 'DELETE FROM Tokens WHERE token = ?'

    begin
      db = SQLite3::Database.open('tokens.db')
      db.execute(query, token)
    ensure
    end
  end

  def self.check_token(token)
    token_result = get_token(token)

    if token_result.nil?
      return false
    end

    current_time = DateTime.now
    expiration_string = token_result['expiration']
    puts expiration_string
    expiration = DateTime.parse(expiration_string)

    if current_time > expiration
      return false
    end

    return true
  end

  def self.generate_one_time_token(user, expiration_date)
    return Digest::SHA256.hexdigest([user, expiration_date.to_s, DateTime.now.to_s].join())
  end

  def self.ot_exists?(ot_token)
    return !get_token(ot_token).nil?
  end

  def self.initialize_token_table
    query = "CREATE TABLE IF NOT EXISTS Tokens(username TEXT, token TEXT, expiration TIMESTAMP);"
    begin
      db = SQLite3::Database.open('tokens.db')
      db.execute(query)
    ensure
      db.close if db
    end
  end

  def self.insert_token(user, expiration_date, token)
    query = "INSERT INTO Tokens (username, token, expiration) VALUES(?, ?, ?);"
    begin
      db = SQLite3::Database.open('tokens.db')
      db.execute(query, user, token, expiration_date)
    ensure
      db.close if db
    end
  end

  def self.get_one_time(user, expiration_date)
    initialize_token_table

    token = generate_one_time_token(user, expiration_date)
    (1..5).each do |try|
      if !ot_exists?(token)
        insert_token(user, expiration_date.to_s, token)
        return token
      end
    end

    raise "Could not generate token!"
  end

  def self.get_token(token)
    result = nil
    query = "SELECT username, token, expiration FROM Tokens WHERE token = ?"
    begin
      db = SQLite3::Database.open('tokens.db')
      db.results_as_hash = true
      db.execute(query, token) do |row|
        result = row
      end
    ensure
      db.close
    end

    return result
  end
end
