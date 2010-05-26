require 'rack'
require 'yaml'

class SixFlags
  def initialize(app, options)
    @app      = app
    @options  = options
    if @options[:config]
      @config = YAML.load(File.open(@options[:config]))
    else
      @options[:config] = nil
    end
  end
  
  def call(env)
    req   = Rack::Request.new(env)
    url   = req.path
    
    if @config[url] == true
      @app.call(env)
    elsif @config[url] == false
      [403, {}, ["Feature disabled."]]
    else
      [404, {}, ["Feature not found."]]
    end
  end
end