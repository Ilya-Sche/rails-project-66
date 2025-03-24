# frozen_string_literal: true

class Repository::CheckPolicy < ApplicationPolicy
  def show?
    user == record.repository.user
  end
end
