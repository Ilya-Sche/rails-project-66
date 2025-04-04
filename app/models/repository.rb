# frozen_string_literal: true

class Repository < ApplicationRecord
  belongs_to :user
  has_many :checks, class_name: 'Repository::Check', dependent: :destroy

  extend Enumerize
  enumerize :language, in: %w[Ruby JavaScript], default: 'Ruby', predicates: true

  validates :github_id, presence: true
end
