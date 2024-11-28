# frozen_string_literal: true

require "test_helper"

class TestPlacate < Minitest::Test
  def setup
    @redis = MockRedis.new
    Placate.configure do |config|
      config.redis = @redis
      config.default_lock_ttl = 60
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Placate::VERSION
  end

  def test_configuration
    assert_equal 60, Placate.configuration.default_lock_ttl
    assert_instance_of MockRedis, Placate.configuration.redis
  end
end
