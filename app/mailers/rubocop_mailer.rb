# frozen_string_literal: true

class RubocopMailer < ApplicationMailer
  def send_rubocop_report(user_email, repository_id, check_id)
    @report_url = repository_check_url(repository_id, check_id)
    mail(to: user_email, subject: I18n.t('rubocop.found'), template_name: 'rubocop_report')
  end
end
