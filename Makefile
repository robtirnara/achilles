.PHONY: generate build run clean open

SCHEME = Achilles
PROJECT = Achilles.xcodeproj
SIM_NAME = iPhone 17 Pro

# Generate Xcode project from spec and build
all: generate build

# Generate .xcodeproj from project.yml
generate:
	@echo "⚙️  Generating Xcode project..."
	@xcodegen generate

# Build for iOS Simulator
build: generate
	@echo "🔨 Building $(SCHEME)..."
	@xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIM_NAME)' \
		-quiet build

# Boot simulator, build, install, and launch the app
run: build
	@echo "📱 Booting simulator..."
	@xcrun simctl boot "$(SIM_NAME)" 2>/dev/null || true
	@open -a Simulator
	@echo "📦 Installing app..."
	@APP_PATH=$$(xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIM_NAME)' \
		-showBuildSettings 2>/dev/null | grep -m1 'BUILT_PRODUCTS_DIR' | awk '{print $$3}'); \
	xcrun simctl install booted "$$APP_PATH/$(SCHEME).app"
	@echo "🚀 Launching Achilles..."
	@xcrun simctl launch booted com.tirnara.achilles
	@echo "✅ Achilles is running."

# Open project in Xcode
open: generate
	@open $(PROJECT)

# Wipe build artifacts
clean:
	@echo "🧹 Cleaning..."
	@xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean -quiet 2>/dev/null || true
	@rm -rf ~/Library/Developer/Xcode/DerivedData/Achilles-*
	@echo "✅ Clean."
