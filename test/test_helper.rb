# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "placate"

require "minitest/autorun"
require "active_job"

class MockRedis
  attr_reader :store

  def initialize
    @store = {}
  end

  def set(key, value)
    @store[key] = value.to_s
    true
  end

  def get(key)
    @store[key]
  end

  def del(key)
    @store.delete(key)
  end
end
