import Foundation
import SwiftData

@Model
final class Series {
    @Attribute(.unique) var comicVineID: Int
    var name: String
    var publisher: String
    var startYear: Int?
    var issueCount: Int
    var imageURL: URL?
    var seriesDescription: String?

    @Relationship(inverse: \Comic.series) var comics: [Comic] = []

    init(
        comicVineID: Int,
        name: String,
        publisher: String,
        startYear: Int? = nil,
        issueCount: Int = 0,
        imageURL: URL? = nil,
        seriesDescription: String? = nil
    ) {
        self.comicVineID = comicVineID
        self.name = name
        self.publisher = publisher
        self.startYear = startYear
        self.issueCount = issueCount
        self.imageURL = imageURL
        self.seriesDescription = seriesDescription
    }
}
