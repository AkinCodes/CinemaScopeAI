import Foundation

actor GPTClient: GPTServiceProtocol {
    nonisolated let endpoint: String

    init(endpoint: String = AppConfiguration.openAIBaseURL) {
        self.endpoint = endpoint
    }

    nonisolated func fetchRecommendations(prompt: String) async throws -> RecommendationResponse {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            throw CinemaScopeError.apiError("API Key not found. Set the OPENAI_API_KEY environment variable.")
        }

        guard let url = URL(string: endpoint) else {
            throw CinemaScopeError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let messages: [[String: String]] = [
            ["role": "system", "content": "You are a movie recommendation AI. Return only raw JSON in this format: {\"recommendations\":[{...}]}"],
            ["role": "user", "content": prompt]
        ]

        let body: [String: Any] = [
            "model": AppConfiguration.openAIModel,
            "messages": messages
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(for: request)
        } catch {
            throw CinemaScopeError.networkError(underlying: error)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw CinemaScopeError.invalidResponse
        }

        guard let extracted = extractJSON(from: content) else {
            throw CinemaScopeError.invalidResponse
        }

        let jsonData = Data(extracted.utf8)
        do {
            return try JSONDecoder().decode(RecommendationResponse.self, from: jsonData)
        } catch {
            throw CinemaScopeError.decodingError(underlying: error)
        }
    }

    private nonisolated func extractJSON(from text: String) -> String? {
        guard let startIndex = text.firstIndex(of: "{"),
              let endIndex = text.lastIndex(of: "}") else {
            return nil
        }
        return String(text[startIndex...endIndex])
    }
}
