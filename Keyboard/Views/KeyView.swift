import SwiftUI
import SharedModels
import ThemeEngine

struct KeyView: View {
    let key: KeyDefinition
    let shiftState: ShiftState
    let theme: KeyboardTheme
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onRelease: () -> Void
    let onSpacebarDragBegan: (CGPoint) -> Void
    let onSpacebarDragMoved: (CGPoint) -> Void
    let onSpacebarDragEnded: () -> Void
    let onNextKeyboard: () -> Void
    var onAlternateChar: ((String) -> Void)?

    @State private var isPressed = false
    @State private var showPopup = false
    @State private var showAlternates = false
    @State private var alternateSelectedIndex: Int? = nil
    @State private var showPunctuation = false
    @State private var punctuationSelectedIndex: Int? = nil
    @State private var keyFrame: CGRect = .zero

    private var displayText: String {
        switch key.type {
        case .character:
            return shiftState.isUppercased ? key.primary.uppercased() : key.primary
        case .space:
            return ""
        case .returnKey:
            return "return"
        default:
            return key.primary
        }
    }

    private var keyBackgroundColor: Color {
        if isPressed {
            return theme.pressedKeyColor
        }
        return key.isModifier ? theme.specialKeyColor : theme.keyColor
    }

    private var fontSize: CGFloat {
        switch key.type {
        case .character, .number:
            return 22
        case .special:
            return 20
        case .returnKey, .numeric, .symbols:
            return 15
        default:
            return 18
        }
    }

    private var keyHeight: CGFloat {
        42
    }

    private var alternates: [String] {
        AlternateCharacters.alternates(for: key.primary) ?? []
    }

