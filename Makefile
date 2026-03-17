SCHEME = ComicPull
SIMULATOR = platform=iOS Simulator,name=iPhone 15 Pro,OS=latest

.PHONY: build test test-unit test-ui lint setup clean generate

generate:
	xcodegen generate

build:
	xcodebuild -scheme $(SCHEME) -sdk iphonesimulator -destination '$(SIMULATOR)' build 2>&1 | tail -20

test: test-unit test-ui

test-unit:
	xcodebuild -scheme $(SCHEME) -sdk iphonesimulator -destination '$(SIMULATOR)' \
		-only-testing:ComicPullTests test 2>&1 | tail -30

test-ui:
	xcodebuild -scheme $(SCHEME) -sdk iphonesimulator -destination '$(SIMULATOR)' \
		-only-testing:ComicPullUITests test 2>&1 | tail -30

lint:
	swiftlint lint --strict 2>&1 || true

setup:
	git config core.hooksPath .githooks
	chmod +x .githooks/pre-push
	@echo "✅ Git hooks configured. Run 'make generate' to create Xcode project."

clean:
	xcodebuild -scheme $(SCHEME) clean 2>/dev/null || true
	rm -rf ~/Library/Developer/Xcode/DerivedData/ComicPull-*
