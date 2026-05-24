import XCTest
@testable import ThemeEngine

final class ThemeEngineTests: XCTestCase {
    func testLightThemeExists() {
        let theme = ThemeProvider.light
        XCTAssertEqual(theme.name, "Light")
        XCTAssertEqual(theme.keyCornerRadius, 5.0)
    }

    func testDarkThemeExists() {
        let theme = ThemeProvider.dark
        XCTAssertEqual(theme.name, "Dark")
    }

    func testAmoledThemeExists() {
        let theme = ThemeProvider.amoled
        XCTAssertEqual(theme.name, "AMOLED")
    }
}
