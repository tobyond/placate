# frozen_string_literal: true

require "digest"

module Placate
  module UniqueJob
    extend ActiveSupport::Concern

    class_methods do
      def unique_lock_ttl
        @unique_lock_ttl || Placate.configuration.default_lock_ttl
      end

      def unique_lock_ttl=(seconds)
        @unique_lock_ttl = seconds
      end
    end

    included do
      class_attribute :unique_lock_prefix, instance_writer: false, default: nil

      before_enqueue do |job|
        args_hash = Digest::MD5.hexdigest(job.arguments.to_s)
        prefix = job.class.unique_lock_prefix || job.class.name
        lock_key = "#{prefix}:#{args_hash}:lock"

        current_time = Time.now.to_i
        existing_lock = Placate.redis.get(lock_key)

        if existing_lock
          lock_time = existing_lock.to_i
          throw :abort if current_time - lock_time < (job.class.unique_lock_ttl || 30)
        end

        Placate.redis.set(lock_key, current_time)
      end

      after_perform do |job|
        args_hash = Digest::MD5.hexdigest(job.arguments.to_s)
        prefix = job.class.unique_lock_prefix || job.class.name
        lock_key = "#{prefix}:#{args_hash}:lock"

        Placate.redis.del(lock_key) if lock_key
      end
    end
  end
end
