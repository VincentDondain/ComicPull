import XCTest

final class ComicDetailUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testSearchTabNavigation() throws {
        let tab = app.tabBars.buttons["Search"]
        XCTAssertTrue(tab.exists)
        tab.tap()
        XCTAssertTrue(app.navigationBars["Search"].exists)
    }

    func testRecommendationsTabNavigation() throws {
        let tab = app.tabBars.buttons["For You"]
        XCTAssertTrue(tab.exists)
        tab.tap()
        XCTAssertTrue(app.navigationBars["For You"].exists)
    }
}
