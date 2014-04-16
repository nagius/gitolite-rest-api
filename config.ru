require './api'

class App < Sinatra::Application
	configure do
		# Don't capture any errors. Throw them up the stack
		set :raise_errors, true
		 
		# Disable internal middleware for presenting errors
		# as useful HTML pages
		set :show_exceptions, false
	end
end
 
class ExceptionHandling
	def initialize(app)
		@app = app
	end
	 
	def call(env)
		begin
			@app.call env
		rescue => ex
			env['rack.errors'].puts ex
			env['rack.errors'].puts ex.backtrace.join("\n")
			env['rack.errors'].flush
			 
			hash = { :message => ex.to_s }
			 
			[500, {'Content-Type' => 'text/html'}, ["Internal server error.\n"]]
		end
	end
end
 
use ExceptionHandling
run App
