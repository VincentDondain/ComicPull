import Foundation
import Observation
import SwiftData

@Observable
final class CollectionViewModel {
    var filterStatus: ReadingStatus?
    var sortOrder: SortOrder = .dateAdded

    enum SortOrder: String, CaseIterable {
        case dateAdded = "Date Added"
        case series = "Series"
        case rating = "Rating"
    }

    func filteredComics(from comics: [Comic]) -> [Comic] {
        var result = comics
        if let status = filterStatus {
            result = result.filter { $0.status == status }
        }
        switch sortOrder {
        case .dateAdded:
            result.sort { ($0.dateAdded ?? .distantPast) > ($1.dateAdded ?? .distantPast) }
        case .series:
            result.sort { ($0.series?.name ?? "") < ($1.series?.name ?? "") }
        case .rating:
            result.sort { ($0.userReview?.score ?? 0) > ($1.userReview?.score ?? 0) }
        }
        return result
    }

    func readingProgress(for seriesName: String, in comics: [Comic]) -> (read: Int, total: Int) {
        let seriesComics = comics.filter { $0.series?.name == seriesName }
        let readCount = seriesComics.filter { $0.status == .read }.count
        return (readCount, seriesComics.count)
    }
}
