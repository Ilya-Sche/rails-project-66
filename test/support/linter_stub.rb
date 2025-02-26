# frozen_string_literal: true

class LinterStub
  def run(_code)
    { success: true, messages: [] }
  end
end
