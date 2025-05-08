class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  before_create :randomize_id
  has_many :time_entries, dependent: :destroy
  validates :name, presence: true
  before_create :generate_authentication_token

  def generate_authentication_token
    loop do
      self.authentication_token = SecureRandom.base64(32)
      break unless User.exists?(authentication_token: authentication_token)
    end
  end

  def invalidate_token
    update(authentication_token: nil)
  end

  def self.valid_token?(token)
    User.exists?(authentication_token: token)
  end


  private
  def randomize_id
    begin
      self.id = SecureRandom.random_number(1_000_000_000)
    end while User.where(id: self.id).exists?
  end

  enum role: [ :user, :manager, :admin ]
  after_initialize :set_default_role, if: :new_record?
  def set_default_role
  self.role ||= :user
  end
end
