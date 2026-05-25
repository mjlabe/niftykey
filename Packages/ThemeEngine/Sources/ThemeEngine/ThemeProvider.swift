import SwiftUI

extension Color {
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

public final class ThemeProvider: ObservableObject, @unchecked Sendable {
    @Published public var currentTheme: KeyboardTheme
    
    private var customBackgroundColor: Color?
    private var currentColorScheme: ColorScheme = .light

    public static let shared = ThemeProvider()

    private init() {
        self.currentTheme = ThemeProvider.light
    }

    public func applyTheme(for colorScheme: ColorScheme) {
        currentColorScheme = colorScheme
        if let customColor = customBackgroundColor {
            currentTheme = Self.createTheme(from: customColor, colorScheme: colorScheme)
        } else {
            currentTheme = colorScheme == .dark ? ThemeProvider.dark : ThemeProvider.light
        }
    }
    
    public func setCustomBackgroundColor(_ color: Color?) {
        customBackgroundColor = color
        if let color = color {
            currentTheme = Self.createTheme(from: color, colorScheme: currentColorScheme)
        } else {
            currentTheme = currentColorScheme == .dark ? ThemeProvider.dark : ThemeProvider.light
        }
    }
    
    public func setCustomBackgroundColor(red: Double, green: Double, blue: Double) {
        let color = Color(red: red, green: green, blue: blue)
        setCustomBackgroundColor(color)
    }
    
    private static func createTheme(from backgroundColor: Color, colorScheme: ColorScheme) -> KeyboardTheme {
        let components = backgroundColor.rgbComponents
        
        let lighterKeyColor = Color(
            red: min(1.0, components.red + (1.0 - components.red) * 0.6),
            green: min(1.0, components.green + (1.0 - components.green) * 0.6),
            blue: min(1.0, components.blue + (1.0 - components.blue) * 0.6)
        )
        
        let specialKeyColor = Color(
            red: min(1.0, components.red + (1.0 - components.red) * 0.3),
            green: min(1.0, components.green + (1.0 - components.green) * 0.3),
            blue: min(1.0, components.blue + (1.0 - components.blue) * 0.3)
        )
        
        let pressedKeyColor = Color(
            red: min(1.0, components.red + (1.0 - components.red) * 0.8),
            green: min(1.0, components.green + (1.0 - components.green) * 0.8),
            blue: min(1.0, components.blue + (1.0 - components.blue) * 0.8)
        )
        
        let luminance = 0.299 * components.red + 0.587 * components.green + 0.114 * components.blue
        let textColor: Color = luminance > 0.5 ? .black : .white
        let secondaryTextColor: Color = luminance > 0.5 
            ? Color(red: 0.3, green: 0.3, blue: 0.3) 
            : Color(red: 0.7, green: 0.7, blue: 0.7)
        
        return KeyboardTheme(
            name: "Custom",
            backgroundColor: backgroundColor,
            keyColor: lighterKeyColor,
            specialKeyColor: specialKeyColor,
            pressedKeyColor: pressedKeyColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            suggestionBarColor: backgroundColor,
            suggestionTextColor: textColor,
            borderColor: specialKeyColor,
            shadowColor: Color.black.opacity(0.3),
            keyCornerRadius: 5.0,
            keyShadowRadius: 1.0
        )
    }

    public static let light = KeyboardTheme(
        name: "Light",
        backgroundColor: Color(red: 0.82, green: 0.84, blue: 0.86),
        keyColor: .white,
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
        backgroundColor: Color(red: 0.11, green: 0.11, blue: 0.12),
        keyColor: Color(red: 0.26, green: 0.26, blue: 0.28),
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
