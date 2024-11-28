# Placate

Placate is a simple Redis-based solution for preventing duplicate job execution in Ruby background job processors. It's designed to work with ActiveJob and any Redis-backed job system.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'placate'
```

And then execute:
```bash
bundle install
```

## Usage

### Basic Setup

First, configure Placate with your Redis connection:

```ruby
# config/initializers/placate.rb
Placate.configure do |config|
  config.redis = Redis.new
  config.default_lock_ttl = 30 # Default time-to-live in seconds
end
```

### In Your Jobs

Include the UniqueJob module in any job you want to prevent duplicates:

```ruby
class ProcessOrderJob < ApplicationJob
  include Placate::UniqueJob
  
  def perform(order_id)
    # Your job code here
  end
end
```

Now if you try to enqueue the same job with the same arguments within the TTL window, the duplicate will be prevented:

```ruby
ProcessOrderJob.perform_later(order_id: 123) # First job enqueued
ProcessOrderJob.perform_later(order_id: 123) # Blocked as duplicate
ProcessOrderJob.perform_later(order_id: 456) # Different args, will be enqueued
```

### Customization

You can customize the TTL per job class:

```ruby
class LongRunningJob < ApplicationJob
  include Placate::UniqueJob
  
  self.unique_lock_ttl = 120 # 2 minutes
  
  def perform
    # Your job code here
  end
end
```

Or use a custom key prefix:

```ruby
class CustomPrefixJob < ApplicationJob
  include Placate::UniqueJob
  
  self.unique_lock_prefix = 'my_app_jobs'
  
  def perform
    # Your job code here
  end
end
```

## How It Works

Placate uses Redis to maintain a lock based on the job class name and arguments. When a job is enqueued (`before_enqueue`):

1. A unique key is generated based on the job class and arguments
2. The current timestamp is stored in Redis with this key
3. If a key exists and its timestamp is within the TTL window, the job is not enqueued
4. If no key exists or the existing timestamp is older than the TTL, the job is enqueued

After the job is performed (`after_perform`):

1. The unique key is deleted, to enable the next job.

## Requirements

- Ruby 3.3+
- Rails 7.0+
- Redis

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub. This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
