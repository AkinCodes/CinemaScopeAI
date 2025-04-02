import SwiftUI

struct CinemScopeAIDetailView: View {
    let movie: Recommendation
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: movie.poster_url ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure(_):
                        Image(systemName: "film.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .padding(20)
                    @unknown default:
                        Image(systemName: "film.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .padding(20)
                    }
                }
                .frame(width: 80, height: 120)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Genre, Director, Release Year
                VStack(alignment: .leading, spacing: 5) {
                    Text("Genre: \(movie.genre)")
                    Text("Directed by: \(movie.director)")
                    Text("Released: \(movie.release_year)")
                    Text("Score: \(String(format: "%.1f", movie.score * 10))/10")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                
                // Movie Summary
                Text("📝 Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text(movie.summary.isEmpty ? "No summary available." : movie.summary)
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Button(action: {
                    print("Trailer button tapped")
                }) {
                    Text("🎥 Watch Trailer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Movie Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
