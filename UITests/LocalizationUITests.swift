import XCTest

final class LocalizationUITests: XCTestCase {
    @MainActor
    func testChineseAndEnglishSettings() throws {
        continueAfterFailure = false
        for (language, general, clipboard, search) in [
            ("zh-Hans", "通用", "剪贴板", "搜索"),
            ("en", "General", "Clipboard", "Search")
        ] {
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", language]
            app.launch()
            app.activate()
            app.typeKey(",", modifierFlags: .command)
            let settings = app.windows.firstMatch
            XCTAssertTrue(settings.waitForExistence(timeout: 20), "Settings must open in \(language)")
            XCTAssertTrue(settings.staticTexts[general].firstMatch.exists)
            let clipboardRow = settings.staticTexts[clipboard].firstMatch
            XCTAssertTrue(clipboardRow.exists)
            clipboardRow.click()
            let enabled = language == "zh-Hans" ? "启用剪贴板历史" : "Enable Clipboard History"
            XCTAssertTrue(settings.staticTexts[enabled].waitForExistence(timeout: 10))
            capture(settings, named: "\(language)-clipboard")
            let field = settings.searchFields.firstMatch
            XCTAssertTrue(field.exists, "\(search) field must be accessible")
            field.click()
            field.typeText(clipboard)
            XCTAssertTrue(settings.staticTexts[clipboard].firstMatch.waitForExistence(timeout: 10))
            capture(settings, named: "\(language)-settings-search")
            if language == "zh-Hans" {
                field.click()
                field.typeKey("a", modifierFlags: .command)
                field.typeText("Clipboard")
                XCTAssertTrue(settings.staticTexts[clipboard].firstMatch.waitForExistence(timeout: 10))
                capture(settings, named: "zh-Hans-english-search")
            }
            app.terminate()
        }
    }

    @MainActor
    private func capture(_ element: XCUIElement, named name: String) {
        let attachment = XCTAttachment(screenshot: element.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
