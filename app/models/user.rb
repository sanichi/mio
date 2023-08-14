class User < ApplicationRecord
  attr_accessor :password

  ROLES = ["admin", "family", "chess", "isle", "none"]
  MAX_EMAIL = 75
  MAX_FN = 25
  MAX_PASSWORD = 32
  MAX_ROLE = 20
  MAX_LN = 25
  OTP_ISSUER = "mio.sanichi.me"
  OTP_TEST_SECRET = "YAJY2UMNXQE4JFTWH4AFZGBE7YOQX3XY"

  before_validation :update_password_if_present
  after_validation :copy_password_error
  after_update :reset_otp

  validates :email, format: { with: /\A[^\s@]+@[^\s@]+\z/ }, length: { maximum: MAX_EMAIL }, uniqueness: true
  validates :encrypted_password, presence: true, length: { is: MAX_PASSWORD }
  validates :role, inclusion: { in: ROLES }
  validates :first_name, presence: true, length: { maximum: MAX_FN }
  validates :last_name, presence: true, length: { maximum: MAX_LN }

  ROLES.each do |role|
    define_method "#{role}?" do
      self.role == role
    end
  end

  def name       = "#{first_name} #{last_name}"
  def initials   = "#{first_name[0]}#{last_name[0]}"
  def guest?     = role == "guest"
  def self.guest = new(role: "guest")

  private

  def update_password_if_present
    self.encrypted_password = Digest::MD5.hexdigest(password) if password.present?
  end

  def copy_password_error
    errors.add(:password, errors[:encrypted_password].first) if errors[:encrypted_password].any?
  end

  def reset_otp
    if !otp_required
      update_columns(otp_secret: nil, last_otp_at: nil)
    end
  end
end
