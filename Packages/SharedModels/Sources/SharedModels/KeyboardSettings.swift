import Foundation

public struct KeyboardSettings: Sendable {
    public var hapticFeedbackEnabled: Bool
    public var soundFeedbackEnabled: Bool
    public var autocorrectEnabled: Bool
    public var predictionsEnabled: Bool
    public var swipeTypingEnabled: Bool
    public var numberRowEnabled: Bool
    public var doubleSpacePeriodEnabled: Bool
    public var autoCapsEnabled: Bool
    public var longPressDelay: Double
    public var customBackgroundColorRed: Double?
    public var customBackgroundColorGreen: Double?
    public var customBackgroundColorBlue: Double?

    public init(
        hapticFeedbackEnabled: Bool = true,
        soundFeedbackEnabled: Bool = false,
        autocorrectEnabled: Bool = true,
        predictionsEnabled: Bool = true,
        swipeTypingEnabled: Bool = true,
        numberRowEnabled: Bool = false,
        doubleSpacePeriodEnabled: Bool = true,
        autoCapsEnabled: Bool = true,
        longPressDelay: Double = 0.10,
        customBackgroundColorRed: Double? = nil,
        customBackgroundColorGreen: Double? = nil,
        customBackgroundColorBlue: Double? = nil
    ) {
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.soundFeedbackEnabled = soundFeedbackEnabled
        self.autocorrectEnabled = autocorrectEnabled
        self.predictionsEnabled = predictionsEnabled
        self.swipeTypingEnabled = swipeTypingEnabled
        self.numberRowEnabled = numberRowEnabled
        self.doubleSpacePeriodEnabled = doubleSpacePeriodEnabled
        self.autoCapsEnabled = autoCapsEnabled
        self.longPressDelay = longPressDelay
        self.customBackgroundColorRed = customBackgroundColorRed
        self.customBackgroundColorGreen = customBackgroundColorGreen
        self.customBackgroundColorBlue = customBackgroundColorBlue
    }

    private static let suiteName = "group.com.niftykey.shared"

    public static func load() -> KeyboardSettings {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return KeyboardSettings()
        }
        return KeyboardSettings(
            hapticFeedbackEnabled: defaults.object(forKey: "hapticFeedback") as? Bool ?? true,
            soundFeedbackEnabled: defaults.object(forKey: "soundFeedback") as? Bool ?? false,
            autocorrectEnabled: defaults.object(forKey: "autocorrect") as? Bool ?? true,
            predictionsEnabled: defaults.object(forKey: "predictions") as? Bool ?? true,
            swipeTypingEnabled: defaults.object(forKey: "swipeTyping") as? Bool ?? true,
            numberRowEnabled: defaults.object(forKey: "numberRow") as? Bool ?? false,
            doubleSpacePeriodEnabled: defaults.object(forKey: "doubleSpacePeriod") as? Bool ?? true,
            autoCapsEnabled: defaults.object(forKey: "autoCaps") as? Bool ?? true,
            longPressDelay: defaults.object(forKey: "longPressDelay") as? Double ?? 0.10,
            customBackgroundColorRed: defaults.object(forKey: "customBackgroundColorRed") as? Double,
            customBackgroundColorGreen: defaults.object(forKey: "customBackgroundColorGreen") as? Double,
            customBackgroundColorBlue: defaults.object(forKey: "customBackgroundColorBlue") as? Double
        )
    }

    public func save() {
        guard let defaults = UserDefaults(suiteName: KeyboardSettings.suiteName) else { return }
        defaults.set(hapticFeedbackEnabled, forKey: "hapticFeedback")
        defaults.set(soundFeedbackEnabled, forKey: "soundFeedback")
        defaults.set(autocorrectEnabled, forKey: "autocorrect")
        defaults.set(predictionsEnabled, forKey: "predictions")
        defaults.set(swipeTypingEnabled, forKey: "swipeTyping")
        defaults.set(numberRowEnabled, forKey: "numberRow")
        defaults.set(doubleSpacePeriodEnabled, forKey: "doubleSpacePeriod")
        defaults.set(autoCapsEnabled, forKey: "autoCaps")
        defaults.set(longPressDelay, forKey: "longPressDelay")
        if let red = customBackgroundColorRed,
           let green = customBackgroundColorGreen,
           let blue = customBackgroundColorBlue {
            defaults.set(red, forKey: "customBackgroundColorRed")
            defaults.set(green, forKey: "customBackgroundColorGreen")
            defaults.set(blue, forKey: "customBackgroundColorBlue")
        } else {
            defaults.removeObject(forKey: "customBackgroundColorRed")
            defaults.removeObject(forKey: "customBackgroundColorGreen")
            defaults.removeObject(forKey: "customBackgroundColorBlue")
        }
    }
}
