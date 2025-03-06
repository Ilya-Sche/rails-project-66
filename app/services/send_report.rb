# frozen_string_literal: true

class SendReport
  def initialize(repository_full_name)
    @repository_full_name = repository_full_name
  end

  def send_report(user_email, repository_full_name)
    repo_dir = Rails.root.join('tmp', 'repos', repository_full_name)
    file_path = Rails.root.join("#{repo_dir}/rubocop_report.json")

    RubocopMailer.send_rubocop_report(user_email, file_path).deliver_now
  end
end
