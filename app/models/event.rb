class Event < ApplicationRecord
  validates :billetto_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :starts_at, presence: true
  validate :ends_after_start, if: -> { starts_at.present? && ends_at.present? }

  scope :upcoming, -> { where("starts_at > ?", Time.current).order(:starts_at) }
  scope :past, -> { where("starts_at <= ?", Time.current).order(starts_at: :desc) }

  private

  def ends_after_start
    errors.add(:ends_at, "must be after start time") if ends_at <= starts_at
  end
end
