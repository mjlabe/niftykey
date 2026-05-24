# NiftyKey

A fully local, privacy-focused, open-source iOS keyboard. No cloud. No tracking. No ads.

## Features

- **QWERTY layout** with optional number row
- **Swipe typing** (gesture-based word input)
- **Local predictions** via trie-based dictionary
- **Autocorrect** with edit-distance matching
- **Double-space period** insertion
- **Auto capitalization** after sentence-ending punctuation
- **Long-press period key** with punctuation popup
- **Spacebar cursor movement** via swipe gesture
- **Haptic feedback** on key presses
- **Dark/Light/AMOLED themes** that follow system appearance
- **Backspace repeat** with word-delete acceleration
- **Emoji keyboard** support
- **No Full Access required** — works completely sandboxed

## Privacy

NiftyKey never sends any data off your device. There is:
- No analytics
- No telemetry
- No cloud sync
- No network requests
- No ad SDKs

All learned words and preferences stay in the app's sandboxed container.

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

## Quick Start

### Using Make (Recommended)

```bash
# Initial setup (installs dependencies)
make setup

# Build, install on simulator, and open
make run

# Or step by step:
make build      # Build the project
make install    # Install on simulator
make simulator  # Open simulator
make test       # Run unit tests
```

### Manual Build

#### 1. Install XcodeGen

```bash
brew install xcodegen
```

#### 2. Generate the Xcode project

```bash
cd niftykey
xcodegen generate
```

#### 3. Build for simulator

```bash
xcodebuild -project NiftyKey.xcodeproj \
  -scheme NiftyKey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

#### 4. Install on simulator

```bash
# Boot simulator
xcrun simctl boot "iPhone 17 Pro"

# Install app
xcrun simctl install "iPhone 17 Pro" \
  ~/Library/Developer/Xcode/DerivedData/NiftyKey-*/Build/Products/Debug-iphonesimulator/NiftyKey.app
```

### Enable the keyboard

1. Open the simulator and launch the NiftyKey app
2. Go to **Settings → General → Keyboard → Keyboards**
3. Tap **Add New Keyboard...**
4. Select **NiftyKey**
5. Open any app with a text field
6. Tap the globe key to switch to NiftyKey

## Architecture

```
NiftyKey/
├── App/                        # Container app (settings UI)
├── Keyboard/                   # Keyboard extension target
│   ├── KeyboardViewController  # UIInputViewController (UIKit shell)
│   └── Views/                  # SwiftUI keyboard rendering
├── Packages/
│   ├── SharedModels/           # Data types, layouts, settings
│   ├── KeyboardCore/           # Input coordination, haptics, state
│   ├── ThemeEngine/            # Theme definitions and provider
│   └── PredictionEngine/       # Trie, predictions, autocorrect
└── Tests/
```

### Design Principles

- **Hybrid UIKit + SwiftUI**: UIKit handles the extension lifecycle and text proxy; SwiftUI handles rendering
- **Modular packages**: Each concern is isolated into a Swift Package
- **Unidirectional data flow**: State changes flow down, actions flow up
- **Performance-first**: Sub-16ms key response, 60fps rendering target
- **No global mutable state**: Dependency injection throughout

## Development Phases

| Phase | Focus | Status |
|-------|-------|--------|
| 1 | Foundation (typing, layout, input) | ✅ |
| 2 | Suggestions (autocorrect, predictions) | ✅ |
| 3 | Swipe typing | 🔲 |
| 4 | Personalization (learning) | 🔲 |
| 5 | Polish (animations, accessibility) | 🔲 |
| 6 | Experimental ML | 🔲 |

## License

MIT
