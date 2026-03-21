import Foundation

final class CinemaScopeAIService: MovieRecommendationServiceProtocol, Sendable {
    static let shared = CinemaScopeAIService()

    private let baseURL: URL

    init(baseURL: URL = AppConfiguration.cinemaBaseURL) {
        self.baseURL = baseURL
    }

    func fetchRecommendations(with input: [String: Any]) async throws -> [Recommendation] {
        let endpoint = baseURL.appendingPathComponent("predict/")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: input, options: [])
        } catch {
            throw CinemaScopeError.decodingError(underlying: error)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw CinemaScopeError.networkError(underlying: error)
        }

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw CinemaScopeError.apiError("HTTP \(httpResponse.statusCode)")
        }

        guard !data.isEmpty else {
            throw CinemaScopeError.noData
        }

        do {
            let decoded = try JSONDecoder().decode([String: [Recommendation]].self, from: data)
            guard let recommendations = decoded["recommendations"] else {
                throw CinemaScopeError.invalidResponse
            }
            return recommendations
        } catch let error as CinemaScopeError {
            throw error
        } catch {
            throw CinemaScopeError.decodingError(underlying: error)
        }
    }
}
