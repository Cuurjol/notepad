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

puts("Здравствуй, я твой блокнот!")
puts("Что хотите записать в блокнот?")

choices = Post.post_types.keys
choice = -1

until choice.between?(0, choices.size - 1)
  puts(choices.map.with_index { |type, index| "\t#{index}. #{type}" }.join("\n"))
  choice = STDIN.gets.chomp.to_i
end

entry = Post.create(choices[choice])
entry.read_from_console
rowid = entry.save_to_db
puts("Запись сохранена в базе, id = #{rowid}")