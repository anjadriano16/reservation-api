class Guest < ApplicationRecord
  has_many :reservations, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
end
