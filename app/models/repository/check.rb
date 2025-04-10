# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  include AASM

  self.table_name = 'repository_checks'

  belongs_to :repository
  has_many :linter_errors, dependent: :destroy

  aasm column: :aasm_state do
    state :created, initial: true
    state :checking
    state :finished
    state :failed

    event :start_check do
      transitions from: :created, to: :checking
    end

    event :complete_check do
      transitions from: :checking, to: :finished
    end

    event :fail_check do
      transitions from: %i[created checking], to: :failed
    end
  end

  def commit_link
    "https://github.com/#{repository.full_name}/commit/#{commit_id}"
  end
end
