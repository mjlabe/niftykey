import SwiftUI
import SharedModels

struct SettingsView: View {
    @State private var settings = KeyboardSettings.load()
    @State private var showingResetAlert = false

    var body: some View {
        NavigationStack {
            List {
                setupSection
                typingSection
                feedbackSection
                appearanceSection
                privacySection
                aboutSection
            }
            .navigationTitle("NiftyKey")
            .onChange(of: settings.hapticFeedbackEnabled) { _ in settings.save() }
            .onChange(of: settings.soundFeedbackEnabled) { _ in settings.save() }
            .onChange(of: settings.autocorrectEnabled) { _ in settings.save() }
            .onChange(of: settings.predictionsEnabled) { _ in settings.save() }
            .onChange(of: settings.swipeTypingEnabled) { _ in settings.save() }
            .onChange(of: settings.numberRowEnabled) { _ in settings.save() }
            .onChange(of: settings.doubleSpacePeriodEnabled) { _ in settings.save() }
            .onChange(of: settings.autoCapsEnabled) { _ in settings.save() }
            .onChange(of: settings.longPressDelay) { _ in settings.save() }
        }
    }

    // MARK: - Sections

    private var setupSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Label("Setup Instructions", systemImage: "keyboard")
                    .font(.headline)

                Text("1. Open Settings → General → Keyboard")
                Text("2. Tap \"Keyboards\"")
                Text("3. Tap \"Add New Keyboard...\"")
                Text("4. Select \"NiftyKey\"")
                Text("5. Switch to NiftyKey when typing")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.vertical, 4)
        } header: {
            Text("Getting Started")
        }
    }

    private var typingSection: some View {
        Section {
            Toggle("Autocorrect", isOn: $settings.autocorrectEnabled)
            Toggle("Predictions", isOn: $settings.predictionsEnabled)
            Toggle("Swipe Typing", isOn: $settings.swipeTypingEnabled)
            Toggle("Double-Space Period", isOn: $settings.doubleSpacePeriodEnabled)
            Toggle("Auto Capitalization", isOn: $settings.autoCapsEnabled)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Long Press Delay")
                    Spacer()
                    Text(String(format: "%.2fs", settings.longPressDelay))
                        .foregroundColor(.secondary)
                }
                Slider(value: $settings.longPressDelay, in: 0.1...0.8, step: 0.05)
            }
        } header: {
            Text("Typing")
        }
    }

    private var feedbackSection: some View {
        Section {
            Toggle("Haptic Feedback", isOn: $settings.hapticFeedbackEnabled)
            Toggle("Sound Feedback", isOn: $settings.soundFeedbackEnabled)
        } header: {
            Text("Feedback")
        }
    }

    private var appearanceSection: some View {
        Section {
            Toggle("Number Row", isOn: $settings.numberRowEnabled)
        } header: {
            Text("Appearance")
        }
    }

    private var privacySection: some View {
        Section {
            Button("Clear Learned Words") {
                showingResetAlert = true
            }
            .foregroundColor(.red)
        } header: {
            Text("Privacy")
        } footer: {
            Text("NiftyKey never sends your keystrokes or data to any server. Everything stays on your device.")
        }
        .alert("Clear Learned Words?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                // Reset learned words
            }
        } message: {
            Text("This will remove all words the keyboard has learned from your typing. This cannot be undone.")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("License")
                Spacer()
                Text("MIT")
                    .foregroundColor(.secondary)
            }
            Link("Source Code", destination: URL(string: "https://github.com/niftykey/niftykey")!)
        } header: {
            Text("About")
        } footer: {
            Text("NiftyKey is free and open source software. No tracking, no ads, no cloud.")
        }
    }
}
