import Foundation

@MainActor
class CinemaScopeAIViewModel: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    @Published var isLoading = false
    
    func fetchRecommendations() {
        isLoading = true
        CinemaScopeAIService.shared.fetchRecommendations { [weak self] result in
            DispatchQueue.main.async {
                self?.recommendations = result ?? []
                self?.isLoading = false
            }
        }
    }
}
