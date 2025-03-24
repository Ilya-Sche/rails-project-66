# frozen_string_literal: true

class RealPayloadWrapper
  def initialize(real_payload)
    @real_payload = real_payload
  end

  def call
    @real_payload.payload
  end
end
