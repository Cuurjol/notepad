require 'optparse'
require_relative 'lib/post'
require_relative 'lib/link'
require_relative 'lib/task'
require_relative 'lib/memo'

if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

Post.check_db!

options = {}
OptionParser.new do |opt|
  # Этот текст будет выводиться, когда программа запущена с опцией -h
  opt.banner = 'Usage: read.rb [options]'

  # Вывод в случае, если запросили help
  opt.on('-h', 'Prints this help') do
    puts(opt)
    exit
  end

  # Опция --type будет передавать тип поста, который мы хотим считать
  opt.on('--type POST_TYPE', 'какой тип постов показывать ' +
      '(по умолчанию любой)') { |o| options[:type] = o.capitalize }

  # Опция --id передает номер записи в базе данных (идентификатор)
  opt.on('--id POST_ID', 'если задан id — показываем подробно ' +
      'только этот пост') { |o| options[:id] = o.capitalize }

  # Опция --limit передает, сколько записей мы хотим прочитать из базы
  opt.on('--limit NUMBER', 'сколько последних постов показать ' +
      '(по умолчанию все)') { |o| options[:limit] = o.capitalize }
end.parse!

if options[:id]
  result = Post.find_by_id(options[:id])

  if result.nil?
    puts("Запись с id = #{options[:id]} не существует в БД!")
  else
    puts("Запись #{result.class.name}, id = #{options[:id]}")
    result.to_strings.each { |line| puts(line) }
  end
else
  result = Post.find_all(options[:type], options[:limit])

  print('| id                 ')
  print('| @type              ')
  print('| @created_at        ')
  print('| @text              ')
  print('| @url               ')
  print('| @due_date          ')
  print('|')

  result.each do |row|
    puts
    row.each do |element|
      # С палкой перед ним и обрезая первые 40 символов для очень длинных строк.
      # Также удаляем символы переноса.
      element_text = "| #{element.to_s.delete("\n\r")[0..17]}"

      # Если текст элемента короткий, добавляем нужное количество пробелов
      element_text << ' ' * (21 - element_text.size)

      # Выводим текст элемента
      print(element_text)
    end
    print('|')
  end

  puts
end