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
            if language == "zh-Hans" {
                try captureOnboardingAndLauncher(app)
            }
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
    private func captureOnboardingAndLauncher(_ app: XCUIApplication) throws {
        let welcome = app.windows["欢迎使用 Tinycast"]
        XCTAssertTrue(welcome.waitForExistence(timeout: 20))
        capture(welcome, named: "zh-Hans-onboarding-shortcut")
        welcome.buttons["继续"].click()
        XCTAssertTrue(welcome.staticTexts["启用粘贴"].waitForExistence(timeout: 10))
        capture(welcome, named: "zh-Hans-onboarding-permissions")
        let skip = welcome.buttons["跳过"]
        if skip.exists { skip.click() } else { welcome.buttons["继续"].click() }
        XCTAssertTrue(welcome.staticTexts["从 Raycast 导入"].waitForExistence(timeout: 10))
        capture(welcome, named: "zh-Hans-onboarding-import")
        welcome.buttons["跳过"].click()
        XCTAssertTrue(welcome.staticTexts["准备就绪"].waitForExistence(timeout: 10))
        capture(welcome, named: "zh-Hans-onboarding-ready")
        welcome.buttons["开始使用"].click()
        let statusItem = app.descendants(matching: .statusItem)["Tinycast Chinese Dev"]
        XCTAssertTrue(statusItem.waitForExistence(timeout: 10))
        statusItem.click()
        app.menuItems["打开Tinycast Chinese Dev"].click()
        let query = app.textFields.firstMatch
        XCTAssertTrue(query.waitForExistence(timeout: 10))
        query.click()
        query.typeText("Tinycast Settings")
        XCTAssertTrue(app.staticTexts["Tinycast 设置"].firstMatch.waitForExistence(timeout: 10))
        capture(app.windows.firstMatch, named: "zh-Hans-launcher-english-alias")
        query.typeKey(.escape, modifierFlags: [])
    }

    @MainActor
    private func captureChinesePanes(_ settings: XCUIElement, search: XCUIElement) throws {
        for (query, title, expected) in [
            ("General", "通用", "登录时启动"),
            ("Permissions", "权限", "辅助功能"),
            ("Applications", "应用", "启用应用"),
            ("System Settings", "系统设置", "启用系统设置"),
            ("System Actions", "系统操作", "启用系统操作"),
            ("Commands", "命令", "启用命令"),
            ("Quicklinks", "快捷链接", "添加快捷链接"),
            ("Apple Shortcuts", "Apple 快捷指令", "启用 Apple 快捷指令"),
            ("Fallbacks", "后备操作", "显示在每次搜索下方的“将…用于”区域，包含带 {argument} 的快捷链接。"),
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
