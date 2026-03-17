import Foundation
import SwiftData

@Model
final class Comic {
    @Attribute(.unique) var comicVineID: Int
    var issueNumber: String
    var title: String?
    var synopsis: String?
    var coverImageURL: URL?
    var storeDate: Date?
    var communityRating: Double?
    var publisher: String?

    var status: ReadingStatus?
    var dateAdded: Date?
    var dateRead: Date?

    var series: Series?
    var creators: [Creator] = []

    @Relationship(deleteRule: .cascade) var userReview: UserReview?

    init(
        comicVineID: Int,
        issueNumber: String,
        title: String? = nil,
        synopsis: String? = nil,
        coverImageURL: URL? = nil,
        storeDate: Date? = nil,
        communityRating: Double? = nil,
        publisher: String? = nil
    ) {
        self.comicVineID = comicVineID
        self.issueNumber = issueNumber
        self.title = title
        self.synopsis = synopsis
        self.coverImageURL = coverImageURL
        self.storeDate = storeDate
        self.communityRating = communityRating
        self.publisher = publisher
    }

    var displayTitle: String {
        if let seriesName = series?.name {
            return "\(seriesName) #\(issueNumber)"
        }
        return title ?? "#\(issueNumber)"
    }
}
