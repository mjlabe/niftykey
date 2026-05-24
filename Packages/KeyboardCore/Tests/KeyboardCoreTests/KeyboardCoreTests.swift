import XCTest
@testable import KeyboardCore
import SharedModels

final class KeyboardCoreTests: XCTestCase {
    @MainActor
    func testKeyboardStateShiftToggle() {
        let state = KeyboardState(settings: KeyboardSettings())
        XCTAssertEqual(state.shiftState, .uppercased)
        state.toggleShift()
        XCTAssertEqual(state.shiftState, .lowercased)
        state.toggleShift()
        XCTAssertEqual(state.shiftState, .uppercased)
    }

    @MainActor
    func testCapsLock() {
        let state = KeyboardState(settings: KeyboardSettings())
        state.enableCapsLock()
        XCTAssertEqual(state.shiftState, .capsLocked)
        state.toggleShift()
        XCTAssertEqual(state.shiftState, .lowercased)
    }

    @MainActor
    func testModeSwitching() {
        let state = KeyboardState(settings: KeyboardSettings())
        XCTAssertEqual(state.mode, .letters)
        state.switchToNumbers()
        XCTAssertEqual(state.mode, .numbers)
        state.switchToSymbols()
        XCTAssertEqual(state.mode, .symbols)
        state.switchToLetters()
        XCTAssertEqual(state.mode, .letters)
    }

    func testSpacebarCursorGesture() {
        let gesture = SpacebarCursorGesture()
        var totalMoved = 0
        gesture.onCursorMove = { offset in
            totalMoved += offset
        }
        gesture.began(at: CGPoint(x: 100, y: 50))
        gesture.moved(to: CGPoint(x: 130, y: 50))
        XCTAssertEqual(totalMoved, 3)
        gesture.ended()
        XCTAssertFalse(gesture.isActive)
    }
}
