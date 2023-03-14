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
     Db_lore.new.new_user(username, password_digest)
     redirect('/')
   else
    "wrong"
   end
 end

# 2 Skapa Login och logga in, ha med validering, authorization och authentication (rb kod)

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
    redirect('/')
 end
 

# require 'sinatra/flash' # OBS! gem install sinatra-flash

# get('/logout') do
#    # logik för utloggning [...]
#    flash[:notice] = "You have been logged out!"
#    redirect('/')
# end



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


# 4 Skapa artister och forma band (table:Artists) Välj instrument till alla spelare (table:Instrument) => relation Artists
get('/band') do  
  user = session[:id] #sparar vilken användare som är inloggad
  current_band = db.execute("SELECT * FROM band")
  p current_band
  result = db.execute("SELECT * FROM artists WHERE user_id = ?", user)
  p result

  slim(:"/band/index",locals:{band:result})
end

get('/new_artist') do
  slim(:"band/new")
end

post('/band') do  
  title = params[:title]
  starting_year = params[:starting_year]

  artistname = params[:artistname]
  age = params[:age]
  country = params[:country]
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


get('/tour/show') do
  db = SQLite3::Database.new("db/rocknmyb.db") #ta bort
  db.results_as_hash = true #ta bort
  result_name = db.execute("SELECT name FROM Tour") #model
  result_city = db.execute("SELECT city FROM Tour")  #model
  result_price = db.execute("SELECT price FROM Tour") #model
  p result_name
  slim(:index)
end
