import Foundation

enum AppConfiguration {
    static let cinemaBaseURL: URL = {
        guard let url = URL(string: "https://cinemascope-api.onrender.com") else {
            fatalError("Invalid cinema base URL configuration")
        }
        return url
    }()
    static let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
    static let openAIModel = "gpt-3.5-turbo"
}
