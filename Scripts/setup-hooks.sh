#!/bin/bash
# Setup script — run after cloning
set -e

echo "🔧 Setting up ComicPull development environment..."

# Configure git hooks
git config core.hooksPath .githooks
chmod +x .githooks/pre-push
echo "✅ Git hooks configured"

# Generate Xcode project
if command -v xcodegen &> /dev/null; then
    xcodegen generate
    echo "✅ Xcode project generated"
else
    echo "⚠️  xcodegen not found. Install with: brew install xcodegen"
    echo "   Then run: xcodegen generate"
fi

echo ""
echo "🎉 Setup complete! Open ComicPull.xcodeproj to get started."
