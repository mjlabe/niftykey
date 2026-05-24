import SwiftUI
import ThemeEngine

struct AlternateCharsPopupView: View {
    let characters: [String]
    let theme: KeyboardTheme
    let selectedIndex: Int?
    let anchorFrame: CGRect

    var body: some View {
        HStack(spacing: 1) {
            ForEach(Array(characters.enumerated()), id: \.offset) { index, char in
                Text(char)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(isSelected(index) ? theme.keyColor : theme.textColor)
                    .frame(width: 36, height: 42)
                    .background(isSelected(index) ? Color.accentColor : theme.keyColor)
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .background(theme.keyColor)
        .cornerRadius(8)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: -2)
        .position(
            x: clampedX,
            y: anchorFrame.minY - 28
        )
    }

    private func isSelected(_ index: Int) -> Bool {
        selectedIndex == index
    }

    private var clampedX: CGFloat {
        let popupWidth = CGFloat(characters.count) * 37 + 8
        let halfWidth = popupWidth / 2
        let rawX = anchorFrame.midX
        let screenWidth = UIScreen.main.bounds.width
        return min(max(rawX, halfWidth + 4), screenWidth - halfWidth - 4)
    }
}
