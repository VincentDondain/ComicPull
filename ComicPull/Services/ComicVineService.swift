import Foundation

// MARK: - Comic Vine API Response Types

struct ComicVineResponse<T: Decodable>: Decodable {
    let error: String
    let limit: Int
    let offset: Int
    let numberOfPageResults: Int
    let numberOfTotalResults: Int
    let statusCode: Int
    let results: T

    enum CodingKeys: String, CodingKey {
        case error, limit, offset, results
        case numberOfPageResults = "number_of_page_results"
        case numberOfTotalResults = "number_of_total_results"
        case statusCode = "status_code"
    }
}

struct ComicVineIssue: Decodable, Identifiable {
    let id: Int
    let issueNumber: String?
    let name: String?
    let description: String?
    let storeDate: String?
    let image: ComicVineImage?
    let volume: ComicVineVolume?
    let personCredits: [ComicVinePerson]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, image, volume
        case issueNumber = "issue_number"
        case storeDate = "store_date"
        case personCredits = "person_credits"
    }
}

struct ComicVineImage: Decodable {
    let smallURL: URL?
    let mediumURL: URL?
    let superURL: URL?

    enum CodingKeys: String, CodingKey {
        case smallURL = "small_url"
        case mediumURL = "medium_url"
        case superURL = "super_url"
    }
}

struct ComicVineVolume: Decodable, Identifiable {
    let id: Int
    let name: String?
    let publisher: ComicVinePublisher?
    let countOfIssues: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, publisher
        case countOfIssues = "count_of_issues"
    }
}

struct ComicVinePublisher: Decodable {
    let id: Int
    let name: String?
}

struct ComicVinePerson: Decodable, Identifiable {
    let id: Int
    let name: String?
    let role: String?
}

// MARK: - Service Protocol

protocol ComicVineServiceProtocol: Sendable {
    func fetchWeeklyReleases(date: Date) async throws -> [ComicVineIssue]
    func fetchIssueDetail(id: Int) async throws -> ComicVineIssue
    func searchIssues(query: String) async throws -> [ComicVineIssue]
    func fetchVolume(id: Int) async throws -> ComicVineVolume
}

// MARK: - Errors

enum ComicVineError: LocalizedError {
    case invalidAPIKey
    case rateLimitExceeded
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            "Invalid Comic Vine API key. Please check your configuration."
        case .rateLimitExceeded:
            "Comic Vine API rate limit exceeded. Please try again later."
        case .networkError(let error):
            "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            "Failed to parse response: \(error.localizedDescription)"
        case .invalidResponse(let code):
            "Invalid API response (status: \(code))"
        }
    }
}

// MARK: - Implementation

final class ComicVineService: ComicVineServiceProtocol {
    private let session: URLSession
    private let apiKey: String
    private let baseURL: URL
    private let cache = URLCache(
        memoryCapacity: 10_000_000,
        diskCapacity: 50_000_000
    )

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
        self.baseURL = AppConfiguration.comicVineBaseURL
    }

    func fetchWeeklyReleases(date: Date) async throws -> [ComicVineIssue] {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? date

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startStr = formatter.string(from: weekStart)
        let endStr = formatter.string(from: weekEnd)

        let url = buildURL(
            endpoint: "issues",
            extraParams: [
                "filter": "store_date:\(startStr)|\(endStr)",
                "sort": "store_date:asc",
                "limit": "100"
            ]
        )

        let response: ComicVineResponse<[ComicVineIssue]> = try await fetch(url: url)
        return response.results
    }

    func fetchIssueDetail(id: Int) async throws -> ComicVineIssue {
        let url = buildURL(endpoint: "issue/4000-\(id)")
        let response: ComicVineResponse<ComicVineIssue> = try await fetch(url: url)
        return response.results
    }

    func searchIssues(query: String) async throws -> [ComicVineIssue] {
        let url = buildURL(
            endpoint: "search",
            extraParams: [
                "query": query,
                "resources": "issue",
                "limit": "20"
            ]
        )

        let response: ComicVineResponse<[ComicVineIssue]> = try await fetch(url: url)
        return response.results
    }

    func fetchVolume(id: Int) async throws -> ComicVineVolume {
        let url = buildURL(endpoint: "volume/4050-\(id)")
        let response: ComicVineResponse<ComicVineVolume> = try await fetch(url: url)
        return response.results
    }

    // MARK: - Private

    private func buildURL(endpoint: String, extraParams: [String: String] = [:]) -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json")
        ]
        for (key, value) in extraParams {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = queryItems
        return components.url!
    }

    private func fetch<T: Decodable>(url: URL) async throws -> T {
        let request = URLRequest(url: url)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw ComicVineError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ComicVineError.invalidResponse(statusCode: -1)
        }

        switch httpResponse.statusCode {
        case 200: break
        case 401: throw ComicVineError.invalidAPIKey
        case 429: throw ComicVineError.rateLimitExceeded
        default: throw ComicVineError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw ComicVineError.decodingError(error)
        }
    }
}
