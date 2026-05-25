.PHONY: help generate build clean install test simulator open lint

PROJECT = NiftyKey.xcodeproj
SCHEME = NiftyKey
SIMULATOR = iPhone 17
SIMULATOR_OS = 26.1
CONFIGURATION = Debug

help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

generate: ## Generate Xcode project from project.yml
	@echo "Generating Xcode project..."
	@xcodegen generate
	@echo "Project generated"

build: generate ## Build the project
	@echo "Building NiftyKey..."
	@xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR),OS=$(SIMULATOR_OS)' \
		-configuration $(CONFIGURATION) \
		-quiet \
		build
	@echo "Build complete"

clean: ## Clean build artifacts
	@echo "Cleaning..."
	@xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean 2>/dev/null || true
	@rm -rf build/
	@rm -rf DerivedData/
	@echo "Clean complete"

install: build ## Build and install on simulator
	@echo "Installing on $(SIMULATOR)..."
	@xcrun simctl boot "$(SIMULATOR)" 2>/dev/null || true
	@sleep 2
	@xcrun simctl install "$(SIMULATOR)" \
		$$(find ~/Library/Developer/Xcode/DerivedData/NiftyKey-*/Build/Products/$(CONFIGURATION)-iphonesimulator -name "NiftyKey.app" -type d | head -1)
	@echo "Installed on simulator"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Open the simulator: make simulator"
	@echo "  2. Launch the NiftyKey app"
	@echo "  3. Go to Settings -> General -> Keyboard -> Keyboards"
	@echo "  4. Tap 'Add New Keyboard...'"
	@echo "  5. Select 'NiftyKey'"
	@echo "  6. Open any app and tap a text field"
	@echo "  7. Tap the globe key to switch to NiftyKey"

simulator: ## Open the simulator
	@echo "Opening $(SIMULATOR)..."
	@open -a Simulator --args -CurrentDeviceUDID $$(xcrun simctl list devices | grep "$(SIMULATOR)" | grep -E -o -i "([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})" | head -1)

test: generate ## Run unit tests
	@echo "Running tests..."
	@xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR),OS=$(SIMULATOR_OS)' \
		-quiet
	@echo "Tests complete"

open: ## Open project in Xcode
	@echo "Opening Xcode..."
	@open $(PROJECT)

lint: ## Run SwiftLint (if installed)
	@if command -v swiftlint >/dev/null 2>&1; then \
		echo "Running SwiftLint..."; \
		swiftlint; \
	else \
		echo "SwiftLint not installed. Install with: brew install swiftlint"; \
	fi

quick: generate ## Quick build without xcpretty
	@echo "Quick building..."
	@xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR),OS=$(SIMULATOR_OS)' \
		-configuration $(CONFIGURATION) \
		build
	@echo "Build complete"

run: install simulator ## Build, install, and open simulator
	@echo "Ready to test. Follow the setup instructions above."

setup: ## Initial setup - install dependencies
	@echo "Setting up development environment..."
	@if ! command -v xcodegen >/dev/null 2>&1; then \
		echo "Installing XcodeGen..."; \
		brew install xcodegen; \
	else \
		echo "XcodeGen already installed"; \
	fi
	@echo "Setup complete"

.DEFAULT_GOAL := help
