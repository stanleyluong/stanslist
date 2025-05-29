#!/bin/bash

# Simple script to test the Flutter web app locally
cd "$(dirname "$0")"

# Ensure we're in the project root
if [ ! -f "pubspec.yaml" ]; then
  echo "Error: Must run this script from the project root directory"
  exit 1
fi

echo "Starting local web server for Stan's List..."
echo "Open http://localhost:8000 in your browser"
echo "Press Ctrl+C to stop the server"

# Use Python's built-in HTTP server to serve the web build
cd build/web
python3 -m http.server 8000
