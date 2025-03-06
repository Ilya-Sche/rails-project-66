# frozen_string_literal: true

class RealPayload
  def payload
    request.body.read
  end
end
