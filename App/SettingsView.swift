import SwiftUI
import SharedModels
#if canImport(UIKit)
import UIKit
#endif

private extension Color {
    var rgbComponents: (red: Double, green: Double, blue: Double) {
        #if canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (Double(red), Double(green), Double(blue))
        #else
        return (0.5, 0.5, 0.5)
        #endif
    }
}

struct SettingsView: View {
    @State private var settings = KeyboardSettings.load()
    @State private var showingResetAlert = false
    @State private var backgroundColor: Color = SettingsView.loadBackgroundColor()
    @State private var useCustomColor: Bool = SettingsView.hasCustomColor()
    
    private static func loadBackgroundColor() -> Color {
        let settings = KeyboardSettings.load()
        if let r = settings.customBackgroundColorRed,
           let g = settings.customBackgroundColorGreen,
           let b = settings.customBackgroundColorBlue {
            return Color(red: r, green: g, blue: b)
        }
        return Color(red: 0.8196078431, green: 0.8274509804, blue: 0.8509803922)
    }
    
    private static func hasCustomColor() -> Bool {
        let settings = KeyboardSettings.load()
        return settings.customBackgroundColorRed != nil
    }

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
            .onChange(of: settings.longPressDelayAlphanumeric) { _ in settings.save() }
            .onChange(of: settings.longPressDelayPunctuation) { _ in settings.save() }
            .onChange(of: backgroundColor) { _ in
                if useCustomColor {
                    saveBackgroundColor()
                }
            }
            .onChange(of: useCustomColor) { newValue in
                if newValue {
                    saveBackgroundColor()
                } else {
                    clearBackgroundColor()
                }
            }
        }
    }
    
    private func saveBackgroundColor() {
        let components = backgroundColor.rgbComponents
        settings.customBackgroundColorRed = components.red
        settings.customBackgroundColorGreen = components.green
        settings.customBackgroundColorBlue = components.blue
        settings.save()
    }
    
    private func clearBackgroundColor() {
        settings.customBackgroundColorRed = nil
        settings.customBackgroundColorGreen = nil
        settings.customBackgroundColorBlue = nil
        settings.save()
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
                    Text("Long Press Delay (Letters/Numbers)")
                    Spacer()
                    Text(String(format: "%.2fs", settings.longPressDelayAlphanumeric))
                        .foregroundColor(.secondary)
                }
                Slider(value: $settings.longPressDelayAlphanumeric, in: 0.1...0.8, step: 0.05)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Long Press Delay (Punctuation)")
                    Spacer()
                    Text(String(format: "%.2fs", settings.longPressDelayPunctuation))
                        .foregroundColor(.secondary)
                }
                Slider(value: $settings.longPressDelayPunctuation, in: 0.1...0.8, step: 0.05)
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
            
            Toggle("Custom Background Color", isOn: $useCustomColor)
            
            if useCustomColor {
                ColorPicker("Background Color", selection: $backgroundColor, supportsOpacity: false)
            }
        } header: {
            Text("Appearance")
        } footer: {
            if useCustomColor {
                Text("Keys will automatically use a lighter shade of your selected color.")
            }
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
