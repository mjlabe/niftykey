# claude.md — LLM Engineering Guidelines for the Local-Only FOSS iOS Keyboard

## Purpose

This document defines the engineering rules, architectural constraints, coding standards, and implementation philosophy for all LLMs contributing to this repository.

The project is:

* A local-only iOS keyboard.
* Privacy-first.
* Open source.
* Swift-native.
* Optimized for extremely low latency.
* Inspired by Swiftly Keyboard UX patterns.

LLMs must prioritize:

1. Performance.
2. Stability.
3. Privacy.
4. Maintainability.
5. Native iOS behavior.

---

# Core Rules

## Rule 1 — Never Add Cloud Dependencies

This project is fully offline.

LLMs must NOT:

* Add analytics SDKs.
* Add telemetry.
* Add remote logging.
* Add cloud APIs.
* Add remote inference.
* Add user tracking.
* Add advertising frameworks.

No keystrokes may ever leave the device.

---

## Rule 2 — Prefer Native APIs

Prefer:

* UIKit
* CoreML
* NaturalLanguage
* CoreHaptics
* os.log
* Swift Concurrency
* Metal (only if proven necessary)

Avoid unnecessary third-party dependencies.

---

## Rule 3 — Typing Latency Is Critical

Keyboard UX is more important than feature count.

Any implementation that risks input lag should be rejected.

Targets:

* Key response under 16ms.
* Suggestion generation under 20ms.
* No dropped frames during typing.
* Stable 60fps rendering.

Prefer simpler algorithms if they reduce latency.

---

## Rule 4 — Hybrid UIKit + SwiftUI Architecture

The project should use a hybrid architecture.

UIKit acts as the system shell.
SwiftUI acts as the primary rendering layer.

Preferred structure:

```text
UIInputViewController (UIKit shell)
 ├── KeyboardCoordinator
 ├── InputProxyAdapter
 ├── GesturePipeline
 └── UIHostingController
      └── SwiftUI KeyboardRootView
           ├── KeyboardGrid
           ├── SuggestionBar
           ├── EmojiPanel
           ├── ThemeLayer
           └── PopupOverlays
```

UIKit responsibilities:

* UIInputViewController lifecycle
* textDocumentProxy integration
* System keyboard APIs
* Low-level gesture recognizers
* Input coordination
* Memory/lifecycle handling

SwiftUI responsibilities:

* Keyboard layout rendering
* Adaptive layouts
* Themes
* Visual state transitions
* Suggestion bar UI
* Emoji keyboard UI
* Popup overlays
* Key animations

SwiftUI is strongly encouraged for:

* Adaptive layouts
* State-driven keyboard modes
* Theme handling
* Accessibility adaptation
* Dynamic number row support
* iPad layout support

Do NOT attempt to bypass UIKit entirely.

textDocumentProxy and keyboard extension lifecycle management must remain inside UIKit.

---

## SwiftUI Performance Rules

SwiftUI performance mistakes can easily introduce keyboard lag.

LLMs must avoid:

* Large shared ObservableObjects.
* Full keyboard invalidation.
* Excessive view recomposition.
* Deep dependency chains.
* Expensive GeometryReader usage.
* Rebuilding entire grids during typing.

Prefer:

* Small isolated state.
* Immutable key models.
* Fine-grained updates.
* Lightweight view hierarchies.
* Stable identity for keys.

Bad pattern:

```swift
@EnvironmentObject var keyboardState
```

on every key view.

Preferred pattern:

```swift
KeyViewModel
```

or immutable value models.

SwiftUI should primarily manage:

* Composition
* Layout
* Visual styling
* Animations
* State-driven UI transitions

Heavy logic should remain outside SwiftUI.

---

## Gesture Architecture Rules

Performance-critical gesture handling may use UIKit recognizers directly.

Especially for:

* Swipe typing
* Cursor dragging
* High-frequency touch sampling
* Gesture velocity tracking
* Beam-search swipe decoding

Preferred architecture:

```text
UIKit Gesture Recognizers
→ GesturePipeline
→ Pure Swift decoding
→ SwiftUI rendering updates
```

Avoid placing heavy gesture decoding directly inside SwiftUI gesture modifiers.

SwiftUI gestures are acceptable for:

* Simple taps
* Basic long presses
* Non-critical interactions

UIKit gesture recognizers are preferred for latency-sensitive systems.

---

## Pure Swift Engine Rules

The following systems should remain mostly framework-independent:

* PredictionEngine
* SwipeEngine
* AutocorrectEngine
* Tokenizer
* Ranking systems
* Learned dictionary
* NLP systems

These systems should:

* Avoid UI coupling
* Be testable independently
* Avoid SwiftUI dependencies
* Prefer deterministic behavior
* Support benchmark testing

---

## Rule 5 — Full Access Must Not Be Required

The keyboard must function correctly without Full Access enabled.

Features that depend on Full Access:

* Must be optional.
* Must degrade gracefully.
* Must clearly explain why access is needed.

The core typing experience may NOT depend on network access.

---

# UX Requirements

## Mandatory MVP Behaviors

The following are REQUIRED:

* Double-space period.
* Auto capitalization.
* Optional top number row.
* Swipe typing.
* Cursor movement via spacebar swipe.
* Long-press period key popup.
* Swipe/flick punctuation selection.
* Haptic feedback.
* Dark mode.
* Emoji keyboard.

LLMs must preserve these features during refactors.

---

## Long-Press Period Key Behavior

The period key must:

* Support long press.
* Open a punctuation popup.
* Allow swipe/flick punctuation selection.
* Insert punctuation on release.
* Work one-handed.
* Have extremely low latency.

Preferred punctuation set:

* ,
* ?
* !
* :
* ;
* '
* "
* (
* )
* *

Implementation guidance:

* Use UILongPressGestureRecognizer.
* Use directional gesture tracking.
* Provide haptic confirmation.
* Avoid blocking the main thread.

---

# Architecture Rules

## Modular Design Required

The project should remain highly modular.

Preferred package layout:

```text
Packages/
├── KeyboardCore/
├── PredictionEngine/
├── SwipeEngine/
├── ThemeEngine/
├── SharedModels/
└── SettingsFeature/
```

LLMs should avoid:

* Massive view controllers.
* Global mutable state.
* Circular dependencies.
* Monolithic services.

---

## State Management

Prefer:

* Unidirectional data flow.
* Immutable models where possible.
* Explicit state transitions.
* Dependency injection.

Avoid:

* Hidden singleton state.
* Tight UI coupling.
* View-driven business logic.

---

## Concurrency Rules

Use:

* async/await
* Task
* Actors where appropriate

Avoid:

* Blocking the main thread
* Excessive DispatchQueue nesting
* Race conditions in prediction engines

Prediction and swipe decoding should run off the main thread whenever possible.

---

# Performance Rules

## Avoid Expensive Layout Work

Keyboard rendering happens constantly.

LLMs should:

* Minimize layout invalidation.
* Reuse views.
* Avoid deep view hierarchies.
* Avoid unnecessary animations.
* Avoid expensive blur effects.

---

## Memory Constraints

iOS keyboard extensions are memory constrained.

Guidelines:

* Prefer lightweight models.
* Avoid loading large dictionaries eagerly.
* Use lazy loading.
* Release unused caches aggressively.
* Avoid retaining large gesture histories.

Target:

* Under 60MB preferred.

---

## Battery Constraints

Avoid:

* Polling loops.
* Background timers.
* Continuous model inference.
* Excessive haptics.

Do work only when the user is actively typing.

---

# Prediction Engine Rules

## Offline Only

Predictions must always work locally.

Preferred stack:

1. Trie lookup
2. N-gram ranking
3. Lightweight local ML enhancement

Avoid giant models.

Small fast models are preferred over large accurate ones.

