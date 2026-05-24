import XCTest
@testable import SwipeEngine

final class SwipeEngineTests: XCTestCase {
    func testSwipeDecoderInit() {
        let decoder = SwipeDecoder()
        let point = SwipePoint(x: 100, y: 50, timestamp: 0)
        decoder.beginSwipe(at: point)
        decoder.addPoint(SwipePoint(x: 120, y: 50, timestamp: 0.01))
        let results = decoder.endSwipe(keyPositions: [:])
        // Phase 3: will return actual candidates
        XCTAssertTrue(results.isEmpty)
    }

    func testCancelSwipe() {
        let decoder = SwipeDecoder()
        decoder.beginSwipe(at: SwipePoint(x: 0, y: 0, timestamp: 0))
        decoder.cancelSwipe()
        let results = decoder.endSwipe(keyPositions: [:])
        XCTAssertTrue(results.isEmpty)
    }
}
