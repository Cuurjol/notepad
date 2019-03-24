require 'i18n'
require 'optparse'
require_relative 'lib/post'
require_relative 'lib/link'
require_relative 'lib/task'
require_relative 'lib/memo'

system("clear") || system("cls")

I18n.load_path << Dir[File.expand_path("config/locales") + "/*.yml"]
locales = I18n.available_locales

if !ARGV.empty? && locales.include?(ARGV[0].to_sym)
  I18n.locale = ARGV[0]
else
  puts("List of available locales:\n\n")
  I18n.available_locales.each_with_index { |e, i| puts("#{i + 1}: #{I18n.t("languages.#{e}")}") }

  print("\nEnter the locales code: ")
  code = STDIN.gets.to_i

  abort("\nFatal error! Wrong local code. The program went out in emergency mode.") if code <= 0 || code > locales.count

  I18n.locale = locales[code - 1]
  puts
end

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
  opt.banner = I18n.t('read.option_parser.banner')

  # Вывод в случае, если запросили help
  opt.on('-h', I18n.t('read.option_parser.help')) do
    puts(opt)
    exit
  end

  # Опция --type будет передавать тип поста, который мы хотим считать
  opt.on('--type POST_TYPE', I18n.t('read.option_parser.type')) { |o| options[:type] = o.capitalize }

  # Опция --id передает номер записи в базе данных (идентификатор)
  opt.on('--id POST_ID', I18n.t('read.option_parser.id')) { |o| options[:id] = o.capitalize }

  # Опция --limit передает, сколько записей мы хотим прочитать из базы
  opt.on('--limit NUMBER', I18n.t('read.option_parser.number')) { |o| options[:limit] = o.capitalize }
end.parse!

if options[:id]
  result = Post.find_by_id(options[:id])

  if result.nil?
    # puts("Запись с id = #{options[:id]} не существует в БД!")
    puts(I18n.t('read.record.not_found', id: options[:id]))
  else
    # puts("Запись #{result.class.name}, id = #{options[:id]}")
    puts(I18n.t('read.record.found', record: result.class.name, id: options[:id]))
    result.to_strings.each { |line| puts(line) }
  end
else
  result = Post.find_all(options[:limit], options[:type])

  puts(I18n.t('read.results_table'))
  print('| id                  ')
  print('| @type               ')
  print('| @created_at         ')
  print('| @text               ')
  print('| @url                ')
  print('| @due_date           ')
  print('|')

  result.each do |row|
    puts
    row.each do |element|
      # С палкой перед ним и обрезая первые 40 символов для очень длинных строк.
      # Также удаляем символы переноса.
      element_text = "| #{element.to_s.delete("\n\r")[0..18]}"

      # Если текст элемента короткий, добавляем нужное количество пробелов
      element_text << ' ' * (22 - element_text.size)

      # Выводим текст элемента
      print(element_text)
    end
    print('|')
  end

  puts
end