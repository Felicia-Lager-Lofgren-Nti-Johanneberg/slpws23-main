require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'byebug'
require 'sqlite3'
require 'bcrypt'


enable :sessions

get('/')  do
  slim(:start)
end 

get '/index' do
  slim(:index)
end

# 1 Skapa regristrerignen

# 2 Skapa Login och logga in, ha med validering, authorization och authentication (rb kod)

# 3 Visa vilka albums som finns och skapa egna album som sparas (+ radera och ändra?) 

get('/albums') do
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM Albums")
  current_albums = db.execute("SELECT album_id FROM Albums")
  p current_albums
  p result
  slim(:"/albums/index",locals:{albums:result})
end


get('/albums/new') do #CREATE ALBUM
  slim(:"albums/new")
end

post('/albums/new') do #CREATE ALBUM
  title = params[:title]
  artist_id = params[:artist_id].to_i
  p "Vi fick in datan #{title} och #{artist_id}"
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.execute("INSERT INTO Albums (title, artist_id) VALUES (?,?)",title, artist_id)
  redirect('/albums')
end

get('/albums/:id/edit') do   #UPPDATE
  id = params[:id].to_i
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM Albums WHERE album_id = ?",id).first
  p "result är #{result}"
  slim(:"/albums/edit",locals:{result:result})
end


# 4 Skapa artister och forma band (table:Artists)

# 5 Välj instrument till alla spelare (table:Instrument) => relation Artists

# 6 Välj stad att turnera i (table:Tour) => relation Artists

get('/tour') do
  id = session[:id].to_i
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM Tour WHERE user_id = ?",id)
  p "Alla städer  från result #{result}"
  slim(:"albums/index",locals:{Tour:result})
end

get('/tour/show') do
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.results_as_hash = true
  result_name = db.execute("SELECT name FROM Tour") #model
  result_city = db.execute("SELECT city FROM Tour")  #model
  result_price = db.execute("SELECT price FROM Tour") #model
  p result_name
  slim(:index)
end
