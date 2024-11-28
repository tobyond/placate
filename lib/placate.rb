# frozen_string_literal: true

require "active_support"

require_relative "placate/version"
require_relative "placate/configuration"
require_relative "placate/unique_job"

module Placate
  class Error < StandardError; end
  # Your code goes here...

  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def redis
      configuration.redis
    end
  end
end
