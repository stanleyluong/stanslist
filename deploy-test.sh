#!/bin/bash

# Stan's List - Local Deployment Test Script
# This script tests your Flutter web build with all environment variables
# Run this before deploying to AWS Amplify to catch any issues early

echo "🚀 Stan's List - Local Deployment Test"
echo "======================================="

# Check if all required environment variables are set
echo "📋 Checking environment variables..."

required_vars=(
    "FIREBASE_API_KEY"
    "FIREBASE_AUTH_DOMAIN"
    "FIREBASE_PROJECT_ID"
    "FIREBASE_STORAGE_BUCKET"
    "FIREBASE_MESSAGING_SENDER_ID"
    "FIREBASE_APP_ID"
    "FIREBASE_MEASUREMENT_ID"
    "GOOGLE_MAPS_API_KEY"
    "GOOGLE_SIGN_IN_CLIENT_ID"
    "GOOGLE_SIGN_IN_SERVER_CLIENT_ID"
)

missing_vars=()

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
        echo "❌ $var is not set"
    else
        echo "✅ $var is set"
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo ""
    echo "❌ Missing environment variables:"
    printf '   %s\n' "${missing_vars[@]}"
    echo ""
    echo "Please set all required environment variables before running this script."
    echo "You can source them from a .env file or export them manually:"
    echo ""
    echo "Example:"
    echo "export FIREBASE_API_KEY='your_api_key'"
    echo "export FIREBASE_PROJECT_ID='your_project_id'"
    echo "# ... etc"
    echo ""
    exit 1
fi

echo ""
echo "🔧 Running Flutter clean..."
flutter clean

echo ""
echo "📦 Getting Flutter dependencies..."
flutter pub get

echo ""
echo "🏗️  Building Flutter web app with all environment variables..."
flutter build web --release \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
  --dart-define=FIREBASE_AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN" \
  --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
  --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
  --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID" \
  --dart-define=FIREBASE_MEASUREMENT_ID="$FIREBASE_MEASUREMENT_ID" \
  --dart-define=GOOGLE_MAPS_API_KEY="$GOOGLE_MAPS_API_KEY" \
  --dart-define=GOOGLE_SIGN_IN_CLIENT_ID="$GOOGLE_SIGN_IN_CLIENT_ID" \
  --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID="$GOOGLE_SIGN_IN_SERVER_CLIENT_ID"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build completed successfully!"
    echo ""
    echo "📁 Build output:"
    ls -la build/web/
    echo ""
    echo "🌐 You can test the build locally by running:"
    echo "   cd build/web && python3 -m http.server 8000"
    echo "   Then open http://localhost:8000 in your browser"
    echo ""
    echo "🚀 Your app is ready for AWS Amplify deployment!"
    echo ""
    echo "Next steps:"
    echo "1. Commit and push your changes to your Git repository"
    echo "2. Follow the AWS Amplify deployment guide (AMPLIFY_DEPLOYMENT_GUIDE.md)"
    echo "3. Use the deployment checklist (DEPLOYMENT_CHECKLIST.md) to track progress"
    echo ""
else
    echo ""
    echo "❌ Build failed!"
    echo "Please check the error messages above and fix any issues before deploying."
    echo ""
    exit 1
fi
