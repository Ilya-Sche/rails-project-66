# frozen_string_literal: true

class User < ApplicationRecord
  has_many :repositories, class_name: 'Repository', dependent: :destroy
end
