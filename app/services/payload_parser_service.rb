class PayloadParserService
  def initialize(payload)
      @payload = payload
  end

  def parse
    # Determine the payload type and delegate to the appropriate parser
    if @payload.key?('reservation')
    parse_payload_type_2
    else
    parse_payload_type_1
    end
  rescue JSON::ParserError
    raise ReservationError, 'Invalid JSON format'
  end

  private

  def parse_payload_type_1
      {
      reservation_data: {
          start_date: @payload['start_date'],
          end_date: @payload['end_date'],
          nights: @payload['nights'],
          adults: @payload['adults'],
          children: @payload['children'],
          infants: @payload['infants'],
          status: @payload['status'],
          currency: @payload['currency'],
          payout_price: @payload['payout_price'],
          security_price: @payload['security_price'],
          total_price: @payload['total_price'],
          guest_id_from_payload: @payload['guest']['id']
      },
      guest_data: {
          email: @payload['guest']['email'],
          first_name: @payload['guest']['first_name'],
          last_name: @payload['guest']['last_name'],
          phone: @payload['guest']['phone']
      }
      }
  end

  def parse_payload_type_2
      reservation = @payload['reservation']
      guest_details = reservation['guest_details']
      
      {
      reservation_data: {
          start_date: reservation['start_date'],
          end_date: reservation['end_date'],
          nights: reservation['nights'],
          adults: guest_details['number_of_adults'],
          children: guest_details['number_of_children'],
          infants: guest_details['number_of_infants'],
          status: map_status(reservation['status_type']),
          currency: reservation['host_currency'],
          payout_price: reservation['expected_payout_amount'],
          security_price: reservation['listing_security_price_accurate'],
          total_price: reservation['total_paid_amount_accurate'],
          guest_id_from_payload: reservation['guest_id']
      },
      guest_data: {
          email: reservation['guest_email'],
          first_name: reservation['guest_first_name'],
          last_name: reservation['guest_last_name'],
          phone: extract_phone(reservation['guest_phone_numbers'])
      }
      }
  end

  def extract_phone(phone_numbers)
      return nil if phone_numbers.blank?
      phone_numbers.first
  end

  def map_status(status_type)
      # Status mappings can be expanded as needed
      status_type
  end
end