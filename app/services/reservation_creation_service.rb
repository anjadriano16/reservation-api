require_relative "../errors/reservation_error"

class ReservationCreationService
  REQUIRED_RESERVATION_FIELDS = %i[start_date end_date nights status currency payout_price total_price].freeze
  REQUIRED_GUEST_FIELDS = %i[email first_name last_name].freeze

  def initialize(parsed_data)
    @reservation_data = parsed_data[:reservation_data]
    @guest_data = parsed_data[:guest_data]
  end
  
  def create_or_update
    validate_data!

    ActiveRecord::Base.transaction do
      # Find or initialize guest by email
      guest = Guest.find_or_initialize_by(email: @guest_data[:email])
      guest.assign_attributes(@guest_data)
      guest.save! # Ensure guest is persisted before creating reservation
      
      # Ensure the reservation data has the correct guest_id
      reservation_data = @reservation_data.dup
      reservation_data[:guest_id] = guest.id # Explicitly set guest_id
      reservation_data.delete(:guest_id_from_payload) # Remove any potential conflicts
      
      # Create the reservation
      guest.reservations.create!(reservation_data)
    end
  rescue ActiveRecord::RecordInvalid => e
    raise ReservationError, "Failed to save: #{e.message}"
  end

  private

  def validate_data!
    missing_reservation_fields = REQUIRED_RESERVATION_FIELDS.select { |field| @reservation_data[field].blank? }
    missing_guest_fields = REQUIRED_GUEST_FIELDS.select { |field| @guest_data[field].blank? }

    unless missing_reservation_fields.empty? && missing_guest_fields.empty?
      raise ReservationError, "Missing required fields: #{(missing_reservation_fields + missing_guest_fields).join(', ')}"
    end
  end
end