import Foundation

actor GPTClient {
    private let endpoint = "https://api.openai.com/v1/chat/completions"

    func fetchRecommendations(prompt: String) async throws -> RecommendationResponse {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            throw NSError(domain: "API Key not found", code: 1)
        }

        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
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
            "model": "gpt-3.5-turbo",
            "messages": messages
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "Invalid response format", code: 2)
        }

        guard let extracted = extractJSON(from: content) else {
            throw NSError(domain: "Failed to extract JSON", code: 3)
        }

        let jsonData = Data(extracted.utf8)
        return try JSONDecoder().decode(RecommendationResponse.self, from: jsonData)
    }

    private func extractJSON(from text: String) -> String? {
        guard let startIndex = text.firstIndex(of: "{"),
              let endIndex = text.lastIndex(of: "}") else {
            return nil
        }
        return String(text[startIndex...endIndex])
    }
}

