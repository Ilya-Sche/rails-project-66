# frozen_string_literal: true

class LinterStub
  def run(code)
    { success: true, messages: [] }
  end
end
