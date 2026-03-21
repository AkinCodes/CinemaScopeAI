import Foundation

enum CinemaScopeError: Error, LocalizedError {
    case networkError(underlying: Error)
    case decodingError(underlying: Error)
    case invalidResponse
    case apiError(String)
    case noData

    var errorDescription: String? {
        switch self {
        case .networkError(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .decodingError(let underlying):
            return "Failed to decode response: \(underlying.localizedDescription)"
        case .invalidResponse:
            return "The server returned an invalid response."
        case .apiError(let message):
            return "API error: \(message)"
        case .noData:
            return "No data was received from the server."
        }
    }
}
