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
    ActiveRecord::Base.transaction { process_reservation }
  rescue ActiveRecord::RecordInvalid => e
    raise ReservationError, "Failed to save: #{e.message}"
  end

  private

  def validate_data!
    missing_fields = missing_required_fields
    raise ReservationError, "Missing required fields: #{missing_fields.join(', ')}" unless missing_fields.empty?
  end

  def missing_required_fields
    REQUIRED_RESERVATION_FIELDS.select { |field| @reservation_data[field].blank? } +
      REQUIRED_GUEST_FIELDS.select { |field| @guest_data[field].blank? }
  end

  def process_reservation
    guest = find_or_create_guest
    reservation_data = @reservation_data.merge(guest_id: guest.id).except(:guest_id_from_payload)
    guest.reservations.create!(reservation_data)
  end

  def find_or_create_guest
    guest = Guest.find_or_initialize_by(email: @guest_data[:email])
    guest.assign_attributes(@guest_data)
    guest.save!
    guest
  end
end
