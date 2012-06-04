require 'spec_helper_integration'

feature 'Authorization Code Flow for Skip Scope Screen' do
  background do
    config_is_set(:authenticate_resource_owner) { User.first || redirect_to('/sign_in') }
    client_exists
    @client.uid = "33489b65a8be52f1853c306bc61a58bd18882eba8b18e1195024708302f22ccb"
    @client.save!
    create_resource_owner
    sign_in
  end

  scenario 'resource owner authorizes the client' do
    visit authorization_endpoint_url(:client => @client)

    access_grant_should_exist_for(@client, @resource_owner)

    i_should_be_on_client_callback(@client)

    url_should_have_param("code", Doorkeeper::AccessGrant.first.token)
    url_should_not_have_param("state")
    url_should_not_have_param("error")
  end

  scenario 'resource owner authorizes the client with state parameter set' do
    visit authorization_endpoint_url(:client => @client, :state => "return-me")
    url_should_have_param("code", Doorkeeper::AccessGrant.first.token)
    url_should_have_param("state", "return-me")
  end

  scenario 'returns the same token if it is still accessible' do
    client_is_authorized(@client, @resource_owner)
    visit authorization_endpoint_url(:client => @client)

    authorization_code = Doorkeeper::AccessGrant.first.token
    post token_endpoint_url(:code => authorization_code, :client => @client)

    Doorkeeper::AccessToken.count.should be(1)

    should_have_json 'access_token', Doorkeeper::AccessToken.first.token
  end

  scenario 'revokes and return new token if it is has expired' do
    client_is_authorized(@client, @resource_owner)
    token = Doorkeeper::AccessToken.first
    token.update_attribute :expires_in, -100
    visit authorization_endpoint_url(:client => @client)

    authorization_code = Doorkeeper::AccessGrant.first.token
    post token_endpoint_url(:code => authorization_code, :client => @client)

    token.reload.should be_revoked
    Doorkeeper::AccessToken.count.should be(2)

    should_have_json 'access_token', Doorkeeper::AccessToken.last.token
  end

  scenario 'resource owner requests an access token with authorization code' do
    visit authorization_endpoint_url(:client => @client)

    authorization_code = Doorkeeper::AccessGrant.first.token
    post token_endpoint_url(:code => authorization_code, :client => @client)

    access_token_should_exist_for(@client, @resource_owner)

    should_not_have_json 'error'

    should_have_json 'access_token', Doorkeeper::AccessToken.first.token
    should_have_json 'token_type',   "bearer"
    should_have_json 'expires_in',   Doorkeeper::AccessToken.first.expires_in

    should_not_have_json 'refresh_token'
  end

  context 'with scopes' do
    background do
      scope_exists :public, :default => true, :description => "Access your public data"
      scope_exists :write,  :description => "Update your data"
    end

    scenario 'resource owner authorizes the client with default scopes' do
      visit authorization_endpoint_url(:client => @client)
      access_grant_should_exist_for(@client, @resource_owner)
      access_grant_should_have_scopes :public
    end

    scenario 'resource owner authorizes the client with required scopes' do
      visit authorization_endpoint_url(:client => @client, :scope => "public write")
      access_grant_should_have_scopes :public, :write
    end

    scenario 'new access token matches required scopes' do
      visit authorization_endpoint_url(:client => @client, :scope => "public write")

      authorization_code = Doorkeeper::AccessGrant.first.token
      post token_endpoint_url(:code => authorization_code, :client => @client)

      access_token_should_exist_for(@client, @resource_owner)
      access_token_should_have_scopes :public, :write
    end

    scenario 'returns new token if scopes have changed' do
      client_is_authorized(@client, @resource_owner, :scopes => "public write")
      visit authorization_endpoint_url(:client => @client, :scope => "public")

      authorization_code = Doorkeeper::AccessGrant.first.token
      post token_endpoint_url(:code => authorization_code, :client => @client)

      Doorkeeper::AccessToken.count.should be(2)

      should_have_json 'access_token', Doorkeeper::AccessToken.last.token
    end
  end
end

feature 'Implicit Grant Flow for Skip Scope Screen' do
  background do
    config_is_set(:authenticate_resource_owner) { User.first || redirect_to('/sign_in') }
    client_exists
    @client.uid = "33489b65a8be52f1853c306bc61a58bd18882eba8b18e1195024708302f22ccb"
    @client.save!
    create_resource_owner
    sign_in
  end

  scenario 'resource owner authorizes the client' do
    visit authorization_endpoint_url(:client => @client, :response_type => 'token')

    access_token_should_exist_for @client, @resource_owner

    i_should_be_on_client_callback @client
  end
end

