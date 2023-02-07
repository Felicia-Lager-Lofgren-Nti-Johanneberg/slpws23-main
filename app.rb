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

# 1 Registrera 

# 2 Skapa Login och logga in, ha med validering, authorization och authentication

# 3 Visa vilka albums som finns och skapa eget

get('/albums') do
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM Albums")
  p result
  slim(:"albums/index",locals:{albums:result})
end

get('/albums/new') do 
  slim(:"albums/new")
end

post('/albums/new') do
  title = params[:title]
  artist_id = params[:artist_id].to_i
  p "Vi fick in datan #{title} och #{artist_id}"
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.execute("INSERT INTO Albums (title, artist_id) VALUES (?,?)",title, artist_id)
  redirect('/albums')
end



# 4 Skapa artister och forma band (table:Artists)

# 5 Välj instrument till alla spelare (table:Instrument) => relation Artists

# 6 Välj stad att turnera i (table:Tour) => relation Artists