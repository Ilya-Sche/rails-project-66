# frozen_string_literal: true

class RealPayload
  def initialize(params)
    @params = params
  end

  def payload
    @params
  end
end
