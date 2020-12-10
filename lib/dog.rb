require 'pry'
class Dog 
    attr_accessor :name, :breed
    attr_reader :id 

    def initialize(name:, breed:, id: nil)
        @name = name 
        @breed = breed 
        @id = id
    end
    
    def self.create(doggy_attributes) 
        self.new(name: doggy_attributes[:name], breed: doggy_attributes[:breed]).save
    end 

    def self.new_from_db(row)
        dog = self.new(id: row[0], name: row[1], breed: row[2])
        @id = row[0]
        dog
    end 

    def self.find_by_id(id_num)
        sql = <<-SQL
            SELECT * 
            FROM dogs 
            WHERE id = ?
        SQL
        
        dog = DB[:conn].execute(sql, id_num)[0]
        self.new_from_db(dog) 
    end 

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs 
            WHERE name = ?
        SQL

        dog = DB[:conn].execute(sql, name)[0]
        self.new_from_db(dog)
    end 
    
    def self.find_or_create_by(doggy_attributes)
        sql = <<-SQL 
            SELECT *
            FROM dogs 
            WHERE name = ? AND breed = ? 
            LIMIT 1
        SQL
        

        dog = DB[:conn].execute(sql, doggy_attributes[:name], doggy_attributes[:breed])
      
        if !dog.empty?
            doggy_attributes = dog[0]
     
            self.new_from_db(doggy_attributes)
        else 
            self.create(name: doggy_attributes[:name], breed: doggy_attributes[:breed])
        end
    end 


    def self.create_table 
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        
        DB[:conn].execute(sql)
    end 

    def self.drop_table 
        sql = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end 

    def save 
        sql = <<-SQL 
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT id FROM DOGS ORDER BY id DESC LIMIT 1")[0][0]
        self
    end 
    
    def update 
        sql = <<-SQL
            UPDATE dogs 
            SET name = ?, breed = ? 
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end 
end 