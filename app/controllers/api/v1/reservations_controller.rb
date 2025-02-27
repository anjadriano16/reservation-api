class Api::V1::ReservationsController < ApplicationController
  # Skip CSRF protection since this is an API
  # skip_before_action :verify_authenticity_token, if: -> { controller_name == 'reservations' }
      
  def create
    # Parse the incoming payload
    parsed_data = PayloadParserService.new(reservation_params).parse
    return render_error('Invalid JSON format', :bad_request) if parsed_data.nil?
    
    # Create or update the reservation
    reservation = ReservationCreationService.new(parsed_data).create_or_update
    
    # Return success response
    render json: { 
      status: 'success', 
      message: 'Reservation created successfully', 
      data: reservation 
    }, status: :created
  rescue JSON::ParserError
    render_error('Invalid JSON format', :bad_request)
  rescue ReservationError => e
    render_error(e.message, :unprocessable_entity)
  rescue StandardError => e
    # Log the error for debugging
    Rails.logger.error "Reservation creation error: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error('An unexpected error occurred', :internal_server_error)
  end
  
  private
  
  def reservation_params
    # Parse JSON from request body
    JSON.parse(request.body.read)
  end
  
  def render_error(message, status)
    render json: { status: 'error', message: message }, status: status
  end
end