---

## Learned Dictionary Rules

The keyboard should locally learn:

* Names
* Slang
* Frequently typed words
* User corrections

Must support:

* Full reset
* Export
* Delete

Never upload learned data.

---

# Swipe Typing Rules

## Swipe Typing Must Feel Native

Gesture decoding should prioritize:

* Responsiveness
* Predictability
* Error tolerance
* Low latency

Preferred architecture:

```text
Touch Path
→ Key Estimation
→ Candidate Generation
→ Beam Search
→ Ranked Suggestions
```

LLMs should avoid overengineering early versions.

A simple fast decoder is preferred over a complex slow one.

---

# UI Rules

## Visual Philosophy

The keyboard should feel:

* Minimal
* Dense but readable
* Native to iOS
* Fast
* Predictable

Avoid:

* Excessive gradients
* Heavy shadows
* Flashy animations
* Visual clutter

---

## Animations

Animations should:

* Be subtle
* Be fast
* Never delay typing
* Never block input

Disable or reduce animations in:

* Low power mode
* Reduced motion accessibility mode

---

# Accessibility Rules

LLMs must preserve support for:

* VoiceOver
* Dynamic Type
* High contrast mode
* Reduced motion
* Large touch targets
* Switch Control

Accessibility regressions are considered serious bugs.

---

# Security Rules

## Never Log Sensitive Text

Do NOT:

* Log keystrokes
* Log full typed phrases
* Log passwords
* Persist sensitive fields

Use redaction when debugging input systems.

---

## Secure Fields

The keyboard must gracefully handle secure text entry.

LLMs must not attempt to bypass:

* Password field restrictions
* Apple privacy protections
* Secure input limitations

---

# Code Quality Rules

## Preferred Swift Style

Prefer:

* Small focused types
* Clear naming
* Explicit state
* Composition over inheritance
* Protocol-driven architecture

Avoid:

* Giant utility files
* Massive extensions
* Implicit side effects
* Force unwraps
* Emojis in code, comments, or output (use plain text only)

---

## Documentation

Public APIs should include:

* Purpose
* Parameters
* Threading expectations
* Performance considerations

Complex gesture systems should include architecture comments.

---

## Testing Expectations

Critical systems must have tests:

* Prediction ranking
* Gesture decoding
* Layout logic
* Cursor movement
* Autocorrect behavior
* Punctuation popup selection

Performance-sensitive code should include benchmarks where possible.

---

# Refactor Rules

When refactoring:

* Preserve keyboard feel.
* Preserve latency.
* Preserve gesture responsiveness.
* Preserve accessibility.
* Preserve offline guarantees.

Never trade typing responsiveness for architectural purity.

---

# Open Source Rules

## Project Requirements

The project should remain:

* Easy to build
* Easy to audit
* Easy to contribute to
* Easy to fork

Avoid unnecessary complexity.

---

## Dependency Rules

Before adding a dependency:

1. Verify it is actively maintained.
2. Verify license compatibility.
3. Verify it does not collect telemetry.
4. Verify performance impact.
5. Verify binary size impact.

Prefer no dependency whenever reasonable.

---

# App Store Rules

LLMs must avoid generating code that risks App Store rejection.

Avoid:

* Private APIs
* Hidden networking
* Misleading permission prompts
* Nonfunctional Full Access requirements
* Unstable memory usage

---

# Preferred Development Order

LLMs should prioritize work in this order:

1. Stable typing
2. Low latency
3. Prediction quality
4. Swipe typing
5. Accessibility
6. Theme polish
7. Advanced ML

Typing quality always comes before feature count.

---

# Definition of Success

A successful implementation:

* Feels close to native iOS quality.
* Never leaks user data.
* Works fully offline.
* Remains responsive under load.
* Is maintainable by open-source contributors.
* Has predictable gesture behavior.
* Supports fast one-handed typing.

If forced to choose between:

* fancy features
  or
* typing reliability

always choose typing reliability.
