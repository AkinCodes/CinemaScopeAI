import SwiftUI

struct CinemaScopeAIView: View {
    @StateObject private var viewModel = CinemaScopeAIViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Fetching Recommendations...")
                } else {
                    List(viewModel.recommendations) { movie in
                        NavigationLink(destination: CinemScopeAIDetailView(movie: movie)) {
                            HStack {
                                // Movie Poster
                                AsyncImage(url: URL(string: movie.poster_url ?? "")) { image in
                                    image.resizable().aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 80, height: 120)
                                .cornerRadius(8)
                                
                                // Movie Details
                                VStack(alignment: .leading) {
                                    Text(movie.title)
                                        .font(.headline)
                                    Text("Genre: \(movie.genre)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Directed by: \(movie.director)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Released: \(movie.release_year)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(movie.summary)
                                        .font(.caption)
                                        .lineLimit(3)
                                }
                                Spacer()
                            }
                            .padding(8)
                        }
                    }
                }
            }
            .navigationTitle("Movie Recommendations")
            .onAppear {
                viewModel.fetchRecommendations()
            }
            .refreshable {
                viewModel.fetchRecommendations()
            }
        }
    }
}


#Preview {
    CinemaScopeAIView()
}
