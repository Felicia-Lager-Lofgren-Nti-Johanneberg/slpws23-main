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

  @privileges = db.execute("SELECT privileges FROM User WHERE id = ?", session[:id]).first
  p @privileges
  slim(:start)
end 

get '/admin' do
  @alla_användare = db.execute("SELECT * FROM User")
  slim(:admin)
end

post '/admin/:id/delete' do
  Db_lore.new.delete_user(params[:id])
  redirect('/admin')
end

get '/index' do
  slim(:index)
end

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
     db = SQLite3::Database.new('db/rocknmyb.db')   
     username = params[:username]
     password = params[:password]
     result = Db_lore.new.login(username, password)
     pwdigest = result["pwdigest"]
     id = result["id"]
     if BCrypt::Password.new(pwdigest) == password
       session[:id] = id
       session[:username] = db.execute("SELECT username FROM User WHERE id = ?",session[:id])
       
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

# 3 Visa vilka albums som finns och skapa egna album som sparas, CREATE READ UPDATE DELETE

get('/albums') do 
  @result = Db_lore.new.albums(session[:id]) 
  slim(:"/albums/index")
end

get('/albums/new') do                                                           
  slim(:"/albums/new")
end

post('/albums/new') do                                                                                    
  Db_lore.new.albums_new(
  title = params[:title], 
  artist_id = params[:artist_id].to_i, 
  user = session[:id])
  redirect('/albums')
end

get'/albums/:id' do
  @result = Db_lore.new.albums_edit(params[:id])                             
  slim(:"albums/edit")
end

post('/update/:id') do 
  Db_lore.new.albums_update(                                                                                               
  title = params[:title],
  artist_id = params[:artist_id].to_i,
  user = session[:id])
  redirect('/albums')
end

# post('/albums/upload_image') do                                                                                     #Fix upload picture
#   #Skapa en sträng med join "./public/uploaded_pictures/cat.png"
#   path = File.join("./public/uploaded_pictures/",params[:file][:filename])
#   #Spara bilden (skriv innehållet i tempfile till destinationen path)
#   File.write(path,File.read(params[:file][:tempfile]))
  
#   redirect('/albums/upload_image')
# end

post('/albums/:id/delete') do
  Db_lore.new.albums_delete(params[:id].to_i)
  redirect('/albums')
end

get('/artist/new') do
  slim(:"artist/new")
end

post('/artist/new') do             
  Db_lore.new.artist_new(                                                                                     
  artistname = params[:artistname],
  age = params[:age].to_i,
  country = params[:country],
  instruments = params[:instruments],
  user = session[:id])
  redirect('/artist/show')
end

get('/artist/show') do
  @result_artist = Db_lore.new.artist_show(session[:id])
  slim (:"/artist/show")
end

get ('/band/new') do
  @artists = Db_lore.new.artist_show(session[:id])
  slim(:"band/new")
end

post ('/band/new') do
  Db_lore.new.band_new(params[:title], params[:starting_year], session[:id], 
  params[:artist1].to_i,
  params[:artist2].to_i,
  params[:artist3].to_i,
  params[:artist4].to_i)
  redirect('/band/show')
end 

get('/band/show') do
  db = SQLite3::Database.new("db/rocknmyb.db")
  @result = Db_lore.new.band_show(session[:id]) 
  # @first_artist = db.execute("SELECT first_artist_id FROM band WHERE user_id = ?", session[:id]).first 
  # @second_artist = db.execute("SELECT second_artist_id FROM band WHERE user_id = ?", session[:id]).first               #detta ska fixas
  # @third_artist = db.execute("SELECT third_artist_id FROM band WHERE user_id = ?", session[:id]).first 
  # @fourth_artist = db.execute("SELECT fourth_artist_id FROM band WHERE user_id = ?", session[:id]).first 
  # @result_first_artist = db.execute("SELECT artistname FROM artists WHERE id = ?", @first_artist)
  # @result_second_artist = db.execute("SELECT artistname FROM artists WHERE id = ?", @second_artist)
  # @result_third_artist = db.execute("SELECT artistname FROM artists WHERE id = ?", @third_artist)
  # @result_fourth_artist = db.execute("SELECT artistname FROM artists WHERE id = ?", @fourth_artist)
 
    
  slim (:"/band/show")
end

post('/update_band/:id') do   
  Db_lore.new.band_update(
  title = params[:title],
  artist_id = params[:artist_id].to_i,
  user = session[:id])                
  redirect('/band/show')
end