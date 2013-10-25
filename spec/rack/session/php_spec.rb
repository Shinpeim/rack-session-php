require "spec_helper"
describe Rack::Session::PHP do
  it "shlould be loaded" do
    expect(Rack::Session::PHP).not_to be_nil
  end
end
