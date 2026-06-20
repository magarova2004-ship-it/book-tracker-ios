import SwiftUI
import Combine

enum ReaderFontSize: String, CaseIterable, Codable {
    case small  = "Маленький"
    case medium = "Средний"
    case large  = "Большой"

    var font: Font {
        switch self {
        case .small:  return .system(size: 15, design: .serif)
        case .medium: return .system(size: 18, design: .serif)
        case .large:  return .system(size: 22, design: .serif)
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .small:  return 6
        case .medium: return 7
        case .large:  return 8
        }
    }
}

class AppSettings: ObservableObject {
    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: "pref_userName") }
    }
    @Published var userEmoji: String {
        didSet { UserDefaults.standard.set(userEmoji, forKey: "pref_userEmoji") }
    }
    @Published var isDarkMode: Bool {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "pref_isDarkMode") }
    }
    @Published var readerFontSize: ReaderFontSize {
        didSet { UserDefaults.standard.set(readerFontSize.rawValue, forKey: "pref_readerFontSize") }
    }

    init() {
        userName     = UserDefaults.standard.string(forKey: "pref_userName") ?? "Читатель"
        userEmoji    = UserDefaults.standard.string(forKey: "pref_userEmoji") ?? "📚"
        isDarkMode   = UserDefaults.standard.bool(forKey: "pref_isDarkMode")
        let raw      = UserDefaults.standard.string(forKey: "pref_readerFontSize") ?? ""
        readerFontSize = ReaderFontSize(rawValue: raw) ?? .medium
    }
}
