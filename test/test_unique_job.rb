# frozen_string_literal: true

require "test_helper"

class TestJob < ActiveJob::Base
  include Placate::UniqueJob
  queue_as :default

  def perform(*_args)
    true
  end
end

class UniqueJobTest < Minitest::Test
  include ActiveJob::TestHelper

  def setup
    @redis = MockRedis.new
    Placate.configure do |config|
      config.redis = @redis
      config.default_lock_ttl = 30
    end
    ActiveJob::Base.queue_adapter = :test
  end

  def test_prevents_duplicate_jobs
    TestJob.perform_later
    TestJob.perform_later
    assert_equal 1, ActiveJob::Base.queue_adapter.enqueued_jobs.size
  end

  def test_allows_jobs_with_different_args
    TestJob.perform_later("arg1")
    TestJob.perform_later("arg2")
    assert_equal 2, ActiveJob::Base.queue_adapter.enqueued_jobs.size
  end

  def test_allows_job_after_ttl
    TestJob.perform_later

    # Simulate time passing
    lock_key = "TestJob:#{Digest::MD5.hexdigest([].to_s)}:lock"
    @redis.set(lock_key, (Time.now.to_i - 31))

    TestJob.perform_later
    assert_equal 2, ActiveJob::Base.queue_adapter.enqueued_jobs.size
  end

  def test_removes_lock_after_enqueue
    perform_enqueued_jobs do
      job = TestJob.perform_later
      lock_key = job.instance_variable_get(:@unique_lock_key)
      assert_nil @redis.get(lock_key)
    end
  end

  def test_allows_immediate_job_after_successful_perform
    perform_enqueued_jobs do
      TestJob.perform_later
    end
    # Since lock is removed after enqueue, this should work
    perform_enqueued_jobs do
      TestJob.perform_later
    end

    assert_performed_jobs 2
  end

  def teardown
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end
end
