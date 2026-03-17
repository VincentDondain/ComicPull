import Foundation

enum AppConfiguration {
    static let comicVineBaseURL = URL(string: "https://comicvine.gamespot.com/api")!
    static let anthropicBaseURL = URL(string: "https://api.anthropic.com/v1")!

    static let comicVineAPIKeyName = "ComicVineAPIKey"
    static let anthropicAPIKeyName = "AnthropicAPIKey"
    static let webSearchAPIKeyName = "WebSearchAPIKey"

    static let comicVineRateLimit = 200 // per hour
    static let cacheDurationSeconds: TimeInterval = 3600

    static let recommendationRefreshInterval: TimeInterval = 7 * 24 * 3600 // weekly
}
