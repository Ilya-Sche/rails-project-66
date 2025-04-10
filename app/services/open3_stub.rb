# frozen_string_literal: true

class Open3Stub
  def self.capture3(command)
    if command.include?('rubocop')
      ['fake rubocop output', '']
    elsif command.include?('eslint')
      ['[{"filePath":"file1.rb","line":1,"ruleId":"rule1","message":"message1"}]', '']
    elsif command.include?('git clone')
      ['Cloning into \'/tmp/repo\'...', '']
    else
      ['', '']
    end
  end
end
