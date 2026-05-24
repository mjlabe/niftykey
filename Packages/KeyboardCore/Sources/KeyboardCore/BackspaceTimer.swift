import Foundation

@MainActor
public final class BackspaceTimer {
    private var timer: Timer?
    private var deleteAction: (() -> Void)?
    private var repeatCount: Int = 0

    private let initialDelay: TimeInterval = 0.4
    private let repeatInterval: TimeInterval = 0.07
    private let wordDeleteThreshold: Int = 20

    public var onDeleteCharacter: (() -> Void)?
    public var onDeleteWord: (() -> Void)?

    public init() {}

    public func start() {
        repeatCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: initialDelay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.beginRepeating()
            }
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        repeatCount = 0
    }

    private func beginRepeating() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: repeatInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.repeatCount += 1
                if let self = self, self.repeatCount > self.wordDeleteThreshold {
                    self.onDeleteWord?()
                } else {
                    self?.onDeleteCharacter?()
                }
            }
        }
    }
}
