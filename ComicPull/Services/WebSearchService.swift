import Foundation

// MARK: - Web Search Types

struct WebSearchResult: Decodable, Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let snippet: String

    enum CodingKeys: String, CodingKey {
        case title, url, snippet
    }

    init(title: String, url: String, snippet: String) {
        self.title = title
        self.url = url
        self.snippet = snippet
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.url = try container.decode(String.self, forKey: .url)
        self.snippet = try container.decodeIfPresent(String.self, forKey: .snippet) ?? ""
    }
}

struct BraveSearchResponse: Decodable {
    let web: BraveWebResults?
}

struct BraveWebResults: Decodable {
    let results: [BraveWebResult]
}

struct BraveWebResult: Decodable {
    let title: String
    let url: String
    let description: String
}

// MARK: - Service Protocol

protocol WebSearchServiceProtocol: Sendable {
    func search(query: String) async throws -> [WebSearchResult]
}

// MARK: - Errors

enum WebSearchError: LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            "Invalid web search API key."
        case .networkError(let error):
            "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            "Failed to parse search results: \(error.localizedDescription)"
        }
    }
}

// MARK: - Brave Search Implementation

final class BraveSearchService: WebSearchServiceProtocol {
    private let session: URLSession
    private let apiKey: String
    private let baseURL = URL(string: "https://api.search.brave.com/res/v1/web/search")!

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func search(query: String) async throws -> [WebSearchResult] {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "count", value: "10")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-Subscription-Token")

        let (data, _): (Data, URLResponse)
        do {
            (data, _) = try await session.data(for: request)
        } catch {
            throw WebSearchError.networkError(error)
        }

        do {
            let response = try JSONDecoder().decode(BraveSearchResponse.self, from: data)
            return response.web?.results.map {
                WebSearchResult(title: $0.title, url: $0.url, snippet: $0.description)
            } ?? []
        } catch {
            throw WebSearchError.decodingError(error)
        }
    }
}
