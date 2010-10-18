$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'minitest/autorun'
require 'rack'
require 'rack/test'
require 'redis'
require 'sixflags'

class MiniTest::Unit::TestCase
  include Rack::Test::Methods
end

ENV['RACK_ENV'] = 'test'

class TestApp  
  def call(env)  
    [200, {'Content-Type' => 'text/plain'}, ["Hello world!"]] 
  end  
end

class SixFlagsTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    @test_app = TestApp.new
    
    SixFlags.new(@test_app, {:host => "127.0.0.1", :port => 6379})
  end

  def setup
    config = Redis.new
    config.set "/", true       
    config.set "/hello", true
    config.set "/goodbye", false
    config.set "/enabled", true
    config.set "/disabled", false
  end
  
  def teardown
    config = Redis.new
    config.del "/"        
    config.del "/hello"
    config.del "/goodbye"
    config.del "/enabled"
    config.del "/disabled"
  end
  
  def test_enabled
    get '/'
    assert last_response.ok?, "Expected 200, got #{last_response.status}"
    assert_equal 'Hello world!', last_response.body

    get '/enabled'
    assert last_response.ok?, "Expected 200, got #{last_response.status}"
    assert_equal 'Hello world!', last_response.body
    
    post '/enabled', "Expected 200, got #{last_response.status}"
    assert last_response.ok?
  end
  
  def test_disabled
    get '/goodbye'
    assert last_response.forbidden?, "Expected 403, got #{last_response.status}"
    assert_equal 'Feature disabled.', last_response.body
    
    delete '/goodbye'
    assert last_response.forbidden?, "Expected 403, got #{last_response.status}"
    assert_equal 'Feature disabled.', last_response.body
  end

  def test_is_not_found
    get '/foo'
    assert last_response.not_found?, "Expected 404, got #{last_response.status}"
    assert_equal 'Feature not found.', last_response.body
  end
end