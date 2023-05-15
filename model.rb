
require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'byebug'
require 'sqlite3'
require 'bcrypt'

module Db_lore

class Db_lore

       
    # Attempts to create a new user
    #
    # @param [Hash] params form data
    # @option params [String] username The username
    # @option params [String] password The password
    #
    # @return [Hash]
    #   * :error [Boolean] whether an error occured
    #   * :message [String] the error message if an error occured
    #   * :user_id [Integer] The user's ID if the user was created

    def new_user(username, password_digest)
        db = SQLite3::Database.new('db/rocknmyb.db')
        db.execute("INSERT INTO User (username,pwdigest) VALUES (?,?)", username, password_digest)
    end
    
    # Gives the user a chance to login
    #
    # @param [Hash] params form data
    # @option params [String] username The username
    # @option params [String] password The password
    #
    # @return [Integer] The ID of the user
    # @return [false] if credentials do not match a user

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

    
    # Attempts to delete a row from the user table
    #
    # @param [Integer] user_id The users's ID
    # @param [Hash] params form data
    # @option params [String] username The username of the user 
    # @option params [String] artists The artists of the user
    # @option params [String] albums The albums of the user
    # @option params [String] band The band of the user
    #
    # @return [Hash]
    #   * :error [Boolean] whether an error occured
    #   * :message [String] the error message
    
    def delete_user(id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("DELETE FROM User WHERE id = ?", id)
        db.execute("DELETE FROM artists WHERE id = ?", id)
        db.execute("DELETE FROM albums WHERE album_id = ?", id)
        db.execute("DELETE FROM band WHERE id = ?", id)
    end

    # Attempts to insert a new row in the albums table
    #
    # @param [Hash] params form data
    # @option params [String] title The title of the article
    # @option params [String] content The content of the article                                                                         #Ej klar
    #
    # @return [Hash]
    #   * :error [Boolean] whether an error occured
    #   * :message [String] the error message

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
    end

    def update_band(title, artist_id, user)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("UPDATE albums SET title = ?, artist_id = ? WHERE user_id = ?",title, artist_id, user)    
    end

    def first_artist(user_id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute('SELECT artistname, artists.id
        FROM artists INNER JOIN band ON band.first_artist_id = artists.id 
        WHERE band.user_id = ?', user_id)
    end

    def second_artist(user_id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute('SELECT artistname, artists.id
        FROM artists INNER JOIN band ON band.second_artist_id = artists.id 
        WHERE band.user_id = ?', user_id)

    end

    def third_artist(user_id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute('SELECT artistname, artists.id
        FROM artists INNER JOIN band ON band.third_artist_id = artists.id 
        WHERE band.user_id = ?', user_id)

    end

    def fourth_artist(user_id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute('SELECT artistname, artists.id
        FROM artists INNER JOIN band ON band.fourth_artist_id = artists.id                                
        WHERE band.user_id = ?', user_id)

    end

    def username(user_id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("SELECT username FROM User WHERE id = ?", user_id)
    end

    def all_users()
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("SELECT * FROM User")
    end

    def privileges(user_id)
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.execute("SELECT privileges FROM User WHERE id = ?", user_id).first
    end

 end 
