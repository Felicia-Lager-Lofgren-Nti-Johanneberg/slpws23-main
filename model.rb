#def register_user(username, password_digest)
require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'byebug'
require 'sqlite3'
require 'bcrypt'

class Db_lore

    def new_user(username, password_digest)
        db = SQLite3::Database.new('db/rocknmyb.db')
        db.execute("INSERT INTO User (username,pwdigest) VALUES (?,?)", username, password_digest)
    end

    def login(username, password_digest)
        db = SQLite3::Database.new('db/rocknmyb.db')   
        db.results_as_hash = true
        db.execute("SELECT * FROM User WHERE username=?",username).first
    end

    def albums() #Test
        db = SQLite3::Database.new("db/rocknmyb.db")
        db.results_as_hash = true        
        db.execute("SELECT * FROM albums WHERE user_id = ?", user)
        db.execute("SELECT album_id FROM albums")
    
    end

    def new_albums(,)
        db = SQLite3::Database.new("db/rocknmyb.db")

    end

    def edit_albums(,)
        db = SQLite3::Database.new("db/rocknmyb.db")

    end

    def delete_albums(,)
        db = SQLite3::Database.new("db/rocknmyb.db")

    end

    def band_new(,)
        db = SQLite3::Database.new("db/rocknmyb.db")

    end

    def tour_price(,)
        db = SQLite3::Database.new("db/rocknmyb.db")

    end

    def tour_show(,)
        db = SQLite3::Database.new("db/rocknmyb.db")

    end

end 


# #Validering:

# def val()
#     print "
#     ###########VALIDATE#################
#     Vilken test vill du göra?
#     Testa längd [1]
#     Jämföra password [2]
#     Bara siffror? [3]
#     Stresstest [4]"
  
#     input = gets.chomp
#     print input
#     p input
#     puts input
  
#     case input
#     when "1"
#       lengthvalidation()
#     when "2"
#       compare()
#     when "3"
#       check_digits()
#     when "4"
#       stress_test()
#     else
#       puts "Du valde ej 1,2 eller 3"
#     end
  
#     print input
#   end
  
#   def lengthvalidation() 
#     print "Skriv username. Är det för kort?"
#     input = gets
#     print input
#     if input.length <= 2
#       p "Input är #{input.chomp}"
#       p "Lösenordet är kortare än 2 bokstäver."
#     else
#       p "Input är #{input.chomp}"
#       p "Lösenordet är 2 bokstäver eller längre."
#     end
#     val()
#   end
  
#   def compare() #lösenord
#     print "Skriv password för FÖRSTA gången"
#     input1 = gets
#     print input1
#     print "Skriv password för ANDRA gången"
#     input2 = gets
#     print input2
  
#     if input1 == input2
#       p "Lösenorden översensstämmer"
#     else
#       p "Lösenorden översensstämmer ej"
#     end
#     val()
#   end
  
#   def check_digits()
#     print "Skriv din ålder. Endast siffror?"
#     input = gets.chomp
#     print input
#     answer = input.scan(/\D/).empty? #True om endast siffror eller tom sträng. RegEx: https://www3.ntu.edu.sg/home/ehchua/programming/howto/Regexe.html
#     if answer == true
#       p "Du har skrivit endast siffror (eller tom sträng)"
#     else
#       p "Du har skrivit tecken som inte är siffror"
#     end
#     val()
#   end
#   #cooldown
#   def stress_test()
#     tidarray = []
#     print "
#     Skriv password (1)"
#     input1 = gets
#     tid1 = Time.now.to_i
#     tidarray << tid1
#     p tid1
#     p tidarray
    
#     print "
#     Skriv password (2)"
#     input2 = gets
#     tid2 = Time.now.to_i
#     tidarray << tid2
#     p tid2
#     p tidarray
    
#     print "
#     Skriv password (3)"
#     input3 = gets
#     tid3 = Time.now.to_i
#     tidarray << tid3
#     p tid3
#     p tidarray
#     val()
  
#   end
  
#   val()