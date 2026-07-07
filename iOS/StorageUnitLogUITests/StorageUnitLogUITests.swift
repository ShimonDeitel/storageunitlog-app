import XCTest

final class StorageUnitLogUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_addEntry_appearsInList() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let field = app.textFields["entryPrimaryField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("UI Test Entry")
        app.buttons["entrySaveButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 5))
    }

    func test_freeLimit_triggersPaywall() throws {
        let app = XCUIApplication()
        app.launch()
        for i in 0..<12 {
            let addButton = app.buttons["addEntryButton"]
            addButton.tap()
            let field = app.textFields["entryPrimaryField"]
            if field.waitForExistence(timeout: 3) {
                field.tap()
                field.typeText("Entry \(i)")
                app.buttons["entrySaveButton"].tap()
            } else {
                break
            }
        }
        XCTAssertTrue(app.buttons["paywallPurchaseButton"].waitForExistence(timeout: 5) ||
                      app.buttons["restorePurchasesButton"].waitForExistence(timeout: 5))
    }

    func test_keyboardDismiss_onTapOutside() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let field = app.textFields["entryPrimaryField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("Dismiss Test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts.firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }
}
