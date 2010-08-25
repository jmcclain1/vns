require 'digest/sha1'
class User < ActiveRecord::Base
  include DefaultUserValidations unless Object.const_defined?(:DISABLE_DEFAULT_USER_VALIDATIONS)

  has_one :profile
  has_many :logins
  has_many :user_validation_tokens
  has_many :password_reset_tokens, :conditions => {:used => false}

  delegate :first_name=, :to => :profile
  delegate :last_name=, :to => :profile

  attr_accessor :password, :current_password
  attr_accessible :unique_name,
                  :email_address,
                  :accept_terms_of_service,
                  :password,
                  :password_confirmation,
                  :current_password,
                  :first_name,
                  :last_name

  before_save :increment_tos
  before_create :build_user_validation_token

  def build_user_validation_token
    user_validation_tokens.build
  end

  def self.authenticate(options)
    options = options.clone
    email_address = options.delete(:email_address)
    password = options.delete(:password)

    user = find_by_email_address(email_address) ||
      find_by_unique_name(email_address)
    if user and user.authenticate?(password)
      user.attributes = options
      user.save
      user
    end
  end

  def self.find_by_param(unique_name)
    find_by_unique_name(unique_name)
  end

  def initialize(attributes={})
    super()
    build_profile
    self.attributes = attributes
  end

  def to_param
    unique_name
  end

  def to_s
    unique_name
  end

  def authenticate?(password)
    encrypted_password == self.class.encrypt(password, salt)
  end

  def self.encrypt(text, salt)
    raise "You need a salt" if salt.nil?
    Digest::SHA1::hexdigest("#{salt}--#{text}--")
  end

  def password=(new_password)
    self.salt = new_salt if new_record?
    @password = new_password
    self.encrypted_password = self.class.encrypt(new_password, salt)
  end

  def increment_tos
    if needs_to_accept_tos?
      self.terms_of_service_id = TermsOfService.latest.id
    end
  end

  def needs_to_accept_tos?
    self.terms_of_service_id != TermsOfService.latest.id
  end

  def new_salt
    Guid.new.to_s
  end

  def password_reset_timeout
    24.hours
  end

  def login!
    self.logins.create
  end

  def last_login
    activity = self.logins.find(:first, :order => "created_at DESC")
    activity.nil? ? nil : activity.created_at
  end

  def unverify_account
    self.account_validated = false
    true
  end

  def unverify_account!
    unverify_account
    save!
  end

  def verify_account!
    self.account_validated = true
    save!
  end

  def display_name
    warn 'display_name is deprecated; use to_s'
    self.to_s
  end


  def full_name
    names = [first_name, last_name].reject { |i| i.blank? }
    names.empty?? unique_name : names.join(' ')
  end

  def first_name
    self.profile.first_name
  end

  def last_name
    self.profile.last_name
  end

  def updatable_by?(acting_user)
    self == acting_user || acting_user.super_admin?
  end

  def destroyable_by?(acting_user)
    updatable_by?(acting_user)
  end

  def can_create?(object)
    object.creatable_by?(self)
  end

  def can_read?(object)
    object.readable_by?(self)
  end

  def can_update?(object)
    object.updatable_by?(self)
  end

  def can_destroy?(object)
    object.destroyable_by?(self)
  end

  def creatable_by?(user)
    true
  end

end

