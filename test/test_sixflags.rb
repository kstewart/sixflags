require 'rubygems'
require 'test/unit'
require 'rack'
require 'rack/test'
require 'sixflags'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

class TestApp  
  def call(env)  
    [200, {'Content-Type' => 'text/plain'}, ["Hello world!"]] 
  end  
end

class SixFlagsTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    @test_app = TestApp.new
    
    SixFlags.new(@test_app, {:config => File.join(File.dirname(__FILE__), 'config.yml')})
  end

  def test_enabled
    get '/'
    assert last_response.ok?
    assert_equal 'Hello world!', last_response.body

    get '/enabled'
    assert last_response.ok?
    assert_equal 'Hello world!', last_response.body
    
    post '/enabled'
    assert last_response.ok?
  end
  
  def test_disabled
    get '/goodbye'
    assert last_response.forbidden?
    assert_equal 'Feature disabled.', last_response.body
    
    delete '/goodbye'
    assert last_response.forbidden?
    assert_equal 'Feature disabled.', last_response.body
  end

  def test_is_not_found
    get '/foo'
    assert last_response.not_found?
    assert_equal 'Feature not found.', last_response.body
  end
end