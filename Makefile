.PHONY: help generate build clean install test simulator open lint archive ipa upload-testflight

# Load environment variables from .env if it exists
-include .env

PROJECT = NiftyKey.xcodeproj
SCHEME = NiftyKey
SIMULATOR = iPhone 17
SIMULATOR_OS = 26.1
CONFIGURATION = Debug
ARCHIVE_PATH = build/NiftyKey.xcarchive
EXPORT_PATH = build/export
IPA_PATH = $(EXPORT_PATH)/NiftyKey.ipa
EXPORT_OPTIONS = build/ExportOptions.plist

# TEAM: set explicitly (TEAM=XXXXXXXXXX make ipa) or auto-detected from Apple Development cert
ifndef TEAM
TEAM := $(shell security find-certificate -a -z -c "Apple Development" -p 2>/dev/null | openssl x509 -noout -subject 2>/dev/null | sed -n 's/.*OU=\([^,]*\).*/\1/p' | head -1)
endif

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

$(EXPORT_OPTIONS):
	@test -n "$(TEAM)" || (echo "Set TEAM to your Apple Developer team ID (e.g. TEAM=XXXXXXXXXX make ipa)" && exit 1)
	@mkdir -p build
	@sed 's/YOUR_TEAM_ID/$(TEAM)/' ExportOptions.plist.example > $(EXPORT_OPTIONS)

archive: generate ## Create Release .xcarchive for device (TestFlight)
	@test -n "$(TEAM)" || (echo "Set TEAM to your Apple Developer team ID (e.g. TEAM=XXXXXXXXXX make ipa)" && exit 1)
	@mkdir -p build
	@echo "Archiving NiftyKey (team $(TEAM))..."
	@xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Release \
		-destination 'generic/platform=iOS' \
		-archivePath $(ARCHIVE_PATH) \
		DEVELOPMENT_TEAM=$(TEAM) \
		CODE_SIGN_STYLE=Automatic \
		-allowProvisioningUpdates \
		archive

ipa: archive $(EXPORT_OPTIONS) ## Export App Store IPA from archive (TestFlight)
	@rm -rf $(EXPORT_PATH)
	@mkdir -p $(EXPORT_PATH)
	@echo "Exporting IPA..."
	@xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath $(EXPORT_PATH) \
		-exportOptionsPlist $(EXPORT_OPTIONS) \
		-allowProvisioningUpdates
	@echo "IPA ready: $(IPA_PATH)"


upload-testflight: ipa ## Upload IPA to App Store Connect (API key or app-specific password)
	@if [ -n "$(APP_STORE_CONNECT_API_KEY)" ] && [ -n "$(APP_STORE_CONNECT_ISSUER_ID)" ]; then \
		echo "Uploading $(IPA_PATH) to App Store Connect..."; \
		xcrun altool --upload-app -f "$(IPA_PATH)" -t ios \
			--apiKey "$(APP_STORE_CONNECT_API_KEY)" \
			--apiIssuer "$(APP_STORE_CONNECT_ISSUER_ID)"; \
	elif [ -n "$(APPLE_ID)" ] && [ -n "$(APP_SPECIFIC_PASSWORD)" ]; then \
		echo "Uploading $(IPA_PATH) to App Store Connect..."; \
		xcrun altool --upload-app -f "$(IPA_PATH)" -t ios \
			-u "$(APPLE_ID)" -p "$(APP_SPECIFIC_PASSWORD)"; \
	else \
		echo "No upload credentials set. Use one of:"; \
		echo "  APP_STORE_CONNECT_API_KEY + APP_STORE_CONNECT_ISSUER_ID"; \
		echo "  APPLE_ID + APP_SPECIFIC_PASSWORD"; \
		echo ""; \
		echo "Or upload manually with Transporter, or:"; \
		echo "  xcrun altool --upload-app -f $(IPA_PATH) -t ios -u YOUR_APPLE_ID -p @keychain:AC_PASSWORD"; \
		exit 1; \
	fi

.DEFAULT_GOAL := help
