#!/bin/bash
# Run all tests with readable output
set -e

echo "🧪 Running ComicPull tests..."
echo ""

echo "=== Unit Tests ==="
xcodebuild -scheme ComicPull -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
  -only-testing:ComicPullTests test 2>&1 | grep -E "(Test Suite|Test Case|passed|failed|error:)" || true

echo ""
echo "=== UI Tests ==="
xcodebuild -scheme ComicPull -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
  -only-testing:ComicPullUITests test 2>&1 | grep -E "(Test Suite|Test Case|passed|failed|error:)" || true

echo ""
echo "✅ Test run complete."
