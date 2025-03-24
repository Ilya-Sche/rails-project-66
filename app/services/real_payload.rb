# frozen_string_literal: true

class RealPayload
  def initialize(request)
    @request = request
  end

  def payload
    JSON.parse(@request.body.read)
  end
end
