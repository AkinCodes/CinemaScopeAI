import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var recommendations: [Recommendation] = []

    func sendMessage() async {
        let input = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }

        let userMessage = ChatMessage(role: "user", content: input)
        messages.append(userMessage)
        currentInput = ""
        isLoading = true

        let prompt = buildPrompt(from: input)

        do {
            let raw = try await sendPromptToGPT(prompt: prompt)
            print("Raw Response: \(raw)")

            guard !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                self.errorMessage = "GPT returned an empty response."
                isLoading = false
                return
            }

            guard let jsonOnly = extractJSON(from: raw) else {
                print("❌ Could not extract JSON from:\n\(raw)")
                self.errorMessage = "Could not find valid JSON in GPT response."
                isLoading = false
                return
            }

            let jsonData = Data(jsonOnly.utf8)

            do {
                let decoded = try JSONDecoder().decode(RecommendationResponse.self, from: jsonData)
                self.recommendations = decoded.recommendations
                print("✅ Decoded \(decoded.recommendations.count) recommendations")
                self.errorMessage = nil
            } catch {
                print("❌ Failed to decode JSON: \(error)")
                self.errorMessage = "Failed to read GPT suggestions"
            }

        } catch {
            print("❌ GPT request failed: \(error)")
            self.errorMessage = "Could not fetch response from GPT."
        }

        isLoading = false
    }

    private func buildPrompt(from input: String) -> String {
        let systemPrompt = """
        You are a movie recommendation AI. Return only valid JSON in the following format:

        {
          "recommendations": [
            {
              "title": "The Matrix",
              "genre": "Action",
              "rating": "PG-13",
              "score": 0.92,
              "poster_url": "https://image.tmdb.org/t/p/w500/valid-poster.jpg",
              "director": "The Wachowskis",
              "release_year": 1999,
              "summary": "A computer hacker learns the nature of reality and joins a rebellion."
            }
          ]
        }

        Rules:
        - Return exactly 5 movie recommendations.
        - The value for poster_url must be a real image link from TMDB (not a placeholder or fake link).
        - Only respond with JSON. Do not include any notes, comments, or explanation.

        Example poster_url:
        "https://image.tmdb.org/t/p/w500/d8Ryb8AunYAuycVKDp5HpdWPKgC.jpg"
        """

        return "\(systemPrompt)\n\nUser Request: \(input)"
    }

    private func sendPromptToGPT(prompt: String) async throws -> String {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            throw NSError(domain: "API Key not found", code: 1)
        }

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a movie recommendation AI. Return only raw JSON in this format:\n\n{\"recommendations\":[{...}]}"],
                ["role": "user", "content": prompt] // this should be what you typed (e.g. "Recommend movies like Terminator")
            ]
        ]

        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: urlRequest)

        if let debugString = String(data: data, encoding: .utf8) {
            print("🧩 Raw JSON returned:\n\(debugString)")
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String ?? "No response"

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func extractJSON(from text: String) -> String? {
        guard let startIndex = text.firstIndex(of: "{"),
              let endIndex = text.lastIndex(of: "}") else {
            return nil
        }

        let jsonSubstring = text[startIndex...endIndex]
        return String(jsonSubstring)
    }

}
