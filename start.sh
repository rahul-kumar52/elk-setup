#!/bin/bash

# Simple startup script for Elasticsearch with automatic S3 upload

echo "🚀 Starting Elasticsearch with automatic S3 upload..."

# Start the S3 monitor in background
echo "📡 Starting S3 upload monitor..."
./auto-s3-upload.sh -m &
MONITOR_PID=$!

echo "🐳 Starting docker-compose..."
docker-compose up -d

echo "✅ Setup started!"
echo "📊 Monitor PID: $MONITOR_PID"
echo "📝 Logs: s3-upload.log"
echo ""
echo "To view logs: ./auto-s3-upload.sh -l"
echo "To stop: docker-compose down" 