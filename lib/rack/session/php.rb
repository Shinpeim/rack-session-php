require "rack/session/abstract/id"
require "php_session"

module Rack
  module Session
    class PHP < Rack::Session::Abstract::ID
      def initialize(app, options = {})
        @session = PHPSession.new(options)
        @mutex = Mutex.new

        super(app, options)
      end

      def generate_sid
        loop do
          sid = super
          break sid if ! @session.exists?(sid)
        end
      end

      def get_session(env, sid)
        with_lock(env) do
          if sid
            data = @session.load(sid)
          else
            data = {}
          end

          if sid.nil? || data.empty?
            sid = generate_sid
          end

          [sid, data]
        end
      end

      def set_session(env, sid, session, options)
        with_lock(env) do
          @session.save(sid, session)
          sid
        end
      end

      def destroy_session(env, sid, options)
        with_lock(env) do
          @session.destroy(sid)
          generate_sid unless options[:drop]
        end
      end

      private

      def with_lock(env, default=nil)
        @mutex.lock if env['rack.multithread']
        yield
      ensure
        @mutex.unlock if @mutex.locked?
      end
    end
  end
end
