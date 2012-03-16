class Doorkeeper::AuthorizationsController < Doorkeeper::ApplicationController
  before_filter :authenticate_resource_owner!

  def new
    if authorization.valid?
      if authorization.access_token_exists?
        authorization.authorize
        redirect_to authorization.success_redirect_uri
      else
        render_approve_scopes_view
      end
    elsif authorization.redirect_on_error?
      redirect_to authorization.invalid_redirect_uri
    else
      render_error_view
    end
  end

  def create
    if authorization.authorize
      redirect_to authorization.success_redirect_uri
    elsif authorization.redirect_on_error?
      redirect_to authorization.invalid_redirect_uri
    else
      render_error_view
    end
  end

  def destroy
    authorization.deny
    redirect_to authorization.invalid_redirect_uri
  end

  def render_approve_scopes_view
    render 'new'
  end

  def render_error_view
    render 'error'
  end

  private

  def authorization
    authorization_params = params.has_key?(:authorization) ? params[:authorization] : params
    @authorization ||= Doorkeeper::OAuth::AuthorizationRequest.new(current_resource_owner, authorization_params)
  end

end
