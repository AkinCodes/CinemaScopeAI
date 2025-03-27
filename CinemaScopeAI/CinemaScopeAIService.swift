import Foundation

class CinemaScopeAIService {
    static let shared = CinemaScopeAIService()
     private let baseURL = URL(string: "https://cinemascope-api.onrender.com")!
    
    func fetchRecommendations(completion: @escaping ([Recommendation]?) -> Void) {
        let endpoint = baseURL.appendingPathComponent("predict/")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "continuous_features": [0.2, 0.9],
            "categorical_features": [1, 7]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Failed to encode request body: \(error)")
            completion(nil)
            return
        }
        

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in request: \(error)")
                print("❌ Error in request: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }

            do {
                let response = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.recommendations) 
                }
            } catch {
                print("Failed to decode response: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
