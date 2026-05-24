import SwiftUI
import ThemeEngine

struct KeyPopupView: View {
    let character: String
    let theme: KeyboardTheme
    let keyFrame: CGRect

    var body: some View {
        Text(character)
            .font(.system(size: 32, weight: .regular))
            .foregroundColor(theme.textColor)
            .frame(width: max(keyFrame.width + 8, 44), height: 52)
            .background(theme.keyColor)
            .cornerRadius(8)
            .shadow(color: theme.shadowColor, radius: 3, x: 0, y: -2)
            .position(
                x: keyFrame.midX,
                y: keyFrame.minY - 30
            )
    }
}
