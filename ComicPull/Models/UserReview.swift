import Foundation
import SwiftData

@Model
final class UserReview {
    var score: Int // 1-10
    var text: String?
    var dateCreated: Date

    var comic: Comic?

    init(score: Int, text: String? = nil, dateCreated: Date = .now) {
        self.score = min(max(score, 1), 10)
        self.text = text
        self.dateCreated = dateCreated
    }
}
