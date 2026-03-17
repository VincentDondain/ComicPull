import XCTest

final class CollectionFlowUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testCollectionTabExists() throws {
        let tab = app.tabBars.buttons["Collection"]
        XCTAssertTrue(tab.exists)
        tab.tap()
        XCTAssertTrue(app.navigationBars["Collection"].exists)
    }
}
