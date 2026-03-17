import Foundation
import Observation
import SwiftData

@Observable
final class ComicDetailViewModel {
    var issue: ComicVineIssue?
    var isLoading = false
    var error: String?

    private let comicVineService: ComicVineServiceProtocol

    init(comicVineService: ComicVineServiceProtocol) {
        self.comicVineService = comicVineService
    }

    @MainActor
    func loadDetail(id: Int) async {
        isLoading = true
        error = nil
        do {
            issue = try await comicVineService.fetchIssueDetail(id: id)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
