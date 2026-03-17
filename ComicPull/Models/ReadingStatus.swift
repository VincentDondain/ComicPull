import Foundation
import SwiftData

enum ReadingStatus: String, Codable, CaseIterable, Identifiable {
    case want = "Want"
    case acquired = "Acquired"
    case reading = "Reading"
    case read = "Read"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .want: "heart"
        case .acquired: "bag"
        case .reading: "book"
        case .read: "checkmark.circle"
        }
    }
}
