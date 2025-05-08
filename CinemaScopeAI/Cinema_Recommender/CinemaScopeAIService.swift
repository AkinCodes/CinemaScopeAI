import Foundation

class CinemaScopeAIService {
    static let shared = CinemaScopeAIService()
    private let baseURL = URL(string: "https://cinemascope-api.onrender.com")!
    
    func fetchRecommendations(with input: [String: Any], completion: @escaping ([Recommendation]?) -> Void) {
        let endpoint = baseURL.appendingPathComponent("predict/")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("🟢 Sending request to: \(endpoint)")
        print("🟢 Request payload: \(input)")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: input, options: [])
        } catch {
            print("❌ Failed to encode request body: \(error)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle no data
            guard let data = data else {
                print("❌ No data received: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            // Log HTTP response code
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
            }

            // Print raw server response
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("📈 Raw JSON response:\n\(rawJSON)")
            }

            do {
                let decoded = try JSONDecoder().decode([String: [Recommendation]].self, from: data)
                print("✅ Successfully decoded \(decoded["recommendations"]?.count ?? 0) recommendations.")
                completion(decoded["recommendations"])
            } catch {
                print("❌ Failed to decode response: \(error)")
                completion(nil)
            }

        }.resume()
    }
}
