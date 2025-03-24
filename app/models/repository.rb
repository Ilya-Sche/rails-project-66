# frozen_string_literal: true

class Repository < ApplicationRecord
  belongs_to :user
  has_many :checks, class_name: 'Repository::Check', dependent: :destroy

  extend Enumerize
  enumerize :language, in: %w[Ruby JavaScript], default: 'Ruby', predicates: true

  scope :owner, ->(user) { where(user_id: user.id) }

  validates :name, presence: true
  validates :github_id, presence: true
  validates :full_name, presence: true
  validates :language, presence: true
  validates :clone_url, presence: true
  validates :ssh_url, presence: true
end
