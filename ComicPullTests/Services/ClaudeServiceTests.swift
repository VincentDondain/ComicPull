import Testing
@testable import ComicPull

// MARK: - Mock Claude Service

struct MockClaudeService: ClaudeServiceProtocol {
    var response: ClaudeResponse?
    var error: Error?

    func sendMessage(
        system: String?,
        messages: [ClaudeMessage],
        tools: [ClaudeTool]?
    ) async throws -> ClaudeResponse {
        if let error { throw error }
        return response ?? ClaudeResponse(
            id: "test",
            content: [.text("No recommendations available.")],
            stopReason: "end_turn"
        )
    }
}

@Suite("Claude Service Tests")
struct ClaudeServiceTests {
    @Test("Send message returns response")
    func sendMessageSuccess() async throws {
        let mockResponse = ClaudeResponse(
            id: "msg_123",
            content: [.text("Here are some recommendations...")],
            stopReason: "end_turn"
        )

        let service = MockClaudeService(response: mockResponse)

        let result = try await service.sendMessage(
            system: "You are a comic expert",
            messages: [ClaudeMessage(role: "user", content: [.text("Recommend comics")])],
            tools: nil
        )

        #expect(result.id == "msg_123")
        #expect(result.content.count == 1)
    }

    @Test("Send message handles error")
    func sendMessageError() async {
        let service = MockClaudeService(error: ClaudeError.invalidAPIKey)

        do {
            _ = try await service.sendMessage(system: nil, messages: [], tools: nil)
            Issue.record("Expected error")
        } catch {
            #expect(error is ClaudeError)
        }
    }
}
