require 'spec_helper'

describe 'Application' do
  let(:new_application) { Factory(:application) }
  let(:new_application_redirect_uri) { new_application.application_redirect_uris.first }

  it 'is invalid without redirect_uri' do
    new_application_redirect_uri.redirect_uri = nil
    new_application_redirect_uri.should_not be_valid
  end

  it 'is invalid with a redirect_uri that is relative' do
    new_application_redirect_uri.redirect_uri = "/abcd"
    new_application_redirect_uri.should_not be_valid
  end

  it 'is invalid with a redirect_uri that has a fragment' do
    new_application_redirect_uri.redirect_uri = "http://example.com/abcd#xyz"
    new_application_redirect_uri.should_not be_valid
  end

  it 'is invalid with a redirect_uri that has a query parameter' do
    new_application_redirect_uri.redirect_uri = "http://example.com/abcd?xyz=123"
    new_application_redirect_uri.should_not be_valid
  end

  describe ".is_matching_redirect_uri?" do
    subject { new_application_redirect_uri }

    it "returns true when the URIs match" do
      subject.is_matching_redirect_uri?(subject.redirect_uri).should be_true
    end

    it "returns false when the protocols don't match" do
      uri = URI.parse(subject.redirect_uri)
      uri.scheme = "http"
      subject.is_matching_redirect_uri?(uri.to_s).should be_false
    end

    it "returns false when the hosts don't match" do
      uri = URI.parse(subject.redirect_uri)
      uri.host = "something-else.com"
      subject.is_matching_redirect_uri?(uri.to_s).should be_false
    end

    it "returns false when the paths don't match" do
      uri = URI.parse(subject.redirect_uri)
      uri.path = "/something-else"
      subject.is_matching_redirect_uri?(uri.to_s).should be_false
    end

    it "ignores query parameters when comparing redirect URIs" do
      uri = URI.parse(subject.redirect_uri)
      uri.query = "abc=123&def=456"
      subject.is_matching_redirect_uri?(uri.to_s).should be_true
    end
  end

end