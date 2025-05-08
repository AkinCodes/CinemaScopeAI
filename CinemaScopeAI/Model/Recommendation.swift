import Foundation

struct Recommendation: Identifiable, Codable {
    var id: String { title + String(release_year) } 
    
    let title: String
    let genre: String
    let rating: String
    let score: Double
    let poster_url: String?
    let director: String
    let release_year: Int
    let summary: String
    
    enum CodingKeys: String, CodingKey {
        case title, genre, rating, score, poster_url, director, release_year, summary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        genre = try container.decode(String.self, forKey: .genre)
        rating = try container.decode(String.self, forKey: .rating)
        
        let rawScore = try container.decode(Double.self, forKey: .score)
        score = rawScore.isFinite ? rawScore : 0.0
        
        poster_url = try? container.decodeIfPresent(String.self, forKey: .poster_url)
        director = try container.decode(String.self, forKey: .director)
        release_year = try container.decode(Int.self, forKey: .release_year)
        summary = try container.decode(String.self, forKey: .summary)
    }
}

struct RecommendationResponse: Codable {
    let recommendations: [Recommendation]
}
