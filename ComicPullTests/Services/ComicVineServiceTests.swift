import Foundation
import Testing
@testable import ComicPull

// MARK: - Mock Comic Vine Service

struct MockComicVineService: ComicVineServiceProtocol {
    var issuesResult: Result<[ComicVineIssue], Error> = .success([])
    var issueDetailResult: Result<ComicVineIssue, Error>?
    var searchResult: Result<[ComicVineIssue], Error> = .success([])
    var volumeResult: Result<ComicVineVolume, Error>?

    func fetchWeeklyReleases(date: Date) async throws -> [ComicVineIssue] {
        try issuesResult.get()
    }

    func fetchIssueDetail(id: Int) async throws -> ComicVineIssue {
        guard let result = issueDetailResult else {
            throw ComicVineError.invalidResponse(statusCode: 404)
        }
        return try result.get()
    }

    func searchIssues(query: String) async throws -> [ComicVineIssue] {
        try searchResult.get()
    }

    func fetchVolume(id: Int) async throws -> ComicVineVolume {
        guard let result = volumeResult else {
            throw ComicVineError.invalidResponse(statusCode: 404)
        }
        return try result.get()
    }
}

// MARK: - Tests

@Suite("Comic Vine Service Tests")
struct ComicVineServiceTests {
    @Test("Weekly releases returns issues")
    func weeklyReleasesSuccess() async throws {
        let mockIssue = ComicVineIssue(
            id: 1,
            issueNumber: "1",
            name: "Test Issue",
            description: nil,
            storeDate: "2026-03-18",
            image: nil,
            volume: ComicVineVolume(id: 100, name: "Batman", publisher: ComicVinePublisher(id: 10, name: "DC Comics"), countOfIssues: 50),
            personCredits: nil
        )

        var service = MockComicVineService()
        service.issuesResult = .success([mockIssue])

        let results = try await service.fetchWeeklyReleases(date: .now)
        #expect(results.count == 1)
        #expect(results.first?.issueNumber == "1")
        #expect(results.first?.volume?.name == "Batman")
    }

    @Test("Weekly releases handles error")
    func weeklyReleasesError() async {
        var service = MockComicVineService()
        service.issuesResult = .failure(ComicVineError.rateLimitExceeded)

        do {
            _ = try await service.fetchWeeklyReleases(date: .now)
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is ComicVineError)
        }
    }

    @Test("Search returns matching issues")
    func searchSuccess() async throws {
        let mockIssue = ComicVineIssue(
            id: 2,
            issueNumber: "5",
            name: "Saga",
            description: nil,
            storeDate: nil,
            image: nil,
            volume: nil,
            personCredits: nil
        )

        var service = MockComicVineService()
        service.searchResult = .success([mockIssue])

        let results = try await service.searchIssues(query: "Saga")
        #expect(results.count == 1)
        #expect(results.first?.name == "Saga")
    }
}
