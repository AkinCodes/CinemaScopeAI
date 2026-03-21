import Foundation
import Observation
import UIKit

@MainActor
@Observable
class CinemaScopeAIViewModel {
    var recommendations: [Recommendation] = []
    var isLoading = false
    var errorMessage: String?
    var releaseYear: String = "2021"
    var durationText: String = ""
    var type: String = ""
    var rating: String = ""

    // Supported values
    let allowedTypes = ["Movie", "TV Show"]
    let allowedRatings = [
        "G", "PG", "PG-13", "PG-15", "R", "NC-17", "NR", "Unrated",
        "TV-Y", "TV-Y7", "TV-G", "TV-PG", "TV-14", "TV-MA",
        "ALL", "7+", "13+", "16+", "18+", "M", "MA15+"
    ]

    private let service: MovieRecommendationServiceProtocol
    private var lastPayload: [String: Any]?

    init(service: MovieRecommendationServiceProtocol = CinemaScopeAIService.shared) {
        self.service = service
    }

    func fetchRecommendations() {
        isLoading = true
        errorMessage = nil

        // --- Sanitize Year ---
        let trimmedYear = releaseYear.trimmingCharacters(in: .whitespacesAndNewlines)
        let year = Int(trimmedYear) ?? 2000

        // --- Sanitize Duration ---
        let safeDuration = durationText.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDuration = safeDuration.isEmpty ? "90" : safeDuration

        // --- Sanitize Type ---
        let cleanType = type.trimmingCharacters(in: .whitespacesAndNewlines)
        let matchedType = allowedTypes.first(where: {
            $0.lowercased().contains(cleanType.lowercased())
        }) ?? "Movie"

        // --- Sanitize Rating ---
        let cleanedRating = rating
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .replacingOccurrences(of: "-", with: "")
        let matchedRating = allowedRatings.first(where: {
            $0.replacingOccurrences(of: "-", with: "").uppercased() == cleanedRating
        }) ?? "PG"

        // --- Build Payload ---
        let payload: [String: Any] = [
            "release_year": year,
            "duration_text": finalDuration,
            "type": matchedType,
            "rating": matchedRating
        ]

        lastPayload = payload

        Task {
            do {
                let results = try await service.fetchRecommendations(with: payload)
                self.recommendations = results
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } catch {
                self.errorMessage = error.localizedDescription
                self.recommendations = []
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
            self.isLoading = false
        }
    }

    func retry() {
        guard lastPayload != nil else {
            fetchRecommendations()
            return
        }
        fetchRecommendations()
    }

    func reset() {
        releaseYear = ""
        durationText = ""
        type = ""
        rating = ""
        recommendations = []
        errorMessage = nil
        lastPayload = nil
    }
}
