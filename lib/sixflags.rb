require 'rack'
require 'redis'

class SixFlags
  def initialize(app, options)
    @app      = app
    @options  = options
    host = @options[:host] ? @options[:host]:"127.0.0.1"
    port = @options[:port] ? @options[:port]:6789
    
    @config = Redis.new(:host => host, :port => port)
  end
  
  # TODO: Look at using Redis' hash features to store config
  # TODO: Add a prefix to the keys
  
  def call(env)
    req   = Rack::Request.new(env)
    scope = req.env["RACK_ENV"] ? req.env["RACK_ENV"]:"test"
    url   = req.path
    # request_method = env['REQUEST_METHOD']
    # if ['GET', 'POST', 'DELETE', 'PUT', 'HEAD'].include?(request_method)
    
    if @config[url] == "true"
      @app.call(env)
    elsif @config[url] == "false"
      [403, {}, ["Feature disabled."]]
    else
      [404, {}, ["Feature not found."]]
    end
  end
end