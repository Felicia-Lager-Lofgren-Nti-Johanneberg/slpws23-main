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

# Restricts the user from entering specific routes (if the user is not authorized)
# 
# @param [Array] restricted_paths Contains all restricted route-names
# @param [Integer] usern_id User's id
# @return [void]                                                                                                       #KLAR 1
# @see Model#privileges
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


# Sends user to the landing page                                                                                #KLAR 2
# 
# @return [void]
#
# @see Model#privileges
get('/')  do
  @privileges =  Db_lore.new.privileges(session[:id])
  slim(:start)
end 

# Displays a admin site if the user is admin.                                                                   #KLAR 3
#                                                                    
# @return [void]
#
# @see Model#all_users
get '/admin/' do
  @alla_användare = Db_lore.new.all_users()
  slim(:admin)
end

# Gives the admin the opportunity to delete users
# 
# @see Model#delete_user
post '/admin/:id/delete' do
  Db_lore.new.delete_user(params[:id])                                                                           #hmmmm
  redirect('/admin/')
end

# HTTP GET request handler for the '/index/' path
#
get '/index/' do
  slim(:index)                                                                                       #KLAR 5
end

# Display the register form
#
get('/register') do                                                                                   #KLAR 6
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
get('/login/:id') do                                                                                     #KLAR 7                                                                   
   slim(:login)
end

# Displays...
# 
# @option [string] :username 
# @option [string] :password
# @option [Integer] :id
# @option []
#
# @see Model#login
post('/login') do
  db = SQLite3::Database.new('db/rocknmyb.db')                                                       #Ej klar 8
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
get('/wrong_password') do                                                                      #KLAR 9
  slim(:cooldown)
end

# Displays a flash notice when a user press logout and clears the login inforamtion
#
get('/logout') do
  flash[:notice] = "You have been logged out!"                                                  #Ej klar 10 
  session.clear 
  slim(:"logout")
end

# Displays all the users created albums
#
# @see Model#albums
get('/albums/') do 
  @result = Db_lore.new.albums(session[:id])                                                      #KLAR 23
  slim(:"/albums/index")
end

# Displays a create-your-own-album form
#
get('/albums/new') do                                                                             #KLAR 11                         
  slim(:"/albums/new")
end

# 
#
# @see Model#albums_new
post('/albums/new') do                                                                                    
  Db_lore.new.albums_new(
  title = params[:title], 
  artist_id = params[:artist_id].to_i,                                                            #Ej klar 12
  user = session[:id])
  redirect('/albums/')
end


# @see Model#albums_edit
get'/albums/:id' do
  @result = Db_lore.new.albums_edit(params[:id])                                                 #Ej klar 13                 
  slim(:"albums/edit")
end


# @see Model#albums_update
post('/update/:id') do 
  Db_lore.new.albums_update(                                                                                               
  title = params[:title],
  artist_id = params[:artist_id].to_i,                                                          #Ej klar 14
  user = session[:id])
  redirect('/albums/')
end


# @see Model#albums_delete
post('/albums/:id/delete') do
  Db_lore.new.albums_delete(params[:id].to_i)                                                  #Ej klar 15
  redirect('/albums/')
end

# Shows the users created artists 
# 
# @see Model#artist_show
get('/artist/') do
  @result_artist = Db_lore.new.artist_show(session[:id])                                       #Ej klar 16
  slim (:"/artist/show")
end

# Sends user to the new-artist-form                                                                                   
#
# 
get('/artist/new') do                
  slim(:"artist/new")                                                                          #KLAR 17
end

# User comes to the artist form to create an artist
#
# @see Model#artist_new
post('/artist/new') do             
  Db_lore.new.artist_new(                                                                                     
  artistname = params[:artistname],
  age = params[:age].to_i,                                                                      #Ej klar 18
  country = params[:country],
  instruments = params[:instruments],
  user = session[:id])
  redirect('/artist/')
end

#
#
# @see Model#band_show
# @see Model#first_artist
# @see Model#second_artist
# @see Model#third_artist
# @see Model#fourth_artist

get('/band/') do
  db = SQLite3::Database.new("db/rocknmyb.db")
  @result = Db_lore.new.band_show(session[:id]) 

  @first_artist_id = Db_lore.new.first_artist(@result[0]['user_id'].to_i)

  @second_artist_id = Db_lore.new.second_artist(@result[0]['user_id'].to_i)                          #Ej klar 19

  @third_artist_id = Db_lore.new.third_artist(@result[0]['user_id'].to_i)

  @fourth_artist_id = Db_lore.new.fourth_artist(@result[0]['user_id'].to_i)

  slim (:'/band/index')
end


# @see Model#artist_show
get ('/band/new') do
  @artists = Db_lore.new.artist_show(session[:id])                                                    #Ej klar 20
  slim(:"band/new")
end


# @see Model#band_new
post ('/band/new') do
  Db_lore.new.band_new(params[:title], params[:starting_year], session[:id], 
  params[:artist1].to_i,                                                                              #Ej klar 21
  params[:artist2].to_i,
  params[:artist3].to_i,
  params[:artist4].to_i)
  redirect('/band/')
end 

# Updates an existing band and redirects to "/band/"
#
# @param title, the the nre title for the band 
# @param [Integer] :id the ID of the artists 
# @param [Integer] :id the ID of the user
#
# @see Model#band_update
post('/band/:id/update') do   
  Db_lore.new.band_update(
  title = params[:title],
  artist_id = params[:artist_id].to_i,
  user = session[:id])                                                                                   #hmmmmmm den är väll klar? 22
  redirect('/band/')
end

