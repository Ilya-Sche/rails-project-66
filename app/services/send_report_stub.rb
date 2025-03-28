# frozen_string_literal: true

class SendReportStub
  def initialize(repository_full_name)
    @repository_full_name = repository_full_name
  end

  def run_rubocop
    {
      'files' => [
        {
          'path' => 'app/models/user.rb',
          'offenses' => [
            {
              'severity' => 'convention',
              'message' => 'Line is too long. [81/80]',
              'cop_name' => 'Layout/LineLength',
              'location' => {
                'line' => 10,
                'column' => 81,
                'length' => 1
              }
            }
          ]
        }
      ]
    }.to_json
  end

  def send_rubocop_report(_repository_full_name, _user_email)
    run_rubocop
  end
end
