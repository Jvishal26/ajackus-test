class VoteCount < ApplicationRecord
  validates :billetto_event_id, presence: true, uniqueness: true
  validates :upvotes, :downvotes, numericality: { greater_than_or_equal_to: 0 }
end
