# Reservation API

A Ruby on Rails API application that handles multiple reservation payload formats from different partners.

## Features

- Accepts and processes multiple reservation payload formats with a single endpoint
- Automatically detects payload format without requiring additional headers or parameters
- Stores reservation data with associated guest information
- Ensures guest uniqueness based on email
- Designed for scalability to handle additional payload formats in the future

## System Requirements

- Ruby 3.0.0 or higher
- Rails 7.0.0 or higher
- PostgreSQL 12.0 or higher

## Setup Instructions

1. Clone the repository
   ```bash
   git clone https://github.com/anjadriano16/reservation-api.git
   cd reservation_api
   ```

2. Install dependencies
   ```bash
   bundle install
   ```

3. Configure the database
   Edit `config/database.yml` if needed to match your PostgreSQL configuration.

4. Create and migrate the database
   ```bash
   rails db:create
   rails db:migrate
   ```

5. Run the tests
   ```bash
   rails test
   ```

6. Start the server
   ```bash
   rails server
   ```

The API will be accessible at http://localhost:3000

## API Documentation

### Create Reservation

**Endpoint:** POST /api/v1/reservations  
**Content-Type:** application/json  
**Description:** Creates a new reservation with guest information. Automatically detects the payload format.

#### Example Request (Format 1):

```bash
curl -X POST \
  http://localhost:3000/api/v1/reservations \
  -H 'Content-Type: application/json' \
  -d '{
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
}'
```

#### Example Request (Format 2):

```bash
curl -X POST \
  http://localhost:3000/api/v1/reservations \
  -H 'Content-Type: application/json' \
  -d '{
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
      "guest_id": 1,
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
}'
```

#### Successful Response:

```json
{
  "status": "success",
  "message": "Reservation created successfully",
  "data": {
    "id": 1,
    "guest_id": 1,
    "start_date": "2021-03-12",
    "end_date": "2021-03-16",
    "nights": 4,
    "adults": 2,
    "children": 2,
    "infants": 0,
    "status": "accepted",
    "currency": "AUD",
    "payout_price": "3800.0",
    "security_price": "500.0",
    "total_price": "4500.0",
    "created_at": "2023-05-12T12:34:56.789Z",
    "updated_at": "2023-05-12T12:34:56.789Z",
    "guest_id_from_payload": 1
  }
}
```

## Architecture

The application follows a service-oriented architecture:

- **Controllers**: Handle HTTP requests and responses
- **Services**: Contain business logic for parsing payloads and creating reservations
- **Models**: Define data structure and relationships

### Key Components:

- **PayloadParserService**: Automatically detects and parses different payload formats into a standardized format
- **ReservationCreationService**: Handles the creation or updating of guests and reservations
- **Api::V1::ReservationsController**: API endpoint that receives and processes reservation requests

## Adding Support for New Payload Formats

To add support for a new payload format:

1. Add a new parser method in PayloadParserService (e.g., `parse_payload_type_3`)
2. Update the parse method in PayloadParserService to detect the new format
3. Ensure the parser returns data in the standardized format used by ReservationCreationService

### Example:

```ruby
def parse
  if @payload.key?('reservation')
    parse_payload_type_2
  elsif @payload.key?('new_partner_reservation')
    parse_payload_type_3
  else
    parse_payload_type_1
  end
end

def parse_payload_type_3
  # Parse data from new partner format
  # Return standardized format
end
```

## Error Handling

The API handles various error cases:

- Invalid JSON format
- Missing required fields
- Database validation errors
- Unexpected errors

All errors return appropriate HTTP status codes and descriptive messages.

## Testing

The application includes comprehensive test coverage:

- **Controller tests**: Ensure API endpoints function correctly
- **Service tests**: Verify business logic for payload parsing and reservation creation
- **Model tests**: Validate data relationships and constraints

Run the tests with:

```bash
rails test
```

## License

MIT License
