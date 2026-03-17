#!/bin/bash
# SwiftLint wrapper
if command -v swiftlint &> /dev/null; then
    swiftlint lint --strict
else
    echo "⚠️  SwiftLint not found. Install with: brew install swiftlint"
fi
