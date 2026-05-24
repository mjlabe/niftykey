# plan.md — Local-Only FOSS iOS Keyboard Inspired by Swiftly Keyboard

## Goal

Build a fully local, privacy-focused, open-source iOS keyboard inspired by the layout, feel, speed, and feature set of Swiftly Keyboard.

The app must:

* Run entirely on-device.
* Never send keystrokes or user data to servers.
* Be fully open source.
* Work as a custom iOS keyboard extension.
* Support modern iPhones and iPads.
* Prioritize low latency and reliability.
* Match Swiftly’s UX patterns closely where legally safe.
* Avoid trademarked assets, names, or copied proprietary code.

---

# Product Vision

## Core Philosophy

The keyboard should feel:

* Extremely fast.
* Gesture-driven.
* Intelligent without cloud AI.
* Minimal and ergonomic.
* Configurable.
* Native to iOS.

The system should rely on:

* On-device language models.
* Compact prediction engines.
* Efficient caching.
* Native rendering.
* Battery-conscious architecture.

---

# High-Level Feature List

## MVP Features

### Keyboard Basics

* QWERTY layout.
* Optional persistent number row.
* Toggleable compact number row mode.
* Shift/caps lock.
* Numbers and symbols pages.
* Emoji keyboard.
* Backspace repeat.
* Return/search/send key variations.
* Haptic feedback.
* Sound feedback.
* Dark/light themes.
* Dynamic height support.
* Safe area support.
* iPad layout support.

### Typing Intelligence

MUST HAVE MVP features:

* Double-space period.
* Auto capitalization.
* Optional top number row.
* Long-press period key that reveals additional punctuation.
* Swipe/flick punctuation selection from the period key popup.

These are hard requirements and not optional stretch goals.

* Local autocorrect.
* Local next-word prediction.
* Swipe typing.
* Double-space period.
* Auto capitalization.
* Smart punctuation.
* Learned local dictionary.

### Gesture Features

* Swipe to type.
* Swipe left on backspace to delete word.
* Swipe on spacebar to move cursor.
* Long press for alternate characters.
* Long-press period key popup for punctuation shortcuts.
* Swipe-selection punctuation menu from the period key.
* Quick punctuation flick gestures similar to modern mobile keyboards.
* Hold shift for caps lock.

### Privacy

* Fully offline.
* No analytics.
* No telemetry.
* No cloud sync.
* No ad SDKs.
* Sandboxed storage.

### Open Source

* MIT or Apache-2.0 license.
* Public GitHub repository.
* Reproducible builds.
* Clear contribution docs.

---

# Stretch Features

## Advanced Prediction

* Transformer-lite local language model.
* Personal writing adaptation.
* Multi-language prediction.
* Personalized autocorrect.

## UX Features

* Clipboard manager.
* Custom themes.
* One-handed mode.
* Split keyboard.
* Floating keyboard.
* Quick emoji suggestions.
* GIF/sticker support (local pack only).

## Power User Features

* Text snippets.
* Macro expansion.
* Vim-style cursor movement.
* Programmable shortcuts.
* Developer debugging overlay.

## Accessibility

* VoiceOver optimization.
* Adjustable key sizes.
* High contrast mode.
* Reduced motion mode.
* Left/right handed tuning.

---

# Legal and Ethical Constraints

## Must NOT Do

* Do not reuse Swiftly source code.
* Do not reuse Swiftly assets.
* Do not copy proprietary branding.
* Do not imitate trademarked logos.
* Do not use proprietary prediction datasets without permission.

## Safe Inspiration Areas

* General keyboard layout.
* UX interaction patterns.
* Gesture concepts.
* Navigation philosophy.
* Similar visual density.

---

# Recommended Tech Stack

## Language

* Swift 6+

## UI

* SwiftUI for settings app.
* UIKit for keyboard rendering performance.

Reason:

UIKit is still substantially better for ultra-low-latency keyboard rendering.

## Architecture

* MVVM + modular services.
* Unidirectional state flow.
* Dependency injection.

## Storage

* App Group shared container.
* SQLite for learned dictionary.
* UserDefaults for preferences.

## ML / NLP

Preferred order:

1. Apple NaturalLanguage framework.
2. CoreML.
3. Custom trie/prefix models.
4. Tiny local transformer.

## Suggested OSS Libraries

### Gesture Recognition

* Native UIGestureRecognizer first.

### Swipe Typing

Potential references:

* OpenBoard (Android reference only).
* FlorisBoard (algorithm inspiration only).

### Language Models

* llama.cpp (optional experimental).
* CoreML-compatible tiny models.

### Database

* GRDB.swift.

### Logging

* os.log.

---

# Repository Structure

```text
swiftly-clone/
├── Apps/
│   ├── KeyboardApp/
│   └── KeyboardExtension/
├── Packages/
│   ├── KeyboardCore/
│   ├── PredictionEngine/
│   ├── SwipeEngine/
│   ├── ThemeEngine/
│   ├── SettingsFeature/
│   ├── SharedModels/
│   └── AnalyticsStub/
├── ML/
│   ├── Dictionaries/
│   ├── Tokenizers/
│   └── Models/
├── Scripts/
├── Docs/
├── Tests/
└── README.md
```

---

# iOS Keyboard Extension Constraints

## Important Limitations

Custom iOS keyboards:

* Cannot access secure fields.
* May be replaced automatically for password entry.
* Have memory constraints.
* Have lifecycle interruptions.
* Cannot draw outside keyboard bounds.
* Require explicit “Full Access” for network/storage beyond sandbox.

The project should work WITHOUT Full Access.

---

# Core System Design

# 1. Keyboard Rendering Engine

## Responsibilities

* Draw keys.
* Handle touch events.
* Animate presses.
* Render suggestions.
* Manage layout transitions.

## Performance Goals

* Touch latency under 16ms.
* Stable 60fps minimum.
* Minimal layout invalidation.

## Recommended Structure

```text
KeyboardViewController
 ├── KeyboardRootView
 ├── KeyGridView
 ├── SuggestionBarView
 ├── GestureLayer
 └── InputCoordinator
```

---

# 2. Layout Engine

## Responsibilities

* Dynamic key sizing.
* Device adaptation.
* Orientation changes.
* Locale-specific layouts.

## Layout Data Model

```swift
struct KeyDefinition {
    let id: String
    let primary: String
    let secondary: String?
    let widthWeight: Float
    let type: KeyType
}
```

## Layout Types

* QWERTY.
* QWERTY with dedicated number row.
* AZERTY.
* QWERTZ.
* Dvorak.
* Colemak.
* Numeric.
* Symbols.
* Emoji.

---

# 3. Input Engine

## Responsibilities

* Text insertion.
* Deletion.
* Cursor movement.
* Autocorrect application.
* Suggestion acceptance.

## Key APIs

Use:

```swift
textDocumentProxy
```

Important methods:

```swift
insertText()
deleteBackward()
documentContextBeforeInput
```

---

# 4. Prediction Engine

## Architecture

Use a layered prediction strategy.

### Layer 1 — Dictionary Lookup

* Fast trie lookup.
* Frequency-ranked words.

### Layer 2 — Statistical Prediction

* N-gram predictions.
* Context scoring.

### Layer 3 — ML Enhancement

* Optional local transformer.
* Personalized ranking.

## Prediction Pipeline

```text
Input
 → Tokenizer
 → Context Analyzer
 → Candidate Generator
 → Ranking Engine
 → Suggestion Bar
```

## Requirements

* Fully offline.
* Sub-20ms suggestion latency.
* Incremental learning.
* Multi-language support.

---

# 5. Swipe Typing Engine

## Core Components

### Path Sampling

Capture:

* Touch points.
* Velocity.
* Timing.
* Direction changes.

### Gesture Decoder

Convert swipe path into:

* Character candidates.
* Word candidates.

### Candidate Ranking

Rank using:

* Dictionary frequency.
* Language model context.
* Geometric similarity.

## Suggested Algorithm

Hybrid approach:

```text
Swipe Path
 → Spatial Quantization
 → Key Hit Estimation
 → Beam Search
 → Word Ranking
```

## Performance Goals

* Real-time decoding.
* No visible lag.
* Minimal battery impact.

---

# 6. Local Learning System

## Goals

Learn:

* Frequently typed words.
* Slang.
* Names.
* User corrections.
* Writing style.

## Storage Rules

* Never upload data.
* Store encrypted if possible.
* Allow reset/export/delete.

## Data Model

```swift
struct LearnedWord {
    let word: String
    let frequency: Int
    let lastUsed: Date
}
```

---

# 6B. Advanced Punctuation System

## Required UX

The keyboard must support a long-press period key that opens a radial or horizontal punctuation popup.

Users should be able to:

* Hold the period key.
* Slide or flick toward punctuation marks.
* Release to insert punctuation quickly.

## Suggested Punctuation Set

* Comma
* Question mark
* Exclamation point
* Colon
* Semicolon
* Apostrophe
* Quotation marks
* Parentheses
* Hyphen

## Interaction Goals

* One-handed usability.
* Extremely low latency.
* Predictable gesture targeting.
* Works during fast typing.

## Implementation Notes

Use:

* UILongPressGestureRecognizer
* Custom popup overlay view
* Direction-based selection tracking
* Haptic confirmation on selection change

---

# 7. Suggestion Bar

## Features

* 3 primary suggestions.
* Tap to replace.
* Inline autocorrect.
* Emoji suggestions.
* Smart punctuation.

## UX Rules

* No jitter.
* Stable layout.
* Fast updates.
* Graceful fallback.

---

# 8. Theme System

## Requirements

* Light mode.
* Dark mode.
* AMOLED mode.
* Dynamic colors.
* User custom themes.

## Theme Model

```swift
struct KeyboardTheme {
    let backgroundColor: UIColor
    let keyColor: UIColor
    let pressedKeyColor: UIColor
    let textColor: UIColor
}
```

---

# 9. Settings App

## Sections

### General

* Auto-correct.
* Swipe typing.
* Haptics.
* Sound.
* Prediction strength.

### Appearance

* Themes.
* Keyboard height.
* Key borders.

### Privacy

* Clear learned words.
* Export dictionary.
* Delete local data.

### Advanced

* Debug logging.
* Experimental models.
* Developer tools.

---

# 10. Emoji System

## Features

* Emoji categories.
* Recently used.
* Skin tone modifiers.
* Search.
* Emoji prediction.

## Storage

Use local emoji metadata JSON.

---

# Accessibility Requirements

## Must Support

* VoiceOver.
* Dynamic Type.
* High contrast.
* Reduced motion.
* Switch Control.

## Interaction Goals

* Large touch targets.
* Predictable focus order.
* Minimal accidental gestures.

---

# Performance Targets

## Startup

* Cold start under 300ms.

## Typing

* Key response under 16ms.
* Suggestion generation under 20ms.
* Swipe decode under 50ms.

## Memory

* Prefer under 60MB.

## Battery

* Minimal background work.
* No constant polling.

---

# Security Model

## Rules

* No outbound networking.
* No hidden analytics.
* No third-party telemetry.
* Explicit permissions only.

## Optional Mode

Allow optional downloadable language packs.

Still:

* User initiated.
* Signed.
* Transparent.
* Offline after install.

---

# Build Phases

# Phase 1 — Foundation

## Deliverables

* Keyboard extension.
* Basic rendering.
* QWERTY layout.
* Input handling.
* Shift/delete/space.

## Exit Criteria

User can type reliably.

---

# Phase 2 — Suggestions

## Deliverables

* Autocorrect.
* Prediction bar.
* Dictionary.
* Learned words.

## Exit Criteria

Predictions feel usable.

---

# Phase 3 — Swipe Typing

## Deliverables

* Gesture recognition.
* Swipe decoder.
* Candidate ranking.

## Exit Criteria

Swipe typing works competitively.

---

# Phase 4 — Personalization

## Deliverables

* Local learning.
* Frequency ranking.
* Personal dictionary.

## Exit Criteria

Keyboard adapts over time.

---

# Phase 5 — Polish

## Deliverables

* Animations.
* Themes.
* Accessibility.
* Performance optimization.

## Exit Criteria

Production-quality UX.

---

# Phase 6 — Experimental ML

## Deliverables

* Tiny local transformer.
* Contextual prediction.
* Better next-word prediction.

## Exit Criteria

Improved prediction quality without major latency cost.

---

# Testing Strategy

## Unit Tests

Test:

* Tokenization.
* Prediction ranking.
* Gesture decoding.
* Layout logic.

## Integration Tests

Test:

* Keyboard lifecycle.
* App group storage.
* Settings sync.

## Performance Tests

Measure:

* Input latency.
* Memory usage.
* Battery impact.

## Real Device Testing

Must test on:

* Small iPhones.
* Pro Max devices.
* iPads.
* Older hardware.

---

# Suggested Development Order

## Week 1–2

* Keyboard extension.
* Basic rendering.
* Touch handling.

## Week 3–4

* Layout system.
* Suggestion bar.
* Autocorrect.

## Week 5–6

* Swipe engine prototype.
* Gesture tracking.

## Week 7–8

* Prediction ranking.
* Learned dictionary.

## Week 9–10

* Themes.
* Accessibility.
* Performance optimization.

---

# Recommended Open Source References

Use only for inspiration and architecture study.

## iOS

* KeyboardKit.
* Fleksy open examples.

## Android Reference Projects

* OpenBoard.
* FlorisBoard.
* AnySoftKeyboard.

Study:

* Gesture decoding.
* Prediction architecture.
* Layout systems.

Do NOT directly port Android UI assumptions.

---

# App Store Considerations

## Important

Apple heavily reviews keyboard apps.

## Must Have

* Clear privacy policy.
* Transparent permissions.
* Stable performance.
* No deceptive data collection.

## Avoid

* Crashes.
* Excessive memory use.
* Hidden networking.
* Misleading “AI” claims.

---

# Future Ideas

## Potential Advanced Features

* On-device speech-to-text.
* Handwriting input.
* Local multilingual translation.
* Federated learning (optional research only).
* AI rewrite tools fully local.
* Grammar correction.

---

# Definition of Done

The project is considered complete when:

* Typing feels native-quality.
* Swipe typing is reliable.
* Predictions are useful.
* No cloud dependency exists.
* Performance is competitive.
* Privacy guarantees are enforceable.
* The codebase is maintainable.
* The project is fully open source.

---

# Deliverables Checklist

## Required

* iOS app.
* Keyboard extension.
* Settings app.
* Prediction engine.
* Swipe typing.
* Offline dictionaries.
* Theme support.
* Accessibility support.
* Unit tests.
* Documentation.
* CI pipeline.
* Open-source license.
* Optional top number row.
* Long-press period key that reveals additional punctuation.
* Swipe/flick punctuation selection from the period key popup.

## Nice to Have

* Local transformer model.
* Plugin system.
* Community themes.
* Macro system.
* Advanced layouts.

---

# Recommended Initial MVP Scope

To avoid project failure from excessive complexity, the first public release should include ONLY:

* English QWERTY.
* Basic autocorrect.
* Local predictions.
* Swipe typing.
* Dark/light themes.
* Haptics.
* Emoji keyboard.
* Cursor swipe gesture.

Do NOT attempt:

* Cloud sync.
* Accounts.
* AI models.
* Online services.
* Plugin ecosystem.
