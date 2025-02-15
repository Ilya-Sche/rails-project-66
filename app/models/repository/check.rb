# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  include AASM

  self.table_name = 'repository_checks'

  belongs_to :repository
  has_many :rubocop_errors

  aasm column: :status do
    state :pending, initial: true
    state :in_progress
    state :completed
    state :failed

    event :start_check do
      transitions from: :pending, to: :in_progress
    end

    event :complete_check do
      transitions from: :in_progress, to: :completed
    end

    event :fail_check do
      transitions from: %i[pending in_progress], to: :failed
    end
  end
end
