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
            let recorder = language == "zh-Hans" ? "录制快捷键" : "Record Hotkey"
            XCTAssertTrue(settings.staticTexts[recorder].firstMatch.exists)
            let hint = language == "zh-Hans"
                ? "按回车键执行此操作，“粘贴”使用对应的快捷键。"
                : "↵ does this, and Paste takes its shortcut."
            XCTAssertTrue(settings.staticTexts[hint].exists)
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
                try captureChinesePanes(settings, search: field)
            }
            app.terminate()
        }
    }

    @MainActor
    private func captureChinesePanes(_ settings: XCUIElement, search: XCUIElement) throws {
        for (query, title, expected) in [
            ("General", "通用", "登录时启动"),
            ("Permissions", "权限", "辅助功能"),
            ("Snippets", "文本片段", "启用文本片段"),
            ("File Search", "文件搜索", "启用文件搜索"),
            ("Window Management", "窗口管理", "启用窗口管理"),
            ("Navigation", "导航", "启用导航"),
            ("Notes", "笔记", "启用笔记"),
            ("Calendar", "日历", "通过 Tinycast 加入会议"),
            ("Emoji & Symbols", "表情与符号", "表情肤色"),
            ("AI", "AI", "启用 AI"),
            ("Quick Actions", "快捷操作", "启用快捷操作"),
            ("Extensions", "扩展", "启用扩展"),
            ("Backup", "备份", "导出备份"),
            ("About", "关于", "小巧的原生 macOS 启动器。")
        ] {
            search.click()
            search.typeKey("a", modifierFlags: .command)
            search.typeText(query)
            let result = settings.staticTexts[title].firstMatch
            XCTAssertTrue(result.waitForExistence(timeout: 10), query)
            result.click()
            XCTAssertTrue(settings.staticTexts[expected].firstMatch.waitForExistence(timeout: 10), query)
            let details: [String: [String]] = [
                "Quick Actions": ["修正语法", "改写", "翻译", "总结"],
                "Calendar": ["读取今天和明天的日程以查找会议链接，数据不会离开此 Mac。"],
                "Window Management": ["重复执行半屏操作时保持原有大小和位置。"],
                "Extensions": ["正在搜索 Raycast Store。"]
            ]
            for detail in details[query] ?? [] {
                XCTAssertTrue(settings.staticTexts[detail].firstMatch.exists, "\(query): \(detail)")
            }
            capture(settings, named: "zh-Hans-pane-\(query)")
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
