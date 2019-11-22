require_relative "../lib/hash-mapper"

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |c|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  c.order = :random

  c.example_status_persistence_file_path = 'tmp/rspec.failures'

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # c.profile_examples = 10

  c.before(:each) do
  end
end
