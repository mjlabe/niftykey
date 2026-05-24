import UIKit
import SharedModels

public protocol TextDocumentProxyProvider: AnyObject {
    var documentProxy: UITextDocumentProxy { get }
}

public final class InputCoordinator {
    private weak var proxyProvider: TextDocumentProxyProvider?
    private var lastSpaceTimestamp: Date?
    private let doubleSpaceThreshold: TimeInterval = 0.3

    public var settings: KeyboardSettings

    public init(proxyProvider: TextDocumentProxyProvider?, settings: KeyboardSettings) {
        self.proxyProvider = proxyProvider
        self.settings = settings
    }

    private var proxy: UITextDocumentProxy? {
        proxyProvider?.documentProxy
    }

    // MARK: - Text Input

    public func insertCharacter(_ char: String) {
        proxy?.insertText(char)
    }

    public func insertSpace() -> Bool {
        if settings.doubleSpacePeriodEnabled, shouldInsertPeriod() {
            proxy?.deleteBackward()
            proxy?.insertText(". ")
            lastSpaceTimestamp = nil
            return true
        }
        proxy?.insertText(" ")
        lastSpaceTimestamp = Date()
        return false
    }

    public func deleteBackward() {
        proxy?.deleteBackward()
    }

    public func deleteWord() {
        guard let context = proxy?.documentContextBeforeInput else { return }
        let trimmed = context.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            proxy?.deleteBackward()
            return
        }

        var deleteCount = 0
        var foundNonSpace = false
        for char in context.reversed() {
            if char == " " || char == "\n" {
                if foundNonSpace { break }
            } else {
                foundNonSpace = true
            }
            deleteCount += 1
        }

        for _ in 0..<deleteCount {
            proxy?.deleteBackward()
        }
    }

    public func insertReturn() {
        proxy?.insertText("\n")
    }

    // MARK: - Cursor Movement

    public func moveCursor(offset: Int) {
        proxy?.adjustTextPosition(byCharacterOffset: offset)
    }

    // MARK: - Auto Capitalization

    public func shouldAutoCapitalize() -> Bool {
        guard settings.autoCapsEnabled else { return false }
        guard let context = proxy?.documentContextBeforeInput else { return true }
        if context.isEmpty { return true }

        let trimmed = context.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return true }

        let lastChar = trimmed.last
        return lastChar == "." || lastChar == "!" || lastChar == "?" || lastChar == "\n"
    }

    // MARK: - Double Space Period

    private func shouldInsertPeriod() -> Bool {
        guard let lastSpace = lastSpaceTimestamp else { return false }
        let elapsed = Date().timeIntervalSince(lastSpace)
        guard elapsed < doubleSpaceThreshold else { return false }

        guard let context = proxy?.documentContextBeforeInput else { return false }
        guard context.hasSuffix(" ") else { return false }

        let beforeSpace = context.dropLast()
        guard let lastChar = beforeSpace.last else { return false }
        return lastChar.isLetter || lastChar.isNumber
    }

    // MARK: - Context

    public var contextBeforeInput: String? {
        proxy?.documentContextBeforeInput
    }

    public var contextAfterInput: String? {
        proxy?.documentContextAfterInput
    }
}
