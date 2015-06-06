class User < ActiveRecord::Base
  include Pageable

  attr_accessor :password

  ROLES = ["admin", "arborist", "none"]

  before_validation :update_password_if_present
  after_validation :copy_password_error

  validates :email, presence: true, length: { maximum: 75 }, uniqueness: true
  validates :encrypted_password, presence: true, length: { is: 32 }
  validates :role, inclusion: { in: ROLES }

  def self.search(params, path, opt={})
    matches = User.order(:email)
    matches = matches.where("email ILIKE ?", "%#{params[:email]}%") if params[:email].present?
    paginate(matches, params, path, opt)
  end

  ROLES.each do |role|
    define_method "#{role}?" do
      self.role == role
    end
  end

  private

  def update_password_if_present
    self.encrypted_password = Digest::MD5.hexdigest(password) if password.present?
  end
  
  def copy_password_error
    errors.add(:password, errors[:encrypted_password].first) if errors[:encrypted_password].any?
  end
end
