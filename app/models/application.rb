class Application < ActiveRecord::Base
  include Doorkeeper::OAuth::RandomString

  self.table_name = :oauth_applications

  has_many :access_grants, :dependent => :destroy
  has_many :access_tokens, :dependent => :destroy
  has_many :application_redirect_uris, :validate => true, :dependent => :destroy

  has_many :authorized_tokens, :class_name => "AccessToken", :conditions => { :revoked_at => nil }
  has_many :authorized_applications, :through => :authorized_tokens, :source => :application

  accepts_nested_attributes_for :application_redirect_uris,
      :allow_destroy => true,
      :reject_if     => :all_blank

  validates :name, :secret, :presence => true
  validates :uid, :presence => true, :uniqueness => true
  validate :validate_redirect_uri

  before_validation :generate_uid, :generate_secret, :on => :create

  def self.authorized_for(resource_owner)
    joins(:authorized_applications).where(:oauth_access_tokens => { :resource_owner_id => resource_owner.id })
  end

  def validate_redirect_uri
    return unless self.public?
    application_redirect_uris.size > 0
  end

  def requires_redirect_uri_in_request?
    public? || application_redirect_uris.size != 1
  end

  def has_registered_redirect_uris?
    !application_redirect_uris.empty?
  end

  def is_matching_redirect_uri?(uri_string)
    match_found = false
    application_redirect_uris.each do |redirect_uri|
      match_found ||= redirect_uri.is_matching_redirect_uri?(uri_string)
    end
    match_found
  end

  def default_redirect_uri
    return nil unless has_registered_redirect_uris?
    application_redirect_uris.first.redirect_uri
  end

  private
  def generate_uid
    self.uid = unique_random_string_for(:uid)
  end

  def generate_secret
    self.secret = random_string
  end
end
