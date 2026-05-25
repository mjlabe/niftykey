import SwiftUI
import SharedModels
import KeyboardCore
import ThemeEngine

struct KeyboardRootView: View {
    @ObservedObject var state: KeyboardState
    @ObservedObject var theme = ThemeProvider.shared

    let onKeyTap: (KeyDefinition) -> Void
    let onKeyLongPress: (KeyDefinition) -> Void
    let onKeyRelease: (KeyDefinition) -> Void
    let onSuggestionTap: (String) -> Void
    let onSpacebarDragBegan: (CGPoint) -> Void
    let onSpacebarDragMoved: (CGPoint) -> Void
    let onSpacebarDragEnded: () -> Void
    let onNextKeyboard: () -> Void
    var onEmojiTap: ((String) -> Void)?
    var onAlternateChar: ((String) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            if state.mode == .emoji {
                EmojiKeyboardView(
                    theme: theme.currentTheme,
                    onEmojiTap: { emoji in onEmojiTap?(emoji) },
                    onBackToLetters: { state.switchToLetters() }
                )
            } else {
                SuggestionBarView(
                    suggestions: state.suggestions,
                    theme: theme.currentTheme,
                    onTap: onSuggestionTap
                )

                KeyGridView(
                    layout: state.currentLayout,
                    shiftState: state.shiftState,
                    showNumberRow: state.showNumberRow,
                    theme: theme.currentTheme,
                    longPressDelay: state.settings.longPressDelay,
                    onKeyTap: onKeyTap,
                    onKeyLongPress: onKeyLongPress,
                    onKeyRelease: onKeyRelease,
                    onSpacebarDragBegan: onSpacebarDragBegan,
                    onSpacebarDragMoved: onSpacebarDragMoved,
                    onSpacebarDragEnded: onSpacebarDragEnded,
                    onNextKeyboard: onNextKeyboard,
                    onAlternateChar: onAlternateChar
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            theme.currentTheme.backgroundColor.ignoresSafeArea()
        }
        .coordinateSpace(name: "keyboard")
    }
}
