import Combine

@MainActor
class GPTChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var recommendations: [Recommendation] = []

    private let gptClient = GPTClient()

    func sendMessage() async {
        let input = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }

        let userMessage = ChatMessage(role: "user", content: input)
        messages.append(userMessage)
        currentInput = ""
        isLoading = true

        let prompt = buildPrompt(from: input)

        do {
            let response = try await gptClient.fetchRecommendations(prompt: prompt)
            self.recommendations = response.recommendations
            self.errorMessage = nil
        } catch {
            print("❌ GPT error: \(error)")
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func buildPrompt(from input: String) -> String {
        // keep the same prompt format you already wrote
        """
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
        - The value for poster_url must be a real image link from TMDB.
        - Only respond with JSON. Do not include any explanation.

        User Request: \(input)
        """
    }
}
