# frozen_string_literal: true

class RealPayload
  def initialize(params, request, body)
    @params = params
    @request = request
    @body = body
  end

  def payload
    JSON.parse(@request.body.read)
  end
end
