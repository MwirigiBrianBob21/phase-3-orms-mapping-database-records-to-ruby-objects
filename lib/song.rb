class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  def self.new_from_db(row)
    # self.new is equivalent to Song.new
    # reading data from SQLite and temporarily representing in ruby
    self.new(id: row[0], name: row[1], album: row[2])
  end

  def self.all 
    # this will return an array of rows from 
    # db that matches our query.
    sql = <<-SQL
      SELECT * FROM songs
    SQL
    # iterate over each row and using the self.map
    # method to create a new Ruby object for each row
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end
  
    # Song.find_by_name
    # this will return an array of rows from 
    # db that matches our query.
    # we have to include a name in our SQL statement
    # this is by using question mark where we want the name parameter
    # to be passed in
    def self.find_by_name(name)
      sql = <<-SQL
        SELECT * FROM songs
        WHERE name = ?
        LIMIT 1
      SQL

      # iterate over each row and using the self.map
      # map will return an array, then grab the first elem 
      # from the returned aray - Chaining
      DB[:conn].execute(sql,name).map do |row|
        self.new_from_db(row)
      end.first
    end    
      # 

end
