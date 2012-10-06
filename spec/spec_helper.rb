TEST_DB_FILE = "#{Dir.pwd}/test.sqlite3"
File.delete(TEST_DB_FILE) if File.exists?(TEST_DB_FILE)
ENV["DATABASE_URL"] = "sqlite3:///#{TEST_DB_FILE}"

require File.join(File.dirname(__FILE__), '..', 'cloud_tunnel_redirect.rb')

require 'sinatra'
require 'rack/test'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

def app
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
