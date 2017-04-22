class Personnel < ApplicationRecord
  attr_accessor :remember_token

  before_save :downcase_email

  has_many :advisors
  has_many :students, :through => :advisors

  has_many :sections
  has_many :courses, :through => :sections

  belongs_to :workin, class_name: 'Department', foreign_key: 'workin_department_id'
  belongs_to :manage, class_name: 'Department', foreign_key: 'manage_department_id'

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


  class << self
    # returns the hash digest of the given string.
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # remembers a personnel in the database for use in persistent sessions.
  def remember
    self.remember_token = personnel.new_token
    update_attribute(:remember_digest, Personnel.digest(remember_token))
  end

  # returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # forgets a personnel.
  def forget
    update_attribute(:remember_digest, nil)
  end

  private
    # converts email to all lower-case
    def downcase_email
      self.email = email.downcase
    end

end
