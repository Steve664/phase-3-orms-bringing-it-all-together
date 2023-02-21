class Dog
attr_accessor :name, :breed, :id

def initialize name:, breed:, id: nil
    @id = id
    @name = name
    @breed = breed 
end

def self.create_table 
    sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY,name TEXT,breed TEXT)"
    DB[:conn].execute(sql)
end
def self.drop_table
    sql = "DROP TABLE IF EXISTs dogs"
    DB[:conn].execute(sql)
end

def save
sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
DB[:conn].execute(sql, self.name, self.breed)
self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

self
end

def self.create name:, breed:
 Dog.new(name: name,breed: breed ).save
end

def self.new_from_db row
    self.new(id: row[0], name: row[1], breed: row[2])
end

def self.all
    sql = "SELECT * FROM dogs" 
    DB[:conn].execute(sql).map { |row| self.new_from_db(row) }
end

def self.find_by_name name
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map {|row|  self.new_from_db(row) }.first
end

def self.find id
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    DB[:conn].execute(sql, id).map {|row|  self.new_from_db(row) }.first
end

def self.find_or_create_by name:, breed:
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
    search =  DB[:conn].execute(sql, name, breed).first
     if search 
        self.new_from_db search
     else
        self.create name: name, breed:breed
     end
end

 def update
    sql = "UPDATE dogs SET name = ? , breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
 end

end
