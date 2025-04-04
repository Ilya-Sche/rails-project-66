# frozen_string_literal: true

class LinterError < ApplicationRecord
  belongs_to :check, class_name: 'Repository::Check', dependent: :destroy
end
