import XCTest
@testable import SharedModels

final class SharedModelsTests: XCTestCase {
    func testKeyDefinitionIdentifiable() {
        let key = KeyDefinition(id: "letter_a", primary: "a")
        XCTAssertEqual(key.id, "letter_a")
        XCTAssertEqual(key.primary, "a")
        XCTAssertNil(key.secondary)
        XCTAssertEqual(key.widthWeight, 1.0)
        XCTAssertEqual(key.type, .character)
        XCTAssertFalse(key.isModifier)
    }

    func testModifierKeys() {
        let shift = KeyDefinition(id: "shift", primary: "⇧", type: .shift)
        XCTAssertTrue(shift.isModifier)
        
        let space = KeyDefinition(id: "space", primary: "space", type: .space)
        XCTAssertTrue(space.isModifier)
    }

    func testShiftState() {
        XCTAssertFalse(ShiftState.lowercased.isUppercased)
        XCTAssertTrue(ShiftState.uppercased.isUppercased)
        XCTAssertTrue(ShiftState.capsLocked.isUppercased)
    }

    func testQWERTYLayout() {
        let layout = LayoutProvider.qwerty
        XCTAssertEqual(layout.rows.count, 4)
        XCTAssertNotNil(layout.numberRow)
        XCTAssertEqual(layout.numberRow?.count, 10)
    }
}
