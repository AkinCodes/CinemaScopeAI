import Foundation

@MainActor
class CinemaScopeAIViewModel: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    @Published var isLoading = false
    @Published var releaseYear: String = "2021"
    @Published var durationText: String = ""
    @Published var type: String = ""
    @Published var rating: String = ""

    // Supported values
    let allowedTypes = ["Movie", "TV Show"]
    let allowedRatings = [
        "G", "PG", "PG-13", "PG-15", "R", "NC-17", "NR", "Unrated",
        "TV-Y", "TV-Y7", "TV-G", "TV-PG", "TV-14", "TV-MA",
        "ALL", "7+", "13+", "16+", "18+", "M", "MA15+"
    ]

    func fetchRecommendations() {
        isLoading = true

        // --- Sanitize Year ---
        let trimmedYear = releaseYear.trimmingCharacters(in: .whitespacesAndNewlines)
        let year = Int(trimmedYear) ?? 2000
        if Int(trimmedYear) == nil {
            print("⚠️ Invalid year input '\(releaseYear)'. Defaulting to 2000.")
        }

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

        print("🟢 Sending normalized request: \(payload)")

        // --- Send API Request ---
        CinemaScopeAIService.shared.fetchRecommendations(with: payload) { [weak self] result in
            DispatchQueue.main.async {
                self?.recommendations = result ?? []
                self?.isLoading = false
            }
        }
    }
}
