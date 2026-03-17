import Testing
@testable import ComicPull

// MARK: - Mock Services

struct MockWebSearch: WebSearchServiceProtocol {
    var results: [WebSearchResult] = []
    func search(query: String) async throws -> [WebSearchResult] { results }
}

@Suite("Recommendation Engine Tests")
struct RecommendationEngineTests {
    @Test("No reading history throws error")
    func noHistory() async {
        let engine = RecommendationEngine(
            claudeService: MockClaudeService(),
            webSearchService: MockWebSearch()
        )

        do {
            _ = try await engine.getRecommendations(readComics: [], reviews: [])
            Issue.record("Expected noReadingHistory error")
        } catch let error as RecommendationError {
            #expect(error == .noReadingHistory)
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }
}

extension RecommendationError: Equatable {
    public static func == (lhs: RecommendationError, rhs: RecommendationError) -> Bool {
        switch (lhs, rhs) {
        case (.noReadingHistory, .noReadingHistory): true
        case (.parsingError, .parsingError): true
        default: false
        }
    }
}
