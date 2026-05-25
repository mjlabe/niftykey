import SwiftUI
import SharedModels
import ThemeEngine

struct KeyGridView: View {
    let layout: KeyboardLayout
    let shiftState: ShiftState
    let showNumberRow: Bool
    let theme: KeyboardTheme
    let longPressDelay: Double
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
        GeometryReader { geometry in
            let letterKeyWidth = calculateLetterKeyWidth(availableWidth: geometry.size.width)
            
            VStack(spacing: rowSpacing) {
                if showNumberRow, let numberRow = layout.numberRow {
                    keyRow(numberRow, letterKeyWidth: letterKeyWidth, availableWidth: geometry.size.width)
                }

                ForEach(Array(layout.rows.enumerated()), id: \.offset) { _, row in
                    keyRow(row, letterKeyWidth: letterKeyWidth, availableWidth: geometry.size.width)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
    }

    private func calculateLetterKeyWidth(availableWidth: CGFloat) -> CGFloat {
        var allRows = layout.rows
        if let numberRow = layout.numberRow {
            allRows.insert(numberRow, at: 0)
        }
        
        var maxLetterCount = 0
        for row in allRows {
            let letterCount = row.filter { $0.type == .character || $0.type == .number }.count
            maxLetterCount = max(maxLetterCount, letterCount)
        }
        
        guard maxLetterCount > 0 else { return 0 }
        
        let totalSpacing = keySpacing * CGFloat(maxLetterCount - 1)
        return (availableWidth - totalSpacing) / CGFloat(maxLetterCount)
    }
    
    private func calculateKeyWidth(for key: KeyDefinition, letterKeyWidth: CGFloat, availableWidth: CGFloat, keys: [KeyDefinition]) -> CGFloat {
        if key.type == .character || key.type == .number {
            return letterKeyWidth
        }
        
        let letterKeys = keys.filter { $0.type == .character || $0.type == .number }
        let specialKeys = keys.filter { $0.type != .character && $0.type != .number }
        
        let totalLetterWidth = CGFloat(letterKeys.count) * letterKeyWidth
        let totalLetterSpacing = CGFloat(max(0, letterKeys.count - 1)) * keySpacing
        let totalSpecialSpacing = CGFloat(specialKeys.count) * keySpacing
        
        let remainingWidth = availableWidth - totalLetterWidth - totalLetterSpacing - totalSpecialSpacing
        let totalSpecialWeight = specialKeys.reduce(CGFloat(0)) { $0 + $1.widthWeight }
        
        if totalSpecialWeight > 0 {
            return (remainingWidth / totalSpecialWeight) * key.widthWeight
        }
        return letterKeyWidth
    }
    
    @ViewBuilder
    private func keyRow(_ keys: [KeyDefinition], letterKeyWidth: CGFloat, availableWidth: CGFloat) -> some View {
        HStack(spacing: keySpacing) {
            ForEach(keys) { key in
                KeyView(
                    key: key,
                    shiftState: shiftState,
                    theme: theme,
                    longPressDelay: longPressDelay,
                    onTap: { onKeyTap(key) },
                    onLongPress: { onKeyLongPress(key) },
                    onRelease: { onKeyRelease(key) },
                    onSpacebarDragBegan: onSpacebarDragBegan,
                    onSpacebarDragMoved: onSpacebarDragMoved,
                    onSpacebarDragEnded: onSpacebarDragEnded,
                    onNextKeyboard: onNextKeyboard,
                    onAlternateChar: onAlternateChar
                )
                .frame(width: calculateKeyWidth(for: key, letterKeyWidth: letterKeyWidth, availableWidth: availableWidth, keys: keys), height: 42)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 42)
    }
}
