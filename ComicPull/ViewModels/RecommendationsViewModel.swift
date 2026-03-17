import Foundation
import Observation

@Observable
final class RecommendationsViewModel {
    var recommendations: [Recommendation] = []
    var isLoading = false
    var error: String?

    private let engine: RecommendationEngineProtocol

    init(engine: RecommendationEngineProtocol) {
        self.engine = engine
    }

    @MainActor
    func loadRecommendations(readComics: [Comic], reviews: [UserReview]) async {
        isLoading = true
        error = nil
        do {
            recommendations = try await engine.getRecommendations(
                readComics: readComics,
                reviews: reviews
            )
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
