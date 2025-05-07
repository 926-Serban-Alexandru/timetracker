class TimeEntry < ApplicationRecord
  belongs_to :user
  validates :date, :distance, :duration, presence: true
  validates :distance, numericality: { greater_than: 0 }
  validates :duration, numericality: { greater_than: 0 }
  before_create :randomize_id

  def average_speed
    distance / duration.to_f 
  end

  def self.weekly_stats(user)
    select(
      "date(date, 'weekday 1', '-7 days') as week_start",  # Group by Monday
      "SUM(distance) as total_distance",
      "SUM(distance) * 1.0 / NULLIF(SUM(duration), 0) as avg_speed"
    )
    .where(user_id: user.id)
    .group("week_start")
    .order("week_start ASC")
  end
  
  private

  def randomize_id
    begin
      self.id = SecureRandom.random_number(1_000_000_000)
    end while TimeEntry.where(id: self.id).exists?
  end
  
end
