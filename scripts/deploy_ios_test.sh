#!/bin/bash
set -e

PROJECT_PATH="/Users/parkjc/Desktop/workland/project/Kohere"
cd "$PROJECT_PATH"

echo "Step 1: Fixing Flutter SDK permissions (might ask for password)..."
sudo chown -R $(whoami) /opt/homebrew/Caskroom/flutter/3.32.2/flutter

echo "Step 2: Cleaning and Fetching packages..."
flutter clean
flutter pub get

echo "Step 3: Building iOS Release (No Codesign)..."
flutter build ios --release --no-codesign

echo "Step 4: Packaging IPA..."
BUILD_DIR="$PROJECT_PATH/build/ios/iphoneos"
mkdir -p "$BUILD_DIR/Payload"
cp -r "$BUILD_DIR/Runner.app" "$BUILD_DIR/Payload/"
cd "$BUILD_DIR"
zip -r "KoHere_Test.ipa" Payload
echo "IPA created at: $BUILD_DIR/KoHere_Test.ipa"

echo "Step 5: Uploading to Firebase App Distribution..."
echo "You must be logged in to Firebase. If this fails, run 'firebase login' first."
firebase appdistribution:distribute "KoHere_Test.ipa" --app "1:408263536531:ios:a6a59799e3b03595624266"
