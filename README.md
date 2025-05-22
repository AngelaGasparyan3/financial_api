# Financial API

# 💰 Finance API

A simple financial API built with **Ruby on Rails** that supports:

- User registration and authentication (JWT-based)
- Role-based access control (admin / regular)
- Balance management and transfers
- Admin namespace for user and transfer management

## Features

- JWT authentication (`POST /login`)
- User registration (`POST /users`)
- Account balance viewing
- Transfers between users
- Admin routes for:
  - Viewing all users
  - Updating user roles

## Technologies

- Ruby 3.2.2
- Ruby on Rails
- PostgreSQL
- JWT for authorization

## Setup

### Clone the repo:
```bash
git clone https://github.com/AngelaGasparyan3/financial_api.git
cd financial_api
bundle install
rails db:create db:migrate rails db:seed
rails server
```

## Run all tests:
```bash
bundle exec rspec
```
## Code Style – RuboCop:
```bash
bundle exec rubocop
```
## Quick Test Script:
 A shell script is included to quickly test the core functionality of the API using curl commands.

### Run the Tests:
```bash
  chmod +x quick_curl_tests.sh
  ./quick_curl_tests.sh
```
### What it Tests
  - User creation (Alice, Bob)
  - User login and JWT token retrieval
  - Admin login and role update
  - Access control (user can view own profile, but not others')
  - Fund transfers between users
  - Admin viewing all users and transfers

Output
-The script prints each step and shows formatted JSON responses using jq. You’ll see:
-Created users with IDs
-Tokens assigned to each user
-Successful and failed access attempts
-Balance checks and transfer results

Requirements
 Make sure you have:
- jq installed (for JSON formatting)
- Your Rails server running on http://localhost:3000
You can install jq if missing:
```bash
  # macOS
  brew install jq
  
  # Ubuntu/Debian
  sudo apt install jq

```
## API Usage (curl examples)

### Create user
```bash
  curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{ "user": {"email": "unique_user@example.com", "password": "password123"} }'
```

### Login and get JWT token
```bash
  curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{ "email":"unique_user@example.com","password":"password123" }'
```

### Check user balance
```bash
  curl -X GET http://localhost:3000/users/1 \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

### Update user balance
```bash
  curl -X PATCH http://localhost:3000/users/1/update_balance \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "amount":100.0 }'
```

### Transfer funds between users
```bash
  curl -X POST http://localhost:3000/users/transfer \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "recipient_email":"recipient@example.com","amount":50.0 }'
```







