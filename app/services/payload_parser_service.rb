class PayloadParserService
  def initialize(payload)
    @payload = payload
  end

  # Public method to parse the payload based on its structure
  def parse
    return parse_payload_type_2 if @payload.key?('reservation')
    parse_payload_type_1
  rescue JSON::ParserError
    raise ReservationError, 'Invalid JSON format'
  end

  private

  # Parses payload type 1 structure
  def parse_payload_type_1
    {
      reservation_data: extract_reservation_data(@payload, type: :type_1),
      guest_data: extract_guest_data(@payload['guest'])
    }
  end

  # Parses payload type 2 structure
  def parse_payload_type_2
    reservation = @payload['reservation']
    guest_details = reservation['guest_details']
    
    {
    reservation_data: extract_reservation_data(reservation, guest_details: guest_details, type: :type_2),
    guest_data: extract_guest_data(reservation, type: :type_2)
    }
  end

  # Extracts reservation data for both payload types
  def extract_reservation_data(data, guest_details: nil, type: :type_1)
    {
      start_date: data['start_date'],
      end_date: data['end_date'],
      nights: data['nights'],
      adults: type == :type_1 ? data['adults'] : guest_details['number_of_adults'],
      children: type == :type_1 ? data['children'] : guest_details['number_of_children'],
      infants: type == :type_1 ? data['infants'] : guest_details['number_of_infants'],
      status: type == :type_1 ? data['status'] : map_status(data['status_type']),
      currency: type == :type_1 ? data['currency'] : data['host_currency'],
      payout_price: type == :type_1 ? data['payout_price'] : data['expected_payout_amount'],
      security_price: type == :type_1 ? data['security_price'] : data['listing_security_price_accurate'],
      total_price: type == :type_1 ? data['total_price'] : data['total_paid_amount_accurate'],
      guest_id_from_payload: type == :type_1 ? data.dig('guest', 'id') : data['guest_id']
    }
  end

  # Extracts guest data for both payload types
  def extract_guest_data(data, type: :type_1)
    {
      email: type == :type_1 ? data['email'] : data['guest_email'],
      first_name: type == :type_1 ? data['first_name'] : data['guest_first_name'],
      last_name: type == :type_1 ? data['last_name'] : data['guest_last_name'],
      phone: type == :type_1 ? data['phone'] : extract_phone(data['guest_phone_numbers'])
    }
  end

  # Extracts phone number, returns the first if multiple exist
  def extract_phone(phone_numbers)
      phone_numbers&.first
  end

  # Maps status type for consistency
  def map_status(status_type)
      # Status mappings can be expanded as needed
      status_type
  end
end