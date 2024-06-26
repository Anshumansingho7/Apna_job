class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  enum role: [:job_seeker, :job_recruiter]
  validates :role, presence: true
  validates :role, inclusion: { in: roles.keys }

  devise :database_authenticatable, :registerable,
         :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_one :job_recruiter, dependent: :destroy
  has_one :job_seeker, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :notifications, dependent: :destroy

  def update_password_without_current(params)
    update(params)
  end

  def jwt_payload
    super
  end
  
end