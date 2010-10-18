require 'rack'
require 'redis'
require 'json'

class SixFlags
  def initialize(app, options)
    @app      = app
    @options  = options
    host      = @options[:host] ? @options[:host]:"127.0.0.1"
    port      = @options[:port] ? @options[:port]:6789
    @prefix   = @options[:prefix] ? @options[:prefix]:""
    
    @config = Redis.new(:host => host, :port => port)
  end
  
  def call(env)
    req   = Rack::Request.new(env)
    scope = req.env["RACK_ENV"] ? req.env["RACK_ENV"]:"test"
    uri   = req.path
    
    key = "#{@prefix}:#{scope}"
    methods = @config.hget(key, uri)
    
    unless methods
      [404, {}, ["URI not found."]]
    else
      # Check for wildcard or explicit HTTP method
      methods = JSON.parse(methods)
      if methods.include?('*') || methods.include?(env['REQUEST_METHOD'].upcase)
        @app.call(env)
      else
        [403, {}, ["Feature disabled."]]
      end
    end
  end
end