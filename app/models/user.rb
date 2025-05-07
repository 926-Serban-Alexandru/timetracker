class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  before_create :randomize_id
  has_many :time_entries, dependent: :destroy
  validates :name, presence: true

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
