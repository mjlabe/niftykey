import SwiftUI

public final class ThemeProvider: ObservableObject, @unchecked Sendable {
    @Published public var currentTheme: KeyboardTheme

    public static let shared = ThemeProvider()

    private init() {
        self.currentTheme = ThemeProvider.light
    }

    public func applyTheme(for colorScheme: ColorScheme) {
        currentTheme = colorScheme == .dark ? ThemeProvider.dark : ThemeProvider.light
    }

    public static let light = KeyboardTheme(
        name: "Light",
        backgroundColor: Color(red: 1.0, green: 0.55, blue: 0.75),
        keyColor: Color(red: 1.0, green: 0.85, blue: 0.9),
        specialKeyColor: Color(red: 0.68, green: 0.71, blue: 0.74),
        pressedKeyColor: Color(red: 0.90, green: 0.91, blue: 0.92),
        textColor: .black,
        secondaryTextColor: Color(red: 0.4, green: 0.4, blue: 0.4),
        suggestionBarColor: Color(red: 0.82, green: 0.84, blue: 0.86),
        suggestionTextColor: .black,
        borderColor: Color(red: 0.75, green: 0.77, blue: 0.79),
        shadowColor: Color.black.opacity(0.3),
        keyCornerRadius: 5.0,
        keyShadowRadius: 1.0
    )

    public static let dark = KeyboardTheme(
        name: "Dark",
        backgroundColor: Color(red: 1.0, green: 0.55, blue: 0.75),
        keyColor: Color(red: 1.0, green: 0.85, blue: 0.9),
        specialKeyColor: Color(red: 0.17, green: 0.17, blue: 0.18),
        pressedKeyColor: Color(red: 0.35, green: 0.35, blue: 0.37),
        textColor: .white,
        secondaryTextColor: Color(red: 0.7, green: 0.7, blue: 0.7),
        suggestionBarColor: Color(red: 0.11, green: 0.11, blue: 0.12),
        suggestionTextColor: .white,
        borderColor: Color(red: 0.2, green: 0.2, blue: 0.22),
        shadowColor: Color.black.opacity(0.5),
        keyCornerRadius: 5.0,
        keyShadowRadius: 0.5
    )

    public static let amoled = KeyboardTheme(
        name: "AMOLED",
        backgroundColor: .black,
        keyColor: Color(red: 0.12, green: 0.12, blue: 0.12),
        specialKeyColor: Color(red: 0.08, green: 0.08, blue: 0.08),
        pressedKeyColor: Color(red: 0.2, green: 0.2, blue: 0.2),
        textColor: .white,
        secondaryTextColor: Color(red: 0.6, green: 0.6, blue: 0.6),
        suggestionBarColor: .black,
        suggestionTextColor: .white,
        borderColor: Color(red: 0.15, green: 0.15, blue: 0.15),
        shadowColor: .clear,
        keyCornerRadius: 5.0,
        keyShadowRadius: 0.0
    )
}
