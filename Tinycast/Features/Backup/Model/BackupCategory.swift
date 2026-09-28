import Foundation

/// One selectable slice of a backup; `descriptor` is exhaustive, as `AppEntry.Kind`'s is.
enum BackupCategory: String, CaseIterable, Identifiable, Sendable {
    case configuration
    case clipboard
    case snippets
    case notes
    case learning

    var id: Self { self }

    struct Descriptor: Sendable {
        let label: String
        let symbol: String
        /// Where this category's files sit inside the bundle; empty means the bundle root.
        let subpath: String
        /// How the picker counts this category; nil where a number would say nothing.
        let countNoun: String?
    }

    var descriptor: Descriptor {
        switch self {
        case .configuration:
            return .init(
                label: String(localized: "Settings & Shortcuts"), symbol: "slider.horizontal.3", subpath: "",
                countNoun: nil)
        case .clipboard:
            return .init(
                label: String(localized: "Clipboard History"), symbol: "doc.on.clipboard", subpath: "clipboard",
                countNoun: String(localized: "clips"))
        case .snippets:
            return .init(
                label: String(localized: "Snippets"), symbol: "curlybraces", subpath: "snippets",
                countNoun: String(localized: "snippets"))
        case .notes:
            return .init(
                label: String(localized: "Notes"), symbol: "note.text", subpath: "notes",
                countNoun: String(localized: "notes"))
        case .learning:
            return .init(
                label: String(localized: "Launcher Learning"), symbol: "chart.line.uptrend.xyaxis",
                subpath: "learning", countNoun: String(localized: "records"))
        }
    }

    static let all = Set(BackupCategory.allCases)

    /// Declaration order, so the picker, the manifest and the summary all list the same way.
    static func ordered(_ selection: Set<BackupCategory>) -> [BackupCategory] {
        allCases.filter(selection.contains)
    }
}
