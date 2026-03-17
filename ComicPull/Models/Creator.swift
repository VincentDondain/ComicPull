import Foundation
import SwiftData

@Model
final class Creator {
    @Attribute(.unique) var comicVineID: Int
    var name: String
    var role: String
    var imageURL: URL?

    @Relationship(inverse: \Comic.creators) var comics: [Comic] = []

    init(comicVineID: Int, name: String, role: String, imageURL: URL? = nil) {
        self.comicVineID = comicVineID
        self.name = name
        self.role = role
        self.imageURL = imageURL
    }
}
