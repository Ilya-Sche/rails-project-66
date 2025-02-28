# frozen_string_literal: true

class RubocopMailer < ApplicationMailer
  default from: 'example@mail.com'

  def send_rubocop_report(user_email, file_path)
    file_content = JSON.parse(File.read(file_path))

    report = format_rubocop_report(file_content)

    mail(to: user_email, subject: I18n.t('rubocop.found')) do |format|
      format.text { render plain: report }
      format.html { render html: "<pre>#{report}</pre>" }
    end
  end

  private

  def format_rubocop_report(report)
    formatted_report = "RuboCop Report\n\n"
    formatted_report += "Offense Count: #{report['summary']['offense_count']}\n\n"
    formatted_report += "Files Inspected: #{report['summary']['inspected_file_count']}\n\n"

    report['files'].each do |file|
      formatted_report += "File: #{file['path']}\n"
      if file['offenses'].any?
        file['offenses'].each do |offense|
          formatted_report += "  - Severity: #{offense['severity']}\n"
          formatted_report += "    Message: #{offense['message']}\n"
          formatted_report += "    Line: #{offense['location']['line']}, Column: #{offense['location']['column']}\n"
          formatted_report += "\n"
        end
      else
        formatted_report += "  No offenses found.\n\n"
      end
    end

    formatted_report
  end
end
