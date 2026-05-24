import Foundation
import SharedModels

@MainActor
public final class KeyboardState: ObservableObject {
    @Published public var mode: KeyboardMode = .letters
    @Published public var shiftState: ShiftState = .uppercased
    @Published public var suggestions: [String] = []
    @Published public var showNumberRow: Bool = false

    public var settings: KeyboardSettings

    public init(settings: KeyboardSettings) {
        self.settings = settings
        self.showNumberRow = settings.numberRowEnabled
    }

    public func toggleShift() {
        switch shiftState {
        case .lowercased:
            shiftState = .uppercased
        case .uppercased:
            shiftState = .lowercased
        case .capsLocked:
            shiftState = .lowercased
        }
    }

    public func enableCapsLock() {
        shiftState = .capsLocked
    }

    public func autoLowercase() {
        if shiftState == .uppercased {
            shiftState = .lowercased
        }
    }

    public func setAutoCapitalize(_ shouldCap: Bool) {
        if shouldCap && shiftState == .lowercased {
            shiftState = .uppercased
        }
    }

    public func switchToLetters() {
        mode = .letters
    }

    public func switchToNumbers() {
        mode = .numbers
    }

    public func switchToSymbols() {
        mode = .symbols
    }

    public func switchToEmoji() {
        mode = .emoji
    }

    public func toggleNumberRow() {
        showNumberRow.toggle()
        settings.numberRowEnabled = showNumberRow
    }

    public var currentLayout: KeyboardLayout {
        switch mode {
        case .letters:
            return LayoutProvider.qwerty
        case .numbers:
            return LayoutProvider.numbers
        case .symbols:
            return LayoutProvider.symbols
        case .emoji:
            return LayoutProvider.qwerty
        }
    }
}
