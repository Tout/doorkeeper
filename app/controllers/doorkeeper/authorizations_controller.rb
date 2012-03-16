class Doorkeeper::AuthorizationsController < Doorkeeper::ApplicationController
  before_filter :authenticate_resource_owner!

  def new
    if authorization.valid?
      if authorization.access_token_exists?
        authorization.authorize
        redirect_to authorization.success_redirect_uri and return
      end
    elsif authorization.redirect_on_error?
      redirect_to authorization.invalid_redirect_uri and return
    else
      render_view_for_display :error and return
    end
    render_view_for_display :new and return
  end

  def create
    if authorization.authorize
      redirect_to authorization.success_redirect_uri
    elsif authorization.redirect_on_error?
      redirect_to authorization.invalid_redirect_uri
    else
      render_view_for_display :error
    end
  end

  def destroy
    authorization.deny
    redirect_to authorization.invalid_redirect_uri
  end

  private
  def render_view_for_display(view)
    render view.to_s
  end

  def authorization
    @authorization ||= Doorkeeper::OAuth::AuthorizationRequest.new(current_resource_owner, params)
  end
end
