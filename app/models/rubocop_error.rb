# frozen_string_literal: true

class RubocopError < ApplicationRecord
  belongs_to :check, class_name: 'Repository::Check'
end
