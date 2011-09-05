require 'bundler/setup'
require 'guard/sprockets2'

require 'aruba/cucumber'

Before do
  system "mkdir -p tmp/aruba"
  @aruba_timeout_seconds = 6
end