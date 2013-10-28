require 'rack/session/php'

app = lambda {|env|
  env["rack.session"]["counter"] ||= 0
  env["rack.session"]["counter"] += 1
  Rack::Response.new(env["rack.session"].inspect).to_a
}

use Rack::Session::PHP, :session_file_dir => Dir.tmpdir

run app
