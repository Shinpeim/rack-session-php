# -*- coding: utf-8 -*-
require 'spec_helper'
require 'rack/session/php'
require 'rack/lint'
require 'rack/mock'
require 'tempfile'

describe Rack::Session::PHP do
  session_key = Rack::Session::PHP::DEFAULT_OPTIONS[:key]
  session_match = /#{session_key}=([0-9a-fA-F]+);/
  incrementor = lambda do |env|
    env["rack.session"]["counter"] ||= 0
    env["rack.session"]["counter"] += 1
    Rack::Response.new(env["rack.session"].inspect).to_a
  end
  drop_session = Rack::Lint.new(proc do |env|
    env['rack.session.options'][:drop] = true
    incrementor.call(env)
  end)
  renew_session = Rack::Lint.new(proc do |env|
    env['rack.session.options'][:renew] = true
    incrementor.call(env)
  end)
  defer_session = Rack::Lint.new(proc do |env|
    env['rack.session.options'][:defer] = true
    incrementor.call(env)
  end)
  skip_session = Rack::Lint.new(proc do |env|
    env['rack.session.options'][:skip] = true
    incrementor.call(env)
  end)
  incrementor = Rack::Lint.new(incrementor)

  let(:session_file_dir) {File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "session_files"))}
  let(:pool) {
    Rack::Session::PHP.new(incrementor, :session_file_dir => session_file_dir)
  }

  after do
    Dir.foreach(session_file_dir) do |file|
      File.delete(File.join(session_file_dir, file)) if file =~ /^sess/
    end
  end

  it "creates a new cookie" do
    res = Rack::MockRequest.new(pool).get("/")
    expect(res["Set-Cookie"]).to be_include("#{session_key}=")
    expect(res.body).to eq '{"counter"=>1}'
  end

  it "determines session from a cookie" do
    req = Rack::MockRequest.new(pool)
    res = req.get("/")
    cookie = res["Set-Cookie"]
    expect(req.get("/", "HTTP_COOKIE" => cookie).body).
      to eq '{"counter"=>2}'
    expect(req.get("/", "HTTP_COOKIE" => cookie).body).
      to eq '{"counter"=>3}'
  end

  it "determines session only from a cookie by default" do
    req = Rack::MockRequest.new(pool)
    res = req.get("/")
    sid = res["Set-Cookie"][session_match, 1]
    expect(req.get("/?rack.session=#{sid}").body).
      to eq '{"counter"=>1}'
    expect(req.get("/?rack.session=#{sid}").body).
      to eq '{"counter"=>1}'
  end

  it "determines session from params" do
    pool_with_params = Rack::Session::PHP.new(incrementor, :session_file_dir => session_file_dir, :cookie_only => false)
    req = Rack::MockRequest.new(pool_with_params)
    res = req.get("/")
    sid = res["Set-Cookie"][session_match, 1]
    expect(req.get("/?rack.session=#{sid}").body).
      to eq '{"counter"=>2}'
    expect(req.get("/?rack.session=#{sid}").body).
      to eq '{"counter"=>3}'
  end

  it "survives nonexistant cookies" do
    bad_session_id = "nekodaisuki"
    bad_cookie = "rack.session=#{bad_session_id}"
    res = Rack::MockRequest.new(pool).
      get("/", "HTTP_COOKIE" => bad_cookie)
    expect(res.body).to eq '{"counter"=>1}'
    cookie = res["Set-Cookie"][session_match]
    expect(cookie).not_to match(/#{bad_cookie}/)
  end

  it "does not send the same session id if it did not change" do
    req = Rack::MockRequest.new(pool)

    res0 = req.get("/")
    cookie = res0["Set-Cookie"][session_match]
    expect(res0.body).to eq '{"counter"=>1}'

    res1 = req.get("/", "HTTP_COOKIE" => cookie)
    expect(res1["Set-Cookie"]).to be_nil
    expect(res1.body).to eq '{"counter"=>2}'

    res2 = req.get("/", "HTTP_COOKIE" => cookie)
    expect(res2["Set-Cookie"]).to be_nil
    expect(res2.body).to eq '{"counter"=>3}'
  end

  it "deletes cookies with :drop option" do
    req = Rack::MockRequest.new(pool)
    drop = Rack::Utils::Context.new(pool, drop_session)
    dreq = Rack::MockRequest.new(drop)

    res1 = req.get("/")
    session = (cookie = res1["Set-Cookie"])[session_match]
    expect(res1.body).to eq '{"counter"=>1}'

    res2 = dreq.get("/", "HTTP_COOKIE" => cookie)
    expect(res2["Set-Cookie"]).to be_nil
    expect(res2.body).to eq '{"counter"=>2}'

    res3 = req.get("/", "HTTP_COOKIE" => cookie)
    expect(res3["Set-Cookie"][session_match]).not_to eq session
    expect(res3.body).to eq '{"counter"=>1}'
  end

  it "provides new session id with :renew option" do
    req = Rack::MockRequest.new(pool)
    renew = Rack::Utils::Context.new(pool, renew_session)
    rreq = Rack::MockRequest.new(renew)

    res1 = req.get("/")
    session = (cookie = res1["Set-Cookie"])[session_match]
    expect(res1.body).to eq '{"counter"=>1}'

    res2 = rreq.get("/", "HTTP_COOKIE" => cookie)
    new_cookie = res2["Set-Cookie"]
    new_session = new_cookie[session_match]
    expect(new_session).not_to eq session
    expect(res2.body).to eq '{"counter"=>2}'

    res3 = req.get("/", "HTTP_COOKIE" => new_cookie)
    expect(res3.body).to eq '{"counter"=>3}'

    # Old cookie was deleted
    res4 = req.get("/", "HTTP_COOKIE" => cookie)
    expect(res4.body).to eq '{"counter"=>1}'
  end

  it "omits cookie with :defer option but still updates the state" do
    count = Rack::Utils::Context.new(pool, incrementor)
    defer = Rack::Utils::Context.new(pool, defer_session)
    dreq = Rack::MockRequest.new(defer)
    creq = Rack::MockRequest.new(count)

    res0 = dreq.get("/")
    expect(res0["Set-Cookie"]).to be_nil
    expect(res0.body).to eq '{"counter"=>1}'

    res0 = creq.get("/")
    res1 = dreq.get("/", "HTTP_COOKIE" => res0["Set-Cookie"])
    expect(res1.body).to eq '{"counter"=>2}'
    res2 = dreq.get("/", "HTTP_COOKIE" => res0["Set-Cookie"])
    expect(res2.body).to eq '{"counter"=>3}'
  end

  it "omits cookie and state update with :skip option" do
    count = Rack::Utils::Context.new(pool, incrementor)
    skip = Rack::Utils::Context.new(pool, skip_session)
    sreq = Rack::MockRequest.new(skip)
    creq = Rack::MockRequest.new(count)

    res0 = sreq.get("/")
    expect(res0["Set-Cookie"]).to be_nil
    expect(res0.body).to eq '{"counter"=>1}'

    res0 = creq.get("/")
    res1 = sreq.get("/", "HTTP_COOKIE" => res0["Set-Cookie"])
    expect(res1.body).to eq '{"counter"=>2}'
    res2 = sreq.get("/", "HTTP_COOKIE" => res0["Set-Cookie"])
    expect(res2.body).to eq '{"counter"=>2}'
  end

  it "can handle multibyte strings" do
    multibyte_app = lambda{|env|
      env['rack.session']['key'] = 'テスト'
      [200, {}, 'session stored']
    }
    pool = Rack::Session::PHP.new(multibyte_app, {
      :session_file_dir => session_file_dir,

      :internal_encoding => "UTF-8",
      :external_encoding => "EUC-JP",
    })

    req = Rack::MockRequest.new(pool)
    res = req.get("/")
    session_id = session_match.match(res["Set-Cookie"])[1]

    file_name = File.join(session_file_dir, "sess_#{session_id}")

    # read as byte sequence
    byteseq = IO.read(file_name, File.size(file_name))
    expect(byteseq.force_encoding('EUC-JP')).to eq('key|s:6:"テスト";'.encode('EUC-JP'))
  end
end
