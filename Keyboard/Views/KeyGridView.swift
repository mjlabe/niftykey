import SwiftUI
import SharedModels
import ThemeEngine

struct KeyGridView: View {
    let layout: KeyboardLayout
    let shiftState: ShiftState
    let showNumberRow: Bool
    let theme: KeyboardTheme
    let onKeyTap: (KeyDefinition) -> Void
    let onKeyLongPress: (KeyDefinition) -> Void
    let onKeyRelease: (KeyDefinition) -> Void
    let onSpacebarDragBegan: (CGPoint) -> Void
    let onSpacebarDragMoved: (CGPoint) -> Void
    let onSpacebarDragEnded: () -> Void
    let onNextKeyboard: () -> Void
    var onAlternateChar: ((String) -> Void)?

    private let rowSpacing: CGFloat = 8
    private let keySpacing: CGFloat = 4
    private let verticalPadding: CGFloat = 4
    private let horizontalPadding: CGFloat = 3

    var body: some View {
        VStack(spacing: rowSpacing) {
            if showNumberRow, let numberRow = layout.numberRow {
                keyRow(numberRow)
            }

            ForEach(Array(layout.rows.enumerated()), id: \.offset) { _, row in
                keyRow(row)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
    }

    @ViewBuilder
    private func keyRow(_ keys: [KeyDefinition]) -> some View {
        GeometryReader { geometry in
            let totalSpacing = keySpacing * CGFloat(keys.count - 1)
            let availableWidth = geometry.size.width - totalSpacing
            let totalWeight = keys.reduce(CGFloat(0)) { $0 + $1.widthWeight }

            HStack(spacing: keySpacing) {
                ForEach(keys) { key in
                    let keyWidth = availableWidth * (key.widthWeight / totalWeight)
                    KeyView(
                        key: key,
                        shiftState: shiftState,
                        theme: theme,
                        onTap: { onKeyTap(key) },
                        onLongPress: { onKeyLongPress(key) },
                        onRelease: { onKeyRelease(key) },
                        onSpacebarDragBegan: onSpacebarDragBegan,
                        onSpacebarDragMoved: onSpacebarDragMoved,
                        onSpacebarDragEnded: onSpacebarDragEnded,
                        onNextKeyboard: onNextKeyboard,
                        onAlternateChar: onAlternateChar
                    )
                    .frame(width: keyWidth)
                }
            }
        }
        .frame(height: 42)
    }
}
