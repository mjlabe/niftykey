import Foundation

public struct KeyboardLayout: Sendable {
    public let rows: [[KeyDefinition]]
    public let numberRow: [KeyDefinition]?

    public init(rows: [[KeyDefinition]], numberRow: [KeyDefinition]? = nil) {
        self.rows = rows
        self.numberRow = numberRow
    }
}

public struct LayoutProvider: Sendable {
    public static let qwerty = makeQWERTY()
    public static let numbers = makeNumbers()
    public static let symbols = makeSymbols()

    private static func makeQWERTY() -> KeyboardLayout {
        let numberRow: [KeyDefinition] = "1234567890".map { char in
            KeyDefinition(id: "num_\(char)", primary: String(char), type: .number)
        }

        let row1: [KeyDefinition] = "qwertyuiop".map { char in
            KeyDefinition(id: "letter_\(char)", primary: String(char))
        }

        let row2: [KeyDefinition] = "asdfghjkl".map { char in
            KeyDefinition(id: "letter_\(char)", primary: String(char))
        }

        let row3: [KeyDefinition] = [
            KeyDefinition(id: "shift", primary: "⇧", widthWeight: 1.5, type: .shift)
        ] + "zxcvbnm".map { char in
            KeyDefinition(id: "letter_\(char)", primary: String(char))
        } + [
            KeyDefinition(id: "backspace", primary: "⌫", widthWeight: 1.5, type: .backspace)
        ]

        let row4: [KeyDefinition] = [
            KeyDefinition(id: "numbers", primary: "123", widthWeight: 1.0, type: .numeric),
            KeyDefinition(id: "emoji", primary: "☺\u{FE0E}", widthWeight: 1.0, type: .emoji),
            KeyDefinition(id: "space", primary: "space", widthWeight: 6.0, type: .space),
            KeyDefinition(id: "period", primary: ".", secondary: ",?!'\"", widthWeight: 1.0, type: .period),
            KeyDefinition(id: "return", primary: "return", widthWeight: 1.0, type: .returnKey)
        ]

        return KeyboardLayout(rows: [row1, row2, row3, row4], numberRow: numberRow)
    }

    private static func makeNumbers() -> KeyboardLayout {
        let row1: [KeyDefinition] = "1234567890".map { char in
            KeyDefinition(id: "numpad_\(char)", primary: String(char), type: .number)
        }

        let row2: [KeyDefinition] = "-/:;()$&@\"".map { char in
            KeyDefinition(id: "sym_\(char.asciiValue ?? 0)", primary: String(char), type: .special)
        }

        let row3: [KeyDefinition] = [
            KeyDefinition(id: "symbols", primary: "#+=", widthWeight: 1.5, type: .symbols)
        ] + ".,?!'".map { char in
            KeyDefinition(id: "punct_\(char.asciiValue ?? 0)", primary: String(char), type: .special)
        } + [
            KeyDefinition(id: "backspace_num", primary: "⌫", widthWeight: 1.5, type: .backspace)
        ]

        let row4: [KeyDefinition] = [
            KeyDefinition(id: "letters", primary: "ABC", widthWeight: 1.0, type: .numeric),
            KeyDefinition(id: "emoji_num", primary: "☺\u{FE0E}", widthWeight: 0.8, type: .emoji),
            KeyDefinition(id: "space_num", primary: "space", widthWeight: 6.4, type: .space),
            KeyDefinition(id: "period_num", primary: ".", widthWeight: 0.8, type: .period),
            KeyDefinition(id: "return_num", primary: "return", widthWeight: 1.0, type: .returnKey)
        ]

        return KeyboardLayout(rows: [row1, row2, row3, row4])
    }

    private static func makeSymbols() -> KeyboardLayout {
        let row1: [KeyDefinition] = "[]{}#%^*+=".map { char in
            KeyDefinition(id: "sym2_\(char.asciiValue ?? 0)", primary: String(char), type: .special)
        }

        let row2: [KeyDefinition] = "_\\|~<>€£¥•".map { char in
            KeyDefinition(id: "sym3_\(char)", primary: String(char), type: .special)
        }

        let row3: [KeyDefinition] = [
            KeyDefinition(id: "numbers_back", primary: "123", widthWeight: 1.5, type: .symbols)
        ] + ".,?!'".map { char in
            KeyDefinition(id: "punct2_\(char.asciiValue ?? 0)", primary: String(char), type: .special)
        } + [
            KeyDefinition(id: "backspace_sym", primary: "⌫", widthWeight: 1.5, type: .backspace)
        ]

        let row4: [KeyDefinition] = [
            KeyDefinition(id: "letters_back", primary: "ABC", widthWeight: 1.0, type: .numeric),
            KeyDefinition(id: "emoji_sym", primary: "☺\u{FE0E}", widthWeight: 0.8, type: .emoji),
            KeyDefinition(id: "space_sym", primary: "space", widthWeight: 6.4, type: .space),
            KeyDefinition(id: "period_sym", primary: ".", widthWeight: 0.8, type: .period),
            KeyDefinition(id: "return_sym", primary: "return", widthWeight: 1.0, type: .returnKey)
        ]

        return KeyboardLayout(rows: [row1, row2, row3, row4])
    }
}
