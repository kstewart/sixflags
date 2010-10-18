# SixFlags - Rack Middleware for RESTful API Feature Flags

*Because deploying features straight to production is a [Great Adventure](http://www.sixflags.com/greatAdventure/index.aspx)&#174;!*

SixFlags is a Rack middleware that implements the concept of [feature flags](http://code.flickr.com/blog/2009/12/02/flipping-out/), but for RESTful APIs. If you are implementing a standalone API (or your webapp is a client of your API), SixFlags allows you to cleanly enable/disable functionality without injecting a ton of conditionals in your code. 

## Usage

To configure the SixFlags middleware, specify a prefix for the Redis keys and, optionally, the host and port on which your Redis instance is running:

    require 'sixflags'
	use SixFlags, { 
		:host => "127.0.0.1", 
		:port => 6379, 
		:prefix => "myapp:prefix"
	}
    
In Redis, use the [hash commands](http://code.google.com/p/redis/wiki/HsetCommand) to specify which URI/method combinations are enabled. You can use a wildcard to enable all HTTP methods:

	HSET "#{:prefix}:#{RACK_ENV}" "#{URI}" ['*']
	
Or, explicitly list which methods to enable:

	HSET "#{:prefix}:#{RACK_ENV}" "#{URI}" ['GET', 'POST', 'HEAD']
    
*Note: The absence of a URI or URI/method combination is implicitly interpreted as that "feature" being disabled.*

SixFlags will parse the incoming request and perform a lookup against the database. There are 3 possible responses:

* 200: URI matched and method enabled. Pass through to the next Rack middleware in the stack.
* 403: URI matched and method disabled. Feature not available for this request.
* 404: URI did not match any entries in the configuration database.

## TODO

* Package as a gem
* Write a small Sinatra application to administer the configuration database
* Add more tests

## Resources

* [Flipping Out](http://code.flickr.com/blog/2009/12/02/flipping-out/)
* [How We Deploy New Features](http://github.com/blog/677-how-we-deploy-new-features)
* [How We Deploy New Features on Forrst](http://blog.forrst.com/post/782356699/how-we-deploy-new-features-on-forrst)
* [Redis Feature Control](http://github.com/bvandenbos/redis_feature_control)

## Author

* [Kevin Stewart](mailto:kevin@working-code.com) - <http://working-code.com/>

## License

See LICENSE.
