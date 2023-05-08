require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'byebug'
require 'sqlite3'
require 'bcrypt'
require_relative 'model' 
require 'sinatra/flash'

enable :sessions

include Db_lore

# Restricts the user from entering specific routes
#
#
before do
  restricted_paths = ['/band/', '/band/*', '/admin/', '/admin/*', '/albums/', '/albums/*', '/artist/', '/artist/*', '/artist/new','/artist/new*', '/band/new','/band/new*', '/albums/new','/albums/new*'  ]
  user_id = session[:id]
  @privileges = Db_lore.new.privileges(user_id)                                 
 

  if !session[:logged_in] && restricted_paths.include?(request.path_info)   
    redirect '/login/:id'
  end
 

  if session[:logged_in] && @privileges != 1 && request.path_info == '/admin'
    redirect '/login/:id'
  end
end


# HTTP GET request handler for the root path ('/')
#
# @return [String] the rendered slim template for the 'start' page
#
get('/')  do
  @privileges =  Db_lore.new.privileges(session[:id])
  slim(:start)
end 

# Displays a admin site if the user is admin 
#
# 
get '/admin/' do
  @alla_användare = Db_lore.new.all_users()
  slim(:admin)
end
# Gives the admin the opportunity to delete users 
#
# return void
post '/admin/:id/delete' do
  Db_lore.new.delete_user(params[:id])
  redirect('/admin/')
end

# HTTP GET request handler for the '/index/' path
#
# @return [String] the rendered slim template for the 'index' page
get '/index/' do
  slim(:index)
end

# Display the register form
#
# 
get('/register') do  
  slim(:register)
end

# Registers a new user with the provided username and password
#
# @option [string] :username 
# @option [string] :password
# @option [string] :password_confirm
post('/users/new') do 
    
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
 
   if (password == password_confirm)
    
     password_digest = BCrypt::Password.create(password)
     Db_lore.new.new_user(username, password_digest)
     redirect('/')
   else
    "wrong password"
   end
end

# Displays a login form
#
# 
get('/login/:id') do   
   slim(:login)
end
 

post('/login') do
  db = SQLite3::Database.new('db/rocknmyb.db')   
  username = params[:username]
  password = params[:password]


  if session[:time] ==  nil
    session[:time] = Time.new()
  elsif Time.new - session[:time] < 12                   
    redirect to('/wrong_password')
  end

  result = Db_lore.new.login(username, password)
  pwdigest = result["pwdigest"]
  id = result["id"]

  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    session[:username] = Db_lore.new.username(session[:id])
    session[:logged_in] = true                                                                               
    redirect('/')

  else
  "Wrong password or username"
  flash[:tries_left] = "You have [] tries left"
  session[:logged_in] = false                 
  session.clear 
  end

  if session[:username] == nil 
    session[:time] = Time.new()
  end
  redirect('/')
end
# Displays a cooldown if user tries to enter wrong login informationen again and again within 12 seconds.
#
#
get('/wrong_password') do   
  slim(:cooldown)
end

#
#
# 
get('/logout') do
  flash[:notice] = "You have been logged out!"
  session.clear 
  slim(:"logout")
end
#
#
# 
get('/albums/') do 
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
  redirect('/albums/')
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
  redirect('/albums/')
end

post('/albums/:id/delete') do
  Db_lore.new.albums_delete(params[:id].to_i)
  redirect('/albums/')
end

# Shows the users created artists 
# 
# 
get('/artist/') do
  @result_artist = Db_lore.new.artist_show(session[:id])
  slim (:"/artist/show")
end

# Sends user to the new artist form                                                                                   
#
# 
get('/artist/new') do
  slim(:"artist/new")
end

# User comes to the artist form to create an artist
#
#
post('/artist/new') do             
  Db_lore.new.artist_new(                                                                                     
  artistname = params[:artistname],
  age = params[:age].to_i,
  country = params[:country],
  instruments = params[:instruments],
  user = session[:id])
  redirect('/artist/')
end

get('/band/') do
  db = SQLite3::Database.new("db/rocknmyb.db")
  @result = Db_lore.new.band_show(session[:id]) 

  @first_artist_id = Db_lore.new.first_artist(@result[0]['user_id'].to_i)

  @second_artist_id = Db_lore.new.second_artist(@result[0]['user_id'].to_i)

  @third_artist_id = Db_lore.new.third_artist(@result[0]['user_id'].to_i)

  @fourth_artist_id = Db_lore.new.fourth_artist(@result[0]['user_id'].to_i)

  slim (:'/band/index')
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
  redirect('/band/')
end 

post('/band/:id/update') do   
  Db_lore.new.band_update(
  title = params[:title],
  artist_id = params[:artist_id].to_i,
  user = session[:id])                
  redirect('/band/')
end

