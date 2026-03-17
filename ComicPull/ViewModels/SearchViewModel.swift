import Foundation
import Observation

@Observable
final class SearchViewModel {
    var query = ""
    var results: [ComicVineIssue] = []
    var isSearching = false
    var error: String?

    private let comicVineService: ComicVineServiceProtocol

    init(comicVineService: ComicVineServiceProtocol) {
        self.comicVineService = comicVineService
    }

    @MainActor
    func search() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        error = nil
        do {
            results = try await comicVineService.searchIssues(query: query)
        } catch {
            self.error = error.localizedDescription
        }
        isSearching = false
    }
}
