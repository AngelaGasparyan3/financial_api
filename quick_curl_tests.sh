#!/bin/bash

# Quick cURL tests using your seeded data
# Run these commands after starting your Rails server: rails server

echo "🚀 Testing Role-Based Access Control"
echo "======================================"

# Step 1: Get tokens from seeded users
echo "1 Getting authentication tokens..."

echo "Admin login:"
ADMIN_RESPONSE=$(curl -s -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password"}')
echo $ADMIN_RESPONSE
ADMIN_TOKEN=$(echo $ADMIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo -e "\nAlice login:"
ALICE_RESPONSE=$(curl -s -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email": "alice@example.com", "password": "password"}')
echo $ALICE_RESPONSE
ALICE_TOKEN=$(echo $ALICE_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo -e "\nBob login:"
BOB_RESPONSE=$(curl -s -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email": "bob@example.com", "password": "password"}')
echo $BOB_RESPONSE
BOB_TOKEN=$(echo $BOB_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo -e "\n"

# Step 2: Test Admin Access
echo "2 Testing Admin Access (Should work)..."

echo "✅ Admin viewing all users:"
curl -s -X GET http://localhost:3000/admin/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'

echo -e "\n✅ Admin viewing all transfers:"
curl -s -X GET http://localhost:3000/transfers \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'

echo -e "\n✅ Admin updating user role (making Bob admin):"
curl -s -X PATCH http://localhost:3000/admin/users/3/update_role \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "admin"}' | jq '.'

# Step 3: Test Regular User Access (Should work)
echo -e "\n3 Testing Regular User Access (Should work)..."

echo "✅ Alice viewing her own profile:"
curl -s -X GET http://localhost:3000/users/2 \
  -H "Authorization: Bearer $ALICE_TOKEN" | jq '.'

echo -e "\n✅ Alice viewing her account:"
curl -s -X GET http://localhost:3000/accounts/1 \
  -H "Authorization: Bearer $ALICE_TOKEN" | jq '.'

echo -e "\n✅ Alice viewing her transfers:"
curl -s -X GET http://localhost:3000/transfers \
  -H "Authorization: Bearer $ALICE_TOKEN" | jq '.'

# Step 4: Test Unauthorized Access (Should fail)
echo -e "\n4 Testing Unauthorized Access (Should fail)..."

echo "❌ Alice trying to access admin users (should fail):"
curl -s -X GET http://localhost:3000/admin/users \
  -H "Authorization: Bearer $ALICE_TOKEN" | jq '.'

echo -e "\n❌ Alice trying to view Bob's profile (should fail):"
curl -s -X GET http://localhost:3000/users/3 \
  -H "Authorization: Bearer $ALICE_TOKEN" | jq '.'

echo -e "\n❌ Bob trying to access Alice's account (should fail):"
curl -s -X GET http://localhost:3000/accounts/1 \
  -H "Authorization: Bearer $BOB_TOKEN" | jq '.'

echo -e "\n❌ Bob trying to update Alice's account balance (should fail):"
curl -s -X PATCH http://localhost:3000/accounts/1/update_balance \
  -H "Authorization: Bearer $BOB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"balance": 10000}' | jq '.'

echo -e "\n❌ No token - accessing users (should fail):"
curl -s -X GET http://localhost:3000/users/1 | jq '.'

# Step 5: Test Transfer Security
echo -e "\n5 Testing Transfer Security..."

echo "✅ Alice creating transfer from her account (should work):"
curl -s -X POST http://localhost:3000/transfers \
  -H "Authorization: Bearer $ALICE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"from_account_id": 1, "to_account_id": 2, "amount": 50}' | jq '.'

echo -e "\n❌ Alice trying to transfer from Bob's account (should fail):"
curl -s -X POST http://localhost:3000/transfers \
  -H "Authorization: Bearer $ALICE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"from_account_id": 2, "to_account_id": 1, "amount": 25}' | jq '.'


# Manual commands for easy copy-paste testing:
echo -e "\n📋 Manual cURL commands for quick testing:"
echo "=========================================="

echo "# Admin login:"
echo 'curl -X POST http://localhost:3000/login -H "Content-Type: application/json" -d '"'"'{"email": "admin@example.com", "password": "password"}'"'"

echo -e "\n# Admin view all users:"
echo 'curl -X GET http://localhost:3000/admin/users -H "Authorization: Bearer YOUR_ADMIN_TOKEN"'

echo -e "\n# Regular user login:"
echo 'curl -X POST http://localhost:3000/login -H "Content-Type: application/json" -d '"'"'{"email": "alice@example.com", "password": "password"}'"'"

echo -e "\n# Regular user try admin endpoint (should fail):"
echo 'curl -X GET http://localhost:3000/admin/users -H "Authorization: Bearer YOUR_USER_TOKEN"'

echo -e "\n# Create transfer:"
echo 'curl -X POST http://localhost:3000/transfers -H "Authorization: Bearer YOUR_TOKEN" -H "Content-Type: application/json" -d '"'"'{"from_account_id":1,"to_account_id":2,"amount":25}'"'"

echo -e "\n# Update user role (admin only):"
echo 'curl -X PATCH http://localhost:3000/admin/users/2/update_role -H "Authorization: Bearer YOUR_ADMIN_TOKEN" -H "Content-Type: application/json" -d '"'"'{"role":"admin"}'"'"
