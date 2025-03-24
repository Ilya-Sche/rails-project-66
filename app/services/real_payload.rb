# frozen_string_literal: true

class RealPayload
  def initialize(request)
    @request = request
  end

  def payload
    @request.body.read
  end
end
