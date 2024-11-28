# frozen_string_literal: true

require_relative "placate/version"
require_relative "placate/configuration"
require_relative "placate/unique_job"

module Placate
  class Error < StandardError; end

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
