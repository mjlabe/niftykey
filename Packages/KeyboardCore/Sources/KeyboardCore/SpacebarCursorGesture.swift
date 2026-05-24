import UIKit

public final class SpacebarCursorGesture {
    private var startPoint: CGPoint?
    private var lastOffset: Int = 0
    private let pointsPerCharacter: CGFloat = 10.0

    public var onCursorMove: ((Int) -> Void)?

    public init() {}

    public func began(at point: CGPoint) {
        startPoint = point
        lastOffset = 0
    }

    public func moved(to point: CGPoint) {
        guard let start = startPoint else { return }
        let deltaX = point.x - start.x
        let offset = Int(deltaX / pointsPerCharacter)
        let movement = offset - lastOffset
        if movement != 0 {
            onCursorMove?(movement)
            lastOffset = offset
        }
    }

    public func ended() {
        startPoint = nil
        lastOffset = 0
    }

    public var isActive: Bool {
        startPoint != nil
    }
}
