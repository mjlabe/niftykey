import Foundation
import SharedModels

public struct SwipePoint: Sendable {
    public let x: CGFloat
    public let y: CGFloat
    public let timestamp: TimeInterval

    public init(x: CGFloat, y: CGFloat, timestamp: TimeInterval) {
        self.x = x
        self.y = y
        self.timestamp = timestamp
    }
}

public struct SwipeCandidate: Sendable {
    public let word: String
    public let confidence: Double

    public init(word: String, confidence: Double) {
        self.word = word
        self.confidence = confidence
    }
}

/// Swipe typing decoder — Phase 3 implementation.
/// Uses spatial quantization and beam search to decode swipe paths into words.
public final class SwipeDecoder: @unchecked Sendable {
    private var currentPath: [SwipePoint] = []
    private var isActive: Bool = false

    public init() {}

    /// Begin a new swipe gesture
    public func beginSwipe(at point: SwipePoint) {
        currentPath = [point]
        isActive = true
    }

    /// Add a point to the current swipe path
    public func addPoint(_ point: SwipePoint) {
        guard isActive else { return }
        currentPath.append(point)
    }

    /// End the swipe and decode candidates
    public func endSwipe(keyPositions: [String: CGPoint]) -> [SwipeCandidate] {
        guard isActive else { return [] }
        isActive = false

        let nearKeys = estimateKeySequence(keyPositions: keyPositions)
        // Phase 3: implement beam search here
        _ = nearKeys

        currentPath = []
        return []
    }

    /// Cancel the current swipe
    public func cancelSwipe() {
        currentPath = []
        isActive = false
    }

    // MARK: - Private

    private func estimateKeySequence(keyPositions: [String: CGPoint]) -> [String] {
        guard currentPath.count >= 2 else { return [] }

        var keys: [String] = []
        let sampledPoints = samplePath(every: 20)

        for point in sampledPoints {
            if let nearest = findNearestKey(to: CGPoint(x: point.x, y: point.y), in: keyPositions) {
                if keys.last != nearest {
                    keys.append(nearest)
                }
            }
        }

        return keys
    }

    private func samplePath(every interval: Int) -> [SwipePoint] {
        guard currentPath.count > interval else { return currentPath }
        var sampled: [SwipePoint] = []
        for i in stride(from: 0, to: currentPath.count, by: interval) {
            sampled.append(currentPath[i])
        }
        if let last = currentPath.last {
            sampled.append(last)
        }
        return sampled
    }

    private func findNearestKey(to point: CGPoint, in positions: [String: CGPoint]) -> String? {
        var nearest: String?
        var minDist = CGFloat.greatestFiniteMagnitude
        for (key, pos) in positions {
            let dx = point.x - pos.x
            let dy = point.y - pos.y
            let dist = dx * dx + dy * dy
            if dist < minDist {
                minDist = dist
                nearest = key
            }
        }
        return nearest
    }
}
