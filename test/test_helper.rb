ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Set up transactional tests
  self.use_transactional_tests = true

  # Add more helper methods to be used by all tests here...
  # Ensure each test starts with a clean state for certain tables
  setup do
    # This will run before each test in all test classes
    Guest.delete_all
    Reservation.delete_all
  end
end
