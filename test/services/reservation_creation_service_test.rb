require 'test_helper'
require_relative "../../app/errors/reservation_error"

class ReservationCreationServiceTest < ActiveSupport::TestCase
  setup do
    @parsed_data = {
      reservation_data: {
        start_date: "2021-03-12",
        end_date: "2021-03-16",
        nights: 4,
        adults: 2,
        children: 2,
        infants: 0,
        status: "accepted",
        currency: "AUD",
        payout_price: "3800.00",
        security_price: "500",
        total_price: "4500.00",
        guest_id_from_payload: 1
      },
      guest_data: {
        email: "wayne_woodbridge@bnb.com",
        first_name: "Wayne",
        last_name: "Woodbridge",
        phone: "639123456789"
      }
    }
  end
  
  test "should create new guest and reservation" do
    puts "Testing: should create new guest and reservation"
    assert_difference('Guest.count') do
      assert_difference('Reservation.count') do
        ReservationCreationService.new(@parsed_data).create_or_update
      end
    end
    
    # Verify guest data
    guest = Guest.last
    puts "Guest created: #{guest.inspect}"
    assert_equal "wayne_woodbridge@bnb.com", guest.email
    assert_equal "Wayne", guest.first_name
    
    # Verify reservation data
    reservation = Reservation.last
    puts "Reservation created: #{reservation.inspect}"
    assert_equal guest, reservation.guest
    assert_equal Date.parse("2021-03-12"), reservation.start_date
    assert_equal "accepted", reservation.status
    assert_equal 4, reservation.nights
  end
  
  test "should update existing guest and create new reservation" do
    puts "Testing: should update existing guest and create new reservation"
    # Create guest first
    guest = Guest.create!(
      email: "wayne_woodbridge@bnb.com",
      first_name: "Old Name",
      last_name: "Old Last Name",
      phone: "123456789"
    )

    puts "Existing guest before update: #{guest.inspect}"
    
    assert_no_difference('Guest.count') do
      assert_difference('Reservation.count') do
        ReservationCreationService.new(@parsed_data).create_or_update
      end
    end
    
    # Verify guest was updated
    guest.reload
    puts "Updated guest: #{guest.inspect}"
    assert_equal "Wayne", guest.first_name
    assert_equal "Woodbridge", guest.last_name
    assert_equal "639123456789", guest.phone
    
    # Verify new reservation was created
    reservation = Reservation.last
    puts "New reservation created: #{reservation.inspect}"
    assert_equal guest, reservation.guest
  end
  
  test "should raise error with invalid data" do
    puts "Testing: should raise error with invalid data"
    # Missing required field
    invalid_data = @parsed_data.deep_dup
    invalid_data[:reservation_data].delete(:start_date)

    puts "Invalid data: #{invalid_data.inspect}"
    
    assert_raises(ReservationError) do
      ReservationCreationService.new(invalid_data).create_or_update
    end
  end
end