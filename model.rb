#def register_user(username, password_digest)
require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'byebug'
require 'sqlite3'
require 'bcrypt'

class Db_lore

    def new_user(username, password_digest)
        db = SQLite3::Database.new('db/rocknmyb.db')
        db.execute("INSERT INTO User (username,pwdigest) VALUES (?,?)", username, password_digest)
    end

    def login(username, password_digest)
        db = SQLite3::Database.new('db/rocknmyb.db')   
        db.results_as_hash = true
        db.execute("SELECT * FROM User WHERE username = ?",username).first
    end

    def albums(user) 
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.results_as_hash = true        
        return result = db.execute("SELECT * FROM albums WHERE user_id = ?", user)
        return current_albums = db.execute("SELECT album_id FROM albums")
    end

    def delete_user(id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("DELETE FROM User WHERE id = ?", id)
        db.execute("DELETE FROM artists WHERE id = ?", id)
        db.execute("DELETE FROM albums WHERE album_id = ?", id)
        db.execute("DELETE FROM band WHERE id = ?", id)
    end

 end 
