import Foundation
import Observation
import UIKit

@MainActor
@Observable
class GPTChatViewModel {
    var messages: [ChatMessage] = []
    var currentInput: String = ""
    var isLoading = false
    var errorMessage: String?
    var recommendations: [Recommendation] = []

    private let gptClient: GPTServiceProtocol
    private var lastPrompt: String?

    init(gptClient: GPTServiceProtocol = GPTClient()) {
        self.gptClient = gptClient
    }

    func sendMessage() async {
        let input = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }

        let userMessage = ChatMessage(role: "user", content: input)
        messages.append(userMessage)
        currentInput = ""
        isLoading = true
        errorMessage = nil

        let prompt = buildPrompt(from: input)
        lastPrompt = prompt

        do {
            let response = try await gptClient.fetchRecommendations(prompt: prompt)
            self.recommendations = response.recommendations
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } catch {
            self.errorMessage = error.localizedDescription
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }

        isLoading = false
    }

    func retry() async {
        guard let prompt = lastPrompt else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await gptClient.fetchRecommendations(prompt: prompt)
            self.recommendations = response.recommendations
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } catch {
            self.errorMessage = error.localizedDescription
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }

        isLoading = false
    }

    private func buildPrompt(from input: String) -> String {
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