    var body: some View {
        Group {
            if key.type == .globe {
                globeKeyContent
            } else if key.type == .space {
                spacebarContent
            } else {
                standardKeyContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(keyBackgroundColor)
        .cornerRadius(theme.keyCornerRadius)
        .shadow(color: theme.shadowColor, radius: theme.keyShadowRadius, x: 0, y: 1)
        .overlay(popupOverlay, alignment: .top)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(key.isModifier ? .isButton : [.isButton, .isKeyboardKey])
    }

    // MARK: - Popup Overlay

    @ViewBuilder
    private var popupOverlay: some View {
        if showPunctuation {
            PunctuationPopupView(
                theme: theme,
                selectedIndex: punctuationSelectedIndex,
                anchorFrame: keyFrame
            )
            .offset(y: -52)
            .zIndex(100)
        } else if showAlternates && !alternates.isEmpty {
            AlternateCharsPopupView(
                characters: alternates,
                theme: theme,
                selectedIndex: alternateSelectedIndex,
                anchorFrame: keyFrame
            )
            .offset(y: -52)
            .zIndex(100)
        } else if showPopup && key.type == .character {
            Text(displayText)
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(theme.textColor)
                .frame(width: max(keyFrame.width + 8, 44), height: 52)
                .background(theme.keyColor)
                .cornerRadius(8)
                .shadow(color: theme.shadowColor, radius: 3, x: 0, y: -2)
                .offset(y: -52)
                .zIndex(99)
        }
    }

    // MARK: - Standard Key

    @ViewBuilder
    private var standardKeyContent: some View {
        keyLabel
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        keyFrame = geo.frame(in: .global)
                    }
                }
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isPressed {
                            isPressed = true
                            showPopup = true
                        }
                        if showPunctuation {
                            let punctuations = PunctuationPopupView.punctuations
                            let dx = value.location.x - value.startLocation.x
                            let charWidth: CGFloat = 37
                            let startOffset = -CGFloat(punctuations.count) * charWidth / 2
                            let idx = Int((dx - startOffset) / charWidth)
                            if idx >= 0 && idx < punctuations.count {
                                if punctuationSelectedIndex != idx {
                                    punctuationSelectedIndex = idx
                                }
                            } else {
                                punctuationSelectedIndex = nil
                            }
                        } else if showAlternates && !alternates.isEmpty {
                            let dx = value.location.x - value.startLocation.x
                            let charWidth: CGFloat = 37
                            let startOffset = -CGFloat(alternates.count) * charWidth / 2
                            let idx = Int((dx - startOffset) / charWidth)
                            if idx >= 0 && idx < alternates.count {
                                if alternateSelectedIndex != idx {
                                    alternateSelectedIndex = idx
                                }
                            } else {
                                alternateSelectedIndex = nil
                            }
                        }
                    }
                    .onEnded { _ in
                        if showPunctuation, let idx = punctuationSelectedIndex {
                            let punctuations = PunctuationPopupView.punctuations
                            if idx < punctuations.count {
                                onAlternateChar?(punctuations[idx])
                            }
                        } else if showAlternates, let idx = alternateSelectedIndex, idx < alternates.count {
                            let char = shiftState.isUppercased
                                ? alternates[idx].uppercased()
                                : alternates[idx]
                            onAlternateChar?(char)
                        } else if !showAlternates && !showPunctuation {
                            onTap()
                        }
                        isPressed = false
                        showPopup = false
                        showAlternates = false
                        alternateSelectedIndex = nil
                        showPunctuation = false
                        punctuationSelectedIndex = nil
                        onRelease(key)
                    }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.35)
                    .onEnded { _ in
                        if key.type == .period {
                            showPunctuation = true
                            showPopup = false
                        } else if !alternates.isEmpty {
                            showAlternates = true
                            showPopup = false
                        }
                        onLongPress()
                    }
            )
    }

    // MARK: - Spacebar

    @ViewBuilder
    private var spacebarContent: some View {
        Text("space")
            .font(.system(size: 15))
            .foregroundColor(theme.secondaryTextColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        if !isPressed {
                            isPressed = true
                            onSpacebarDragBegan(value.startLocation)
                        }
                        onSpacebarDragMoved(value.location)
                    }
                    .onEnded { _ in
                        isPressed = false
                        onSpacebarDragEnded()
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        onTap()
                    }
            )
    }

    // MARK: - Globe

    @ViewBuilder
    private var globeKeyContent: some View {
        Button(action: onNextKeyboard) {
            Image(systemName: "globe")
                .font(.system(size: 18))
                .foregroundColor(theme.textColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Key Label

    @ViewBuilder
    private var keyLabel: some View {
        switch key.type {
        case .backspace:
            Image(systemName: "delete.left")
                .font(.system(size: 18))
                .foregroundColor(theme.textColor)
        case .shift:
            Image(systemName: shiftIconName)
                .font(.system(size: 18))
                .foregroundColor(theme.textColor)
        case .returnKey:
            Image(systemName: "return")
                .font(.system(size: 18))
                .foregroundColor(theme.textColor)
        case .emoji:
            Image(systemName: "face.smiling")
                .font(.system(size: 18))
                .foregroundColor(theme.textColor)
        default:
            Text(displayText)
                .font(.system(size: fontSize, weight: .regular, design: .default))
                .foregroundColor(theme.textColor)
        }
    }

    private var shiftIconName: String {
        switch shiftState {
        case .lowercased:
            return "shift"
        case .uppercased:
            return "shift.fill"
        case .capsLocked:
            return "capslock.fill"
        }
    }

    // MARK: - Accessibility

    private var accessibilityText: String {
        switch key.type {
        case .character:
            return displayText
        case .shift:
            switch shiftState {
            case .lowercased: return "Shift"
            case .uppercased: return "Shift on"
            case .capsLocked: return "Caps lock on"
            }
        case .backspace:
            return "Delete"
        case .space:
            return "Space"
        case .returnKey:
            return "Return"
        case .globe:
            return "Next keyboard"
        case .numeric:
            return "Numbers"
        case .symbols:
            return "Symbols"
        case .emoji:
            return "Emoji"
        case .period:
            return "Period"
        case .comma:
            return "Comma"
        case .number:
            return key.primary
        case .special:
            return key.primary
        }
    }

    private func onRelease(_ key: KeyDefinition) {
        onRelease()
    }
}
