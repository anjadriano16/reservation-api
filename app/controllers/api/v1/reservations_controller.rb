class Api::V1::ReservationsController < ApplicationController
  before_action :parse_request_body, only: [:create]

  def create
    parsed_data = PayloadParserService.new(@reservation_payload).parse
    return render_error('Invalid JSON format', :bad_request) unless parsed_data

    reservation = ReservationCreationService.new(parsed_data).create_or_update
    render_success('Reservation created successfully', reservation, :created)
  rescue ReservationError => e
    render_error(e.message, :unprocessable_entity)
  rescue StandardError => e
    Rails.logger.error "Reservation creation error: #{e.message}\n#{e.backtrace.join("\n")}"
    render_error('An unexpected error occurred', :internal_server_error)
  end

  private

  # Parses the JSON request body before action
  def parse_request_body
    @reservation_payload = JSON.parse(request.body.read)
  rescue JSON::ParserError
    render_error('Invalid JSON format', :bad_request)
  end

  # Standardized success response
  def render_success(message, data, status)
    render json: { status: 'success', message: message, data: data }, status: status
  end

  # Standardized error response
  def render_error(message, status)
    render json: { status: 'error', message: message }, status: status
  end
end
