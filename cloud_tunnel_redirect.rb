require 'sinatra'
require 'dm-core'
require 'dm-serializer'
require 'dm-migrations'

class Route
  include DataMapper::Resource
  property :id, Serial
  property :source, String, :unique => true 
  property :destination, String
  property :port, Integer
end

configure do
  DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/development.sqlite3"))
  DataMapper.auto_upgrade!
end

get '/' do
  route = Route.last(:source => parse_hostname(request.host))
  if route
    redirect_path = "#{route.destination}" + (route.port.nil? ? '' : ":#{route.port}")
    redirect redirect_path, 302
  else
    halt 404, 'Not found.'
  end
end

post '/route' do
  source = params["source"]
  destination = params["destination"]
  if source && destination
    route = set_route(source, destination)
    return route.to_json if route
  end

  halt 403, 'Invalid parameters.'
end

delete '/route' do
  source = params["source"]
  if source && validate_source(source)
    route = Route.first(:source => source)

    if route
      route.destroy
      status 200
      return route.to_json
    else
      halt 404, 'Not found.'
    end
  end
  halt 403, 'Invalid parameters.'
end

private 

def set_route(source, destination)
  return false unless validate_source(source) && validate_destination(destination) 
  route = Route.first_or_create(:source => source)
  route.update(:destination => ensure_scheme(destination))
  route
end

def validate_source(source)
  (source =~ /([^\w]+)/).nil?
end

def validate_destination(destination)
  begin
    URI.parse(ensure_scheme(destination)).kind_of?(URI::HTTP)
  rescue => e
    puts e.message
    false
  end
end

def ensure_scheme(hostname)
  "http://#{hostname}" if hostname.match(/^http:\/\//i).nil?
end

def parse_hostname(host_string)
  host_string.split('.').first
end
