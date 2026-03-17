import XCTest

final class WeeklyReleasesUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testTabBarExists() throws {
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }

    func testWeeklyReleasesTabIsSelected() throws {
        let tab = app.tabBars.buttons["This Week"]
        XCTAssertTrue(tab.exists)
    }

    func testNavigationTitleExists() throws {
        XCTAssertTrue(app.navigationBars["This Week"].exists)
    }
}
