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

post('/users/new') do   #Ny användare
    
  username = params[:username]
   password = params[:password]
   password_confirm = params[:password_confirm]
 
   if (password == password_confirm)
     #Lägg till användare
     password_digest = BCrypt::Password.create(password)
     db = SQLite3::Database.new('db/rocknmyb.db')
     db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)", username, password_digest)
     redirect('/')
   else
     "Fel lösen"
   end
 end

get('/showlogin') do   #loginsida
   slim(:login)
 end
 
 post('/login') do
     username = params[:username]
     password = params[:password]
     db = SQLite3::Database.new("db/rocknmyb.db")   ### döp om DB Browser till rock'n'myb
     db.results_as_hash = true
     result=db.execute("SELECT * FROM users WHERE username=?",username).first
     pwdigest = result["pwdigest"]
     id = result["id"]
   
     if BCrypt::Password.new(pwdigest) == password
       session[:id] = id
       redirect('/')
     else
       "Fel lösen 3"  
     end
   end


#post('/albums/:id/delete') do     # post som raderar och även kommer ihåg vad du har raderat.
#  id = params[:id].to_i
#  db = SQLite3::Database.new("db/chinook-crud.db")
#  db.execute("DELETE FROM albums WHERE AlbumId = ?",id)
#  redirect('/albums')
#end