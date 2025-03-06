# frozen_string_literal: true

class RubocopReport
  def initialize(repository_full_name)
    @repository_full_name = repository_full_name
    @repo_dir = Rails.root.join('tmp', 'repos', repository_full_name)
  end

  def run_rubocop
    rubocop_config_path = Rails.root.join('.rubocop.yml')

    `cd #{@repo_dir} && rubocop --config #{rubocop_config_path} --format json --out #{@repo_dir}/rubocop_report.json`
  end

  def read_rubocop_report
    Rails.root.join(@repo_dir, 'rubocop_report.json').read
  end
end
