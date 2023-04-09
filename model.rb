
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
        return db.execute("SELECT * FROM albums WHERE user_id = ?", user)
    end

    def delete_user(id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("DELETE FROM User WHERE id = ?", id)
        db.execute("DELETE FROM artists WHERE id = ?", id)
        db.execute("DELETE FROM albums WHERE album_id = ?", id)
        db.execute("DELETE FROM band WHERE id = ?", id)
    end

    def albums_new(title, artist_id, user)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("INSERT INTO albums (title, artist_id, user_id) VALUES (?,?,?)",title, artist_id, user)
    end

    def albums_edit(id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("SELECT * FROM albums WHERE album_id = ?",id).first   
    end

    def albums_update(title, artist_id, user)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("UPDATE albums SET title = ?, artist_id = ? WHERE user_id = ?",title, artist_id, user)
    end

    def albums_delete(id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("DELETE FROM albums WHERE album_id = ?",id)
    end

    def artist_new(artistname, age, country, instruments, user)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("INSERT INTO artists (artistname, age, country, instruments, user_id) VALUES (?,?,?,?,?)",artistname, age, country, instruments, user)
    end

    def artist_show(user)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.results_as_hash = true
        db.execute("SELECT * FROM artists WHERE user_id = ?", user)   
    end

    def band_new(title, starting_year, user, first_artist, second_artist, third_artist, fourth_artist)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.results_as_hash = true
        db.execute("INSERT INTO band (name, starting_year, user_id, first_artist_id, second_artist_id, third_artist_id, fourth_artist_id) VALUES (?,?,?,?,?,?,?)", title, starting_year, user, first_artist, second_artist, third_artist, fourth_artist)                
    end

    def band_show(user)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.results_as_hash = true
        db.execute("SELECT * FROM band WHERE user_id = ?", user)       
        # @innerjoin = db.execute("SELECT first_artist_id FROM band WHERE user_id = ?", user) 
        # db.execute("SELECT artistname FROM artists WHERE id = ?", @innerjoin )
    end

    def update_band(title, artist_id, user)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("UPDATE albums SET title = ?, artist_id = ? WHERE user_id = ?",title, artist_id, user)    
    end

 end 
