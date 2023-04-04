require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'byebug'
require 'sqlite3'
require 'bcrypt'
require_relative 'model' 
require 'sinatra/flash'

enable :sessions

db = SQLite3::Database.new('db/rocknmyb.db')

output=[]

get('/')  do
  redirect('showlogin') unless session[:id]
  slim(:start)
end 

get '/index' do
  slim(:index)
end

# 1 REGRISTRERING:

get('/register') do   #regristrering
  slim(:register)
end

post('/users/new') do   #Ny användare
    
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
 
   if (password == password_confirm)
     #Lägg till användare
     password_digest = BCrypt::Password.create(password)
     Db_lore.new.new_user(username, password_digest)
     redirect('/')
   else
    "wrong"
   end
 end

# 2 Logga in, authorization och authentication:

get('/showlogin') do   #loginsida
   slim(:login)
 end
 
 post('/login') do
     username = params[:username]
     password = params[:password]
     result = Db_lore.new.login(username, password)
     pwdigest = result["pwdigest"]
     id = result["id"]
     if BCrypt::Password.new(pwdigest) == password
       session[:id] = id
       redirect('/')
     else
      "wrong password or username"
     end
   end

   get('/logout') do
    # logik för utloggning [...]
    flash[:notice] = "You have been logged out!"
    session.clear 
    slim(:"logout")
 end

# 3 Visa vilka albums som finns och skapa egna album som sparas CREATE READ UPDATE DELETE

get('/albums') do #READ
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.results_as_hash = true
  user = session[:id]
  
  # result = Db_lore.new.albums(user) ###HJÄLP
  
  result = db.execute("SELECT * FROM albums WHERE user_id = ?", user)
  current_albums = db.execute("SELECT album_id FROM albums")
  p current_albums
  p result
  slim(:"/albums/index",locals:{albums:result})
end

get('/albums/new') do #CREATE ALBUM
  slim(:"/albums/new")
end

post('/albums/new') do #CREATE ALBUM
  title = params[:title]
  artist_id = params[:artist_id].to_i
  user = session[:id]
  p "Vi fick in datan #{title} och #{artist_id}"
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.execute("INSERT INTO albums (title, artist_id, user_id) VALUES (?,?,?)",title, artist_id, user)


  # #Skapa en sträng med join "./public/uploaded_pictures/cat.png"
  # path = File.join("./public/uploaded_pictures/",params[:file][:filename])                                    #Fixa bild 
  # #Spara bilden (skriv innehållet i tempfile till destinationen path)
  # File.write(path,File.read(params[:file][:tempfile]))

  redirect('/albums')

end

get'/albums/:id' do
  db = SQLite3::Database.new("db/rocknmyb.db")
  @result = db.execute("SELECT * FROM albums WHERE album_id = ?",params[:id]).first
  p "result är #{@result}"
  slim(:"albums/edit")
end

post('/update/:id') do   #EDIT
  title = params[:title]
  artist_id = params[:artist_id].to_i
  user = session[:id]
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.execute("UPDATE albums SET title = ?, artist_id = ? WHERE user_id = ?",title, artist_id, user)
  
  redirect('/albums')
end

# post('/albums/upload_image') do
#   #Skapa en sträng med join "./public/uploaded_pictures/cat.png"
#   path = File.join("./public/uploaded_pictures/",params[:file][:filename])
#   #Spara bilden (skriv innehållet i tempfile till destinationen path)
#   File.write(path,File.read(params[:file][:tempfile]))
  
#   redirect('/albums/upload_image')
# end

post('/albums/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.execute("DELETE FROM albums WHERE album_id = ?",id)
  redirect('/albums')
end

get('/artist/new') do
  slim(:"artist/new")

end

post('/artist/new') do
  artistname = params[:artistname]
  age = params[:age].to_i
  country = params[:country]
  instruments = params[:instruments]
  user = session[:id]
  db.execute("INSERT INTO artists (artistname, age, country, instruments, user_id) VALUES (?,?,?,?,?)",artistname, age, country, instruments, user)
  redirect('/artist/show')
end

get('/artist/show') do
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.results_as_hash = true
  user = session[:id]
  @result_artist = db.execute("SELECT * FROM artists WHERE user_id = ?", user)
  slim (:"/artist/show")
end

get ('/band/new') do
  db.results_as_hash = true
  user = session[:id]
  @artists = db.execute("SELECT * FROM artists WHERE user_id = ?", user)
  slim(:"band/new")
end

post ('/band/new') do

  title = params[:title]
  starting_year = params[:starting_year]
  user = session[:id]
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.execute("INSERT INTO band (name, starting_year, user_id) VALUES (?,?,?)", title, starting_year, user)
 
  redirect('/band/show')
end 

get('/band/show') do #READ
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.results_as_hash = true
  user = session[:id]
  @result = db.execute("SELECT * FROM band WHERE user_id = ?", user)
  
  slim (:"/band/show")
end

post('/update_band/:id') do   #EDIT för bandet 
  title = params[:title]
  artist_id = params[:artist_id].to_i
  user = session[:id]
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.execute("UPDATE albums SET title = ?, artist_id = ? WHERE user_id = ?",title, artist_id, user)
  
  redirect('/band/show')
end







# 6 Välj stad att turnera i (table:Tour) => relation Artists + bestäm pris

=begin
get('/tour') do
  id = session[:id].to_i
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM Tour WHERE id = ?",id)
  slim(:"albums/index",locals:{Tour:result})
end
=end


get('/tour') do  
  slim(:"tour/index")
end

helpers do
  def price 
    db = SQLite3::Database.new('db/rocknmyb.db')
    db.results_as_hash = true
  price = db.execute("SELECT price FROM tour")
    return price
  end
 end

get('/show_calculate') do
  slim (:tour/forms)
end

post('/calculate') do

  @num1 = params[:num1].to_f
  @num2 = params[:num2].to_f
  @operator = params[:operator]
  @result = case @operator
            when '+' then @num1 + @num2
            when '-' then @num1 - @num2
            when '*' then @num1 * @num2
            when '/' then @num1 / @num2
            end
            
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.execute("INSERT INTO band (name, starting_year, user_id) VALUES (?,?,?)", title, starting_year, user)
  redirect('/tour/show')
end






get('/tour/show') do
  db = SQLite3::Database.new("db/rocknmyb.db") #ta bort
  db.results_as_hash = true #ta bort
  result_name = db.execute("SELECT name FROM Tour") #model
  result_city = db.execute("SELECT city FROM Tour")  #model
  result_price = db.execute("SELECT price FROM Tour") #model
  p result_name
  slim(:index)
end
