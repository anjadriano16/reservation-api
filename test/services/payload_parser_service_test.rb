require 'test_helper'

class PayloadParserServiceTest < ActiveSupport::TestCase
  setup do
    @payload_type_1 = {
      "start_date" => "2021-03-12",
      "end_date" => "2021-03-16",
      "nights" => 4,
      "guests" => 4,
      "adults" => 2,
      "children" => 2,
      "infants" => 0,
      "status" => "accepted",
      "guest" => {
        "id" => 1,
        "first_name" => "Wayne",
        "last_name" => "Woodbridge",
        "phone" => "639123456789",
        "email" => "wayne_woodbridge@bnb.com"
      },
      "currency" => "AUD",
      "payout_price" => "3800.00",
      "security_price" => "500",
      "total_price" => "4500.00"
    }
    
    @payload_type_2 = {
      "reservation" => {
        "start_date" => "2021-03-12",
        "end_date" => "2021-03-16",
        "expected_payout_amount" => "3800.00",
        "guest_details" => {
          "localized_description" => "4 guests",
          "number_of_adults" => 2,
          "number_of_children" => 2,
          "number_of_infants" => 0
        },
        "guest_email" => "wayne_woodbridge@bnb.com",
        "guest_first_name" => "Wayne",
        "guest_last_name" => "Woodbridge",
        "guest_phone_numbers" => [
          "639123456789",
          "639123456789"
        ],
        "listing_security_price_accurate" => "500.00",
        "host_currency" => "AUD",
        "nights" => 4,
        "number_of_guests" => 4,
        "status_type" => "accepted",
        "total_paid_amount_accurate" => "4500.00"
      }
    }
  end
  
  test "should parse payload type 1 correctly" do
    puts "Parsing payload type 1..."
    parsed_data = PayloadParserService.new(@payload_type_1).parse
    puts "Parsed data: #{parsed_data.inspect}"

    # Check reservation data
    assert_equal "2021-03-12", parsed_data[:reservation_data][:start_date]
    assert_equal "2021-03-16", parsed_data[:reservation_data][:end_date]
    assert_equal 4, parsed_data[:reservation_data][:nights]
    assert_equal "accepted", parsed_data[:reservation_data][:status]
    assert_equal "3800.00", parsed_data[:reservation_data][:payout_price]
    assert_equal 1, parsed_data[:reservation_data][:guest_id_from_payload]
    
    # Check guest data
    assert_equal "wayne_woodbridge@bnb.com", parsed_data[:guest_data][:email]
    assert_equal "Wayne", parsed_data[:guest_data][:first_name]
    assert_equal "Woodbridge", parsed_data[:guest_data][:last_name]
  end
  
  test "should parse payload type 2 correctly" do
    puts "Parsing payload type 2..."
    parsed_data = PayloadParserService.new(@payload_type_2).parse
    puts "Parsed data: #{parsed_data.inspect}"
    
    # Check reservation data
    assert_equal "2021-03-12", parsed_data[:reservation_data][:start_date]
    assert_equal "2021-03-16", parsed_data[:reservation_data][:end_date]
    assert_equal 4, parsed_data[:reservation_data][:nights]
    assert_equal "accepted", parsed_data[:reservation_data][:status]
    assert_equal "3800.00", parsed_data[:reservation_data][:payout_price]
    
    # Check guest data
    assert_equal "wayne_woodbridge@bnb.com", parsed_data[:guest_data][:email]
    assert_equal "Wayne", parsed_data[:guest_data][:first_name]
    assert_equal "Woodbridge", parsed_data[:guest_data][:last_name]
  end
end