import Foundation

struct Recommendation: Identifiable, Codable {
    let id = UUID()
    let title: String
    let genre: String
    let rating: String
    let score: Double
    let poster_url: String?
    let director: String
    let release_year: Int
    let summary: String
}

struct RecommendationResponse: Codable {
    let recommendations: [Recommendation]
}


