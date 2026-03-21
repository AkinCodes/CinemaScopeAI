import Foundation

protocol MovieRecommendationServiceProtocol: Sendable {
    func fetchRecommendations(with input: [String: Any]) async throws -> [Recommendation]
}

protocol GPTServiceProtocol: Sendable {
    func fetchRecommendations(prompt: String) async throws -> RecommendationResponse
}
