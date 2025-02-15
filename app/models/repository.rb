# frozen_string_literal: true

class Repository < ApplicationRecord
  belongs_to :user
  has_many :checks, class_name: 'Repository::Check'

  extend Enumerize
  enumerize :language, in: ['Ruby'], default: 'Ruby', predicates: true

  validates :name, presence: true
  validates :github_id, presence: true
  validates :full_name, presence: true
  validates :language, presence: true
  validates :clone_url, presence: true
  validates :ssh_url, presence: true
end
