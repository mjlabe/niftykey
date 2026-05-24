import UIKit

public final class HapticEngine: @unchecked Sendable {
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionGenerator = UISelectionFeedbackGenerator()

    public var isEnabled: Bool = true

    public init() {
        lightGenerator.prepare()
        selectionGenerator.prepare()
    }

    public func prepare() {
        lightGenerator.prepare()
        selectionGenerator.prepare()
    }

    public func keyTap() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred()
        lightGenerator.prepare()
    }

    public func modifierTap() {
        guard isEnabled else { return }
        mediumGenerator.impactOccurred()
        mediumGenerator.prepare()
    }

    public func deleteTap() {
        guard isEnabled else { return }
        rigidGenerator.impactOccurred()
        rigidGenerator.prepare()
    }

    public func selectionChanged() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
}
