import SwiftUI

public struct KeyboardTheme: Sendable, Equatable {
    public let name: String
    public let backgroundColor: Color
    public let keyColor: Color
    public let specialKeyColor: Color
    public let pressedKeyColor: Color
    public let textColor: Color
    public let secondaryTextColor: Color
    public let suggestionBarColor: Color
    public let suggestionTextColor: Color
    public let borderColor: Color
    public let shadowColor: Color
    public let keyCornerRadius: CGFloat
    public let keyShadowRadius: CGFloat

    public init(
        name: String,
        backgroundColor: Color,
        keyColor: Color,
        specialKeyColor: Color,
        pressedKeyColor: Color,
        textColor: Color,
        secondaryTextColor: Color,
        suggestionBarColor: Color,
        suggestionTextColor: Color,
        borderColor: Color,
        shadowColor: Color,
        keyCornerRadius: CGFloat = 5.0,
        keyShadowRadius: CGFloat = 1.0
    ) {
        self.name = name
        self.backgroundColor = backgroundColor
        self.keyColor = keyColor
        self.specialKeyColor = specialKeyColor
        self.pressedKeyColor = pressedKeyColor
        self.textColor = textColor
        self.secondaryTextColor = secondaryTextColor
        self.suggestionBarColor = suggestionBarColor
        self.suggestionTextColor = suggestionTextColor
        self.borderColor = borderColor
        self.shadowColor = shadowColor
        self.keyCornerRadius = keyCornerRadius
        self.keyShadowRadius = keyShadowRadius
    }
}
