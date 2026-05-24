import SwiftUI
import ThemeEngine

struct PunctuationPopupView: View {
    static let punctuations = ["!", "@", "#", ",", ".", "?"]

    let theme: KeyboardTheme
    let selectedIndex: Int?
    let anchorFrame: CGRect

    var body: some View {
        HStack(spacing: 1) {
            ForEach(Array(Self.punctuations.enumerated()), id: \.offset) { index, punct in
                Text(punct)
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
        .fixedSize()
        .offset(x: horizontalOffset)
    }

    private func isSelected(_ index: Int) -> Bool {
        selectedIndex == index
    }

    private var horizontalOffset: CGFloat {
        // If keyFrame hasn't been set yet, stay centered on the key
        guard anchorFrame.width > 0 else { return 0 }

        let popupWidth = CGFloat(Self.punctuations.count) * 37 + 8
        let halfPopup = popupWidth / 2
        let keyCenterX = anchorFrame.midX
        let screenWidth = UIScreen.main.bounds.width

        // Calculate how far left or right we need to shift so popup stays on screen
        let leftEdge = keyCenterX - halfPopup
        let rightEdge = keyCenterX + halfPopup

        if leftEdge < 4 {
            return -leftEdge + 4
        } else if rightEdge > screenWidth - 4 {
            return (screenWidth - 4) - rightEdge
        }
        return 0
    }
}
