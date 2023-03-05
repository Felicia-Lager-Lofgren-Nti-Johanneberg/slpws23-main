require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'byebug'
require 'sqlite3'
require 'bcrypt'


enable :sessions

output=[]


get('/')  do
  slim(:start)
end 

get '/index' do
  slim(:index)
end

# 1 Skapa regristrerignen

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
     db = SQLite3::Database.new('db/rocknmyb.db')
     db.execute("INSERT INTO User (username,pwdigest) VALUES (?,?)", username, password_digest)
     redirect('/')
   else
     "Fel lösen"
   end
 end

# 2 Skapa Login och logga in, ha med validering, authorization och authentication (rb kod)

get('/showlogin') do   #loginsida
   slim(:login)
 end
 
 post('/login') do
     username = params[:username]
     password = params[:password]
     db = SQLite3::Database.new('db/rocknmyb.db')   ### döp om DB Browser till rock'n'myb
     db.results_as_hash = true
     result=db.execute("SELECT * FROM User WHERE username=?",username).first
     pwdigest = result["pwdigest"]
     id = result["id"]
   
     if BCrypt::Password.new(pwdigest) == password
       session[:id] = id
       redirect('/')
     else
       "Fel lösen 3"  
     end
   end


# 3 Visa vilka albums som finns och skapa egna album som sparas (+ radera och ändra?) CREATE READ UPDATE DELETE

get('/albums') do
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.results_as_hash = true
  user = session[:id]
  result = db.execute("SELECT * FROM albums WHERE user_id = ?", user)
  current_albums = db.execute("SELECT album_id FROM albums")
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
  user = session[:id]
  p "Vi fick in datan #{title} och #{artist_id}"
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.execute("INSERT INTO albums (title, artist_id, user_id) VALUES (?,?,?)",title, artist_id, user)
  
  redirect('/albums')
end



get'/albums/:id' do
  db = SQLite3::Database.new("db/rocknmyb.db")
  @result = db.execute("SELECT * FROM albums WHERE album_id = ?",params[:id]).first
  p "result är #{@result}"
  
  slim(:"albums/edit")
end

post('/update/:id/') do   #EDIT
  title = params[:title]
  artist_id = params[:artist_id].to_i
  user = session[:id]
  p "Vi fick in datan #{title} och #{artist_id}"
  db = SQLite3::Database.new("db/rocknmyb.db")
  db.execute("INSERT INTO albums (title, artist_id, user_id) VALUES (?,?,?)",title, artist_id, user)
  
  redirect('/albums')
end


post('/albums/upload_image') do
  #Skapa en sträng med join "./public/uploaded_pictures/cat.png"
  path = File.join("./public/uploaded_pictures/",params[:file][:filename])
  
  #Spara bilden (skriv innehållet i tempfile till destinationen path)
  File.write(path,File.read(params[:file][:tempfile]))
  
  redirect('/albums/upload_image')
 end

# post('albums/:id/delete/')
#   id = params[:id].to_i
#   db = SQLite3::Database.new("db/rocknmyb.db")
#   db.execute("DELETE FROM albums WHERE album_id = ?",id)
# end


# 4 Skapa artister och forma band (table:Artists)

# 5 Välj instrument till alla spelare (table:Instrument) => relation Artists

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

end

get('/') do
 # Visa calculator-sidan
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
  slim :result
  redirect('/tour')

end

#ELLER 

post '/calculate' do
  num1 = params[:num1].to_f
  num2 = params[:num2].to_f
  operator = params[:operator]

  case operator
  when 'add'
    result = num1 + num2
  when 'subtract'
    result = num1 - num2
  when 'multiply'
    result = num1 * num2
  when 'divide'
    result = num1 / num2
  end
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
