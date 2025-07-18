#!/bin/bash

echo "=== Fixing Production Database Connection ==="

# The correct database URL for your Raspberry Pi
NEW_DATABASE_URL="postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"

echo "Setting DATABASE_URL to match Raspberry Pi..."
export DATABASE_URL="$NEW_DATABASE_URL"

echo "Testing connection to Raspberry Pi database..."
echo "Database URL: $DATABASE_URL"

echo "Connection test complete. Please deploy with this environment variable."