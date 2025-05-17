# Financial API

A simple financial API built with Ruby on Rails and PostgreSQL, featuring JWT-based authentication.

## Technologies

- Ruby 3.2.2
- Ruby on Rails
- PostgreSQL
- JWT for authorization

## Features

- Create user (email + password)
- Check user balance
- Update user balance
- Transfer funds between users

## Setup

### Clone the repo:
```bash
git clone https://github.com/AngelaGasparyan3/financial_api.git
cd financial_api
bundle install
rails db:create db:migrate
rails server
```

### Run all tests:
```bash
bundle exec rspec
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







