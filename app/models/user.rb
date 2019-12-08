class User < ApplicationRecord
  include Pageable

  attr_accessor :password

  belongs_to :person

  ROLES = ["admin", "none", "family"]
  MAX_EMAIL = 75
  MAX_PASSWORD = 32
  MAX_ROLE = 20

  before_validation :update_password_if_present, :clean_person_id
  after_validation :copy_password_error

  validates :email, format: { with: /\A[^\s@]+@[^\s@]+\z/ }, length: { maximum: MAX_EMAIL }, uniqueness: true
  validates :encrypted_password, presence: true, length: { is: MAX_PASSWORD }
  validates :person_id, numericality: { integer_only: true, greater_than: 0 }, allow_nil: true
  validates :role, inclusion: { in: ROLES }

  ROLES.each do |role|
    define_method "#{role}?" do
      self.role == role
    end
  end

  def guest?
    !id
  end

  class << self
    def search(params, path, opt={})
      matches = left_joins(:person).includes(:person).order(:email)
      matches = matches.where("email ILIKE ?", "%#{params[:email]}%") if params[:email].present?
      matches = matches.where("people.last_name ILIKE ?", "%#{params[:last_name]}%") if params[:last_name].present?
      if params[:first_names].present?
        pattern = "%#{params[:first_names]}%"
        matches = matches.where("first_names ILIKE ? OR known_as ILIKE ?", pattern, pattern)
      end
      paginate(matches, params, path, opt)
    end

    def guest
      new(role: "none")
    end
  end

  private

  def update_password_if_present
    self.encrypted_password = Digest::MD5.hexdigest(password) if password.present?
  end

  def clean_person_id
    self.person_id = nil if person_id.to_i == 0
  end

  def copy_password_error
    errors.add(:password, errors[:encrypted_password].first) if errors[:encrypted_password].any?
  end
end
