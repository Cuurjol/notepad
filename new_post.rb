require 'i18n'
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

puts(I18n.t('new_post.greeting'))
puts(I18n.t('new_post.question'))

choices = Post.post_types.keys
choice = -1

until choice.between?(0, choices.size - 1)
  puts(choices.map.with_index { |type, index| "\t#{index}. #{type}" }.join("\n"))
  choice = STDIN.gets.chomp.to_i
end

entry = Post.create(choices[choice])
entry.read_from_console
rowid = entry.save_to_db
puts(I18n.t('new_post.created_record', rowid: rowid))