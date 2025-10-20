class User < ApplicationRecord
  ROLES = ["admin", "family", "chess", "isle", "none"]
  MAX_EMAIL = 75
  MAX_FN = 25
  MAX_ROLE = 20
  MAX_LN = 25
  OTP_ISSUER = "mio.sanichi.me"

  has_secure_password

  after_update :reset_otp

  validates :email, format: { with: /\A[^\s@]+@[^\s@]+\z/ }, length: { maximum: MAX_EMAIL }, uniqueness: true
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

  def reset_otp
    if !otp_required
      update_columns(otp_secret: nil, last_otp_at: nil)
    end
  end
end
