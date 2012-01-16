class ApplicationRedirectUri < ActiveRecord::Base

  self.table_name = :oauth_application_redirect_uris

  belongs_to :application

  validates :redirect_uri, :presence => true
  validate :validate_redirect_uri

  def validate_redirect_uri
    return unless redirect_uri
    uri = URI.parse(redirect_uri)
    errors.add(:redirect_uri, "cannot contain a fragment.") unless uri.fragment.nil?
    errors.add(:redirect_uri, "must be an absolute URL.") if uri.scheme.nil? || uri.host.nil?
    errors.add(:redirect_uri, "cannot contain a query parameter.") unless uri.query.nil?
  rescue URI::InvalidURIError => e
    errors.add(:redirect_uri, "must be a valid URI.")
  end

  def is_matching_redirect_uri?(uri_string)
    uri = URI.parse(uri_string)
    uri.query = nil
    uri.to_s == redirect_uri
  end

end