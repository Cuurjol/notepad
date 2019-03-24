require 'date'

class Task < Post
  def initialize
    super

    @due_date = Time.now
  end

  def read_from_console
    puts(I18n.t('task.description'))
    @text = STDIN.gets.chomp

    puts(I18n.t('task.date'))
    input = STDIN.gets.chomp

    @due_date = Date.parse(input)
  end

  def to_strings
    time_string = "#{I18n.t('task.created', created_at: @created_at.strftime('%Y.%m.%d, %H:%M:%S'))} \n"
    deadline = I18n.t('task.deadline', due_date: @due_date)
    [deadline, @text, time_string]
  end

  def to_db_hash
    super.merge('text' => @text, 'due_date' => @due_date.to_s)
  end

  def load_data(data_hash)
    super
    @due_date = Date.parse(data_hash['due_date'])
  end
end