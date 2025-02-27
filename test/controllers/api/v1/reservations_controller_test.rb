require "test_helper"

class Api::V1::ReservationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payload_type_1 = {
      "start_date": "2021-03-12",
      "end_date": "2021-03-16",
      "nights": 4,
      "guests": 4,
      "adults": 2,
      "children": 2,
      "infants": 0,
      "status": "accepted",
      "guest": {
        "id": 1,
        "first_name": "Wayne",
        "last_name": "Woodbridge",
        "phone": "639123456789",
        "email": "wayne_woodbridge@bnb.com"
      },
      "currency": "AUD",
      "payout_price": "3800.00",
      "security_price": "500",
      "total_price": "4500.00"
    }
    
    @payload_type_2 = {
      "reservation": {
        "start_date": "2021-03-12",
        "end_date": "2021-03-16",
        "expected_payout_amount": "3800.00",
        "guest_details": {
          "localized_description": "4 guests",
          "number_of_adults": 2,
          "number_of_children": 2,
          "number_of_infants": 0
        },
        "guest_email": "wayne_woodbridge@bnb.com",
        "guest_first_name": "Wayne",
        "guest_last_name": "Woodbridge",
        "guest_phone_numbers": [
          "639123456789",
          "639123456789"
        ],
        "listing_security_price_accurate": "500.00",
        "host_currency": "AUD",
        "nights": 4,
        "number_of_guests": 4,
        "status_type": "accepted",
        "total_paid_amount_accurate": "4500.00"
      }
    }
  end
  
  test "should create reservation with payload type 1" do
    puts "Sending request with payload type 1..."
    assert_difference('Reservation.count') do
      post api_v1_reservations_path, params: @payload_type_1.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    end

    puts "Response status: #{response.status}"
    puts "Response body: #{response.body}"
    
    assert_response :created
    assert_equal 'wayne_woodbridge@bnb.com', Guest.last.email
  end
  
  test "should create reservation with payload type 2" do
    puts "Sending request with payload type 2..."
    assert_difference('Reservation.count') do
      post api_v1_reservations_path, params: @payload_type_2.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    end

    puts "Response status: #{response.status}"
    puts "Response body: #{response.body}"
    
    assert_response :created
    assert_equal 'wayne_woodbridge@bnb.com', Guest.last.email
  end
  
  test "should not create duplicate guest when email is the same" do
    puts "Creating first reservation..."
    # Create first reservation
    post api_v1_reservations_path, params: @payload_type_1.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    
    puts "Creating second reservation with the same email..."
    # Create second reservation with different payload type but same guest email
    assert_no_difference('Guest.count') do
      post api_v1_reservations_path, params: @payload_type_2.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    end

    puts "Total guests: #{Guest.count}"
    puts "Total reservations: #{Reservation.count}"
    
    assert_response :created
    assert_equal 2, Reservation.count
    assert_equal 1, Guest.count
  end
  
  test "should return error for invalid json" do
    puts "Sending invalid JSON request..."
    post api_v1_reservations_path, params: "invalid json", headers: { 'CONTENT_TYPE' => 'application/json' }

    puts "Response status: #{response.status}"
    puts "Response body: #{response.body}"
    assert_response :bad_request
  end
end
