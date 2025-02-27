require 'test_helper'
require_relative "../../app/errors/reservation_error"

class ReservationCreationServiceTest < ActiveSupport::TestCase
  setup do
    @parsed_data = build_parsed_data
  end

  test "should create new guest and reservation" do
    assert_difference(['Guest.count', 'Reservation.count']) do
      create_reservation(@parsed_data)
    end

    verify_guest_and_reservation
  end

  test "should update existing guest and create new reservation" do
    guest = create_existing_guest
    assert_no_difference('Guest.count') do
      assert_difference('Reservation.count') do
        create_reservation(@parsed_data)
      end
    end

    verify_guest_update(guest)
    verify_new_reservation(guest)
  end

  test "should raise error with invalid data" do
    invalid_data = @parsed_data.deep_dup
    invalid_data[:reservation_data].delete(:start_date)

    assert_raises(ReservationError) do
      create_reservation(invalid_data)
    end
  end

  private

  def build_parsed_data
    {
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

  def create_reservation(data)
    ReservationCreationService.new(data).create_or_update
  end

  def verify_guest_and_reservation
    guest = Guest.last
    assert_equal "wayne_woodbridge@bnb.com", guest.email
    assert_equal "Wayne", guest.first_name

    reservation = Reservation.last
    assert_equal guest, reservation.guest
    assert_equal Date.parse("2021-03-12"), reservation.start_date
    assert_equal "accepted", reservation.status
    assert_equal 4, reservation.nights
  end

  def create_existing_guest
    Guest.create!(
      email: "wayne_woodbridge@bnb.com",
      first_name: "Old Name",
      last_name: "Old Last Name",
      phone: "123456789"
    )
  end

  def verify_guest_update(guest)
    guest.reload
    assert_equal "Wayne", guest.first_name
    assert_equal "Woodbridge", guest.last_name
    assert_equal "639123456789", guest.phone
  end

  def verify_new_reservation(guest)
    reservation = Reservation.last
    assert_equal guest, reservation.guest
  end
end