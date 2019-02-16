require 'sqlite3'

class Post
  SQLITE_DB_FILE = "#{File.dirname(__FILE__)}/../notepad.sqlite3".freeze

  def self.post_types
    { 'Memo' => Memo, 'Task' => Task, 'Link' => Link }
  end

  def self.create(type)
    post_types[type].new
  end

  def initialize
    @created_at = Time.now
    @text = []
  end

  def read_from_console; end

  def to_strings; end

  def self.check_db!
    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.execute(
      'CREATE TABLE IF NOT EXISTS "main"."posts" ("type" TEXT, ' +
          '"created_at" DATETIME, "text" TEXT, "url" TEXT, "due_date" DATETIME)'
    )
    db.close
  end

  # Метод to_db_hash должен вернуть хэш типа {'имя_столбца' -> 'значение'} для
  # сохранения новой записи в базу данных
  def to_db_hash
    {
        'type' => self.class.name,
        'created_at' => @created_at.to_s
    }
  end

  def save_to_db
    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.results_as_hash = true
    post_hash = to_db_hash

    db.execute(
      'INSERT INTO posts (' + post_hash.keys.join(', ') +
          ") VALUES (#{('?,' * post_hash.size).chomp(',')})",
      post_hash.values
    )

    insert_row_id = db.last_insert_row_id
    db.close
    insert_row_id
  end

  # Метод класса find_by_id находит в базе запись по идентификатору
  def self.find_by_id(id)
    return nil if id.nil?

    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.results_as_hash = true
    result = db.execute('SELECT * FROM posts WHERE  rowid = ?', id)
    db.close

    return nil if result.empty?

    result = result[0]
    post = create(result['type'])
    post.load_data(result)
    post
  end

  # Метод класса find_all возвращает массив записей из базы данных, который
  # можно например показать в виде таблицы на экране.
  def self.find_all(limit, type)
    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.results_as_hash = false

    query = 'SELECT rowid, * FROM posts '
    query += 'WHERE type = :type ' unless type.nil?
    query += 'ORDER by rowid DESC '
    query += 'LIMIT :limit ' unless limit.nil?

    statement = db.prepare query
    statement.bind_param('type', type) unless type.nil?
    statement.bind_param('limit', limit) unless limit.nil?

    result = statement.execute!
    statement.close
    db.close

    result
  end

  # Метод load_data заполняет переменные эземпляра из полученного хэша
  def load_data(data_hash)
    @created_at = Time.parse(data_hash['created_at'])
    @text = data_hash['text']
  end
end