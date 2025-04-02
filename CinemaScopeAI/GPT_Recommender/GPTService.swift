import Foundation

struct GPTRequest: Codable {
    let model: String
    let messages: [GPTMessage]
}

struct GPTMessage: Codable {
    let role: String
    let content: String
}

struct GPTResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

class GPTService {
    static let shared = GPTService()
    private init() {}

    func promptToJSON(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing API Key"])))
            return
        }

        let endpoint = "https://api.openai.com/v1/chat/completions"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let messages = [
            GPTMessage(role: "system", content: "You are a helpful assistant that takes a user's movie preference and returns JSON in the format: {\"continuous_features\": [Float, Float], \"categorical_features\": [Int, Int]}"),
            GPTMessage(role: "user", content: prompt)
        ]

        let requestBody = GPTRequest(model: "gpt-3.5-turbo", messages: messages)

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                return
            }

            do {
                let result = try JSONDecoder().decode(GPTResponse.self, from: data)
                let content = result.choices.first?.message.content ?? ""
                completion(.success(content))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
