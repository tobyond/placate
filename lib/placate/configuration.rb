# frozen_string_literal: true

module Placate
  class Configuration
    attr_accessor :redis, :default_lock_ttl

    def initialize
      @default_lock_ttl = 60 # 1 minute default
    end
  end
end
