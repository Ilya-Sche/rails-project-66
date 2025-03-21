# frozen_string_literal: true

class RubocopReportStub
  def initialize(repository_full_name)
    @repository_full_name = repository_full_name
  end

  def run_rubocop
    {
      'files' => [
        {
          'path' => 'app/models/user.rb'
        }
      ]
    }.to_json
  end

  def read_rubocop_report
    run_rubocop
  end
end
