import Foundation
import SwiftData

// MARK: - Recommendation Types

struct Recommendation: Identifiable {
    let id = UUID()
    let seriesName: String
    let issueNumber: String
    let publisher: String
    let releaseInfo: String
    let reason: String
    let creators: String
    let coverSearchQuery: String
}

// MARK: - Protocol

protocol RecommendationEngineProtocol: Sendable {
    func getRecommendations(
        readComics: [Comic],
        reviews: [UserReview]
    ) async throws -> [Recommendation]
}

// MARK: - Errors

enum RecommendationError: LocalizedError {
    case noReadingHistory
    case claudeError(Error)
    case parsingError

    var errorDescription: String? {
        switch self {
        case .noReadingHistory:
            "No reading history found. Read and rate some comics first!"
        case .claudeError(let error):
            "Recommendation engine error: \(error.localizedDescription)"
        case .parsingError:
            "Failed to parse recommendations."
        }
    }
}

// MARK: - Implementation

final class RecommendationEngine: RecommendationEngineProtocol {
    private let claudeService: ClaudeServiceProtocol
    private let webSearchService: WebSearchServiceProtocol

    private let systemPrompt = """
    You are a comic book expert recommendation engine. Given a user's reading history \
    and ratings, suggest new comic book series they should start reading.

    Focus on:
    - New #1 issues releasing in the next 3 months
    - Series by the same writers, artists, or creative teams
    - Similar themes, tones, or genres
    - Critically acclaimed new launches

    When you need to find upcoming releases, use the web_search tool.

    Format each recommendation as:
    SERIES: [name]
    ISSUE: [number, usually #1]
    PUBLISHER: [publisher]
    RELEASE: [release info]
    CREATORS: [key creators]
    REASON: [why this matches their taste, 1-2 sentences]
    ---
    """

    init(claudeService: ClaudeServiceProtocol, webSearchService: WebSearchServiceProtocol) {
        self.claudeService = claudeService
        self.webSearchService = webSearchService
    }

    func getRecommendations(
        readComics: [Comic],
        reviews: [UserReview]
    ) async throws -> [Recommendation] {
        guard !readComics.isEmpty else {
            throw RecommendationError.noReadingHistory
        }

        let readingSummary = buildReadingSummary(comics: readComics, reviews: reviews)

        let searchTool = ClaudeTool(
            name: "web_search",
            description: "Search the web for upcoming comic book releases and news.",
            inputSchema: ClaudeToolSchema(
                type: "object",
                properties: [
                    "query": ClaudeToolProperty(
                        type: "string",
                        description: "The search query for finding comic book releases"
                    )
                ],
                required: ["query"]
            )
        )

        var messages: [ClaudeMessage] = [
            ClaudeMessage(role: "user", content: [
                .text("""
                Based on my reading history, recommend 5 new comic series I should start. \
                Search the web to find upcoming #1 releases.

                My reading history:
                \(readingSummary)

                Find upcoming comic #1 issues and recommend series that match my taste.
                """)
            ])
        ]

        // Agentic loop: handle tool calls
        var maxIterations = 5
        while maxIterations > 0 {
            maxIterations -= 1

            let response: ClaudeResponse
            do {
                response = try await claudeService.sendMessage(
                    system: systemPrompt,
                    messages: messages,
                    tools: [searchTool]
                )
            } catch {
                throw RecommendationError.claudeError(error)
            }

            // Check for tool use
            var hasToolUse = false
            var toolResults: [ClaudeContent] = []

            for content in response.content {
                if case .toolUse(let id, let name, let input) = content, name == "web_search" {
                    hasToolUse = true
                    let query = input["query"] ?? "new comic book releases 2026"
                    let results = try await webSearchService.search(query: query)
                    let resultText = results.prefix(5).map { "\($0.title)\n\($0.snippet)" }.joined(separator: "\n\n")
                    toolResults.append(.toolResult(toolUseID: id, content: resultText))
                }
            }

            if hasToolUse {
                messages.append(ClaudeMessage(role: "assistant", content: response.content))
                messages.append(ClaudeMessage(role: "user", content: toolResults))
            } else {
                // Final text response — parse recommendations
                return parseRecommendations(from: response)
            }
        }

        throw RecommendationError.parsingError
    }

    // MARK: - Private

    private func buildReadingSummary(comics: [Comic], reviews: [UserReview]) -> String {
        var lines: [String] = []
        for comic in comics {
            var line = comic.displayTitle
            if let review = comic.userReview {
                line += " (rated: \(review.score)/10)"
            }
            if let creators = comic.creators.first {
                line += " — \(creators.name) (\(creators.role))"
            }
            lines.append(line)
        }
        return lines.joined(separator: "\n")
    }

    private func parseRecommendations(from response: ClaudeResponse) -> [Recommendation] {
        var recommendations: [Recommendation] = []

        for content in response.content {
            if case .text(let text) = content {
                let blocks = text.components(separatedBy: "---")
                for block in blocks {
                    if let rec = parseBlock(block.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        recommendations.append(rec)
                    }
                }
            }
        }

        return recommendations
    }

    private func parseBlock(_ block: String) -> Recommendation? {
        guard !block.isEmpty else { return nil }

        func extract(_ prefix: String) -> String {
            block.components(separatedBy: "\n")
                .first { $0.hasPrefix(prefix) }?
                .replacingOccurrences(of: prefix, with: "")
                .trimmingCharacters(in: .whitespaces) ?? ""
        }

        let series = extract("SERIES:")
        guard !series.isEmpty else { return nil }

        return Recommendation(
            seriesName: series,
            issueNumber: extract("ISSUE:"),
            publisher: extract("PUBLISHER:"),
            releaseInfo: extract("RELEASE:"),
            reason: extract("REASON:"),
            creators: extract("CREATORS:"),
            coverSearchQuery: "\(series) comic cover"
        )
    }
}
