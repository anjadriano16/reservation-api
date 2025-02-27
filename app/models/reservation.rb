class Reservation < ApplicationRecord
  belongs_to :guest
  
  validates :start_date, :end_date, :nights, :status, presence: true
  validates :adults, :children, :infants, numericality: { greater_than_or_equal_to: 0 }
  validates :payout_price, :security_price, :total_price, numericality: true
  
  # Store the original guest_id from the payload for reference
  attribute :guest_id_from_payload
end
