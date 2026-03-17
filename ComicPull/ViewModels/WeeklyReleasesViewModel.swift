import Foundation
import Observation
import SwiftData

@Observable
final class WeeklyReleasesViewModel {
    var issues: [ComicVineIssue] = []
    var isLoading = false
    var error: String?
    var selectedPublisher: String?

    private let comicVineService: ComicVineServiceProtocol

    var filteredIssues: [ComicVineIssue] {
        guard let publisher = selectedPublisher else { return issues }
        return issues.filter { $0.volume?.publisher?.name == publisher }
    }

    var publishers: [String] {
        let names = Set(issues.compactMap { $0.volume?.publisher?.name })
        return Array(names).sorted()
    }

    init(comicVineService: ComicVineServiceProtocol) {
        self.comicVineService = comicVineService
    }

    @MainActor
    func loadWeeklyReleases() async {
        isLoading = true
        error = nil
        do {
            issues = try await comicVineService.fetchWeeklyReleases(date: .now)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
