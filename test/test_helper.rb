# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "bubblezone"
require "maxitest/autorun"

def scan_and_wait(text, delay: 0.01)
  result = Bubblezone.scan(text)
  sleep delay
  result
end

module ManagerTestHelper
  def scan_and_wait(text, delay: 0.01)
    result = scan(text)
    sleep delay
    result
  end
end

Bubblezone::Manager.include(ManagerTestHelper)
