import Testing
@testable import ComicPull

@Suite("Recommendations ViewModel Tests")
struct RecommendationsViewModelTests {
    @Test("Empty history shows error")
    @MainActor
    func emptyHistory() async {
        let engine = RecommendationEngine(
            claudeService: MockClaudeService(),
            webSearchService: MockWebSearch()
        )
        let vm = RecommendationsViewModel(engine: engine)

        await vm.loadRecommendations(readComics: [], reviews: [])

        #expect(vm.recommendations.isEmpty)
        #expect(vm.error != nil)
    }
}
