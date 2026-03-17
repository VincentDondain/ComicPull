import Foundation

// MARK: - Claude API Types

struct ClaudeMessage: Codable {
    let role: String
    let content: [ClaudeContent]
}

enum ClaudeContent: Codable {
    case text(String)
    case toolUse(id: String, name: String, input: [String: String])
    case toolResult(toolUseID: String, content: String)

    enum CodingKeys: String, CodingKey {
        case type, text, id, name, input
        case toolUseID = "tool_use_id"
        case content
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .toolUse(let id, let name, let input):
            try container.encode("tool_use", forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(input, forKey: .input)
        case .toolResult(let toolUseID, let content):
            try container.encode("tool_result", forKey: .type)
            try container.encode(toolUseID, forKey: .toolUseID)
            try container.encode(content, forKey: .content)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text)
        case "tool_use":
            let id = try container.decode(String.self, forKey: .id)
            let name = try container.decode(String.self, forKey: .name)
            let input = try container.decode([String: String].self, forKey: .input)
            self = .toolUse(id: id, name: name, input: input)
        default:
            let text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
            self = .text(text)
        }
    }
}

struct ClaudeRequest: Encodable {
    let model: String
    let maxTokens: Int
    let system: String?
    let messages: [ClaudeMessage]
    let tools: [ClaudeTool]?

    enum CodingKeys: String, CodingKey {
        case model, system, messages, tools
        case maxTokens = "max_tokens"
    }
}

struct ClaudeResponse: Decodable {
    let id: String
    let content: [ClaudeContent]
    let stopReason: String?

    enum CodingKeys: String, CodingKey {
        case id, content
        case stopReason = "stop_reason"
    }
}

struct ClaudeTool: Codable {
    let name: String
    let description: String
    let inputSchema: ClaudeToolSchema

    enum CodingKeys: String, CodingKey {
        case name, description
        case inputSchema = "input_schema"
    }
}

struct ClaudeToolSchema: Codable {
    let type: String
    let properties: [String: ClaudeToolProperty]
    let required: [String]
}

struct ClaudeToolProperty: Codable {
    let type: String
    let description: String
}

// MARK: - Service Protocol

protocol ClaudeServiceProtocol: Sendable {
    func sendMessage(
        system: String?,
        messages: [ClaudeMessage],
        tools: [ClaudeTool]?
    ) async throws -> ClaudeResponse
}

// MARK: - Errors

enum ClaudeError: LocalizedError {
    case invalidAPIKey
    case rateLimitExceeded
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            "Invalid Anthropic API key."
        case .rateLimitExceeded:
            "Claude API rate limit exceeded."
        case .networkError(let error):
            "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            "Failed to parse Claude response: \(error.localizedDescription)"
        case .invalidResponse(let code):
            "Invalid API response (status: \(code))"
        }
    }
}

// MARK: - Implementation

final class ClaudeService: ClaudeServiceProtocol {
    private let session: URLSession
    private let apiKey: String
    private let baseURL: URL
    private let model: String

    init(
        apiKey: String,
        model: String = "claude-sonnet-4-20250514",
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
        self.baseURL = AppConfiguration.anthropicBaseURL
    }

    func sendMessage(
        system: String?,
        messages: [ClaudeMessage],
        tools: [ClaudeTool]?
    ) async throws -> ClaudeResponse {
        let url = baseURL.appendingPathComponent("messages")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body = ClaudeRequest(
            model: model,
            maxTokens: 4096,
            system: system,
            messages: messages,
            tools: tools
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw ClaudeError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse(statusCode: -1)
        }

        switch httpResponse.statusCode {
        case 200: break
        case 401: throw ClaudeError.invalidAPIKey
        case 429: throw ClaudeError.rateLimitExceeded
        default: throw ClaudeError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(ClaudeResponse.self, from: data)
        } catch {
            throw ClaudeError.decodingError(error)
        }
    }
}
