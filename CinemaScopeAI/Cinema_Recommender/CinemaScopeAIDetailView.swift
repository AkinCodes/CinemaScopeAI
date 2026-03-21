import SwiftUI

struct CinemaScopeAIDetailView: View {
    let movie: Recommendation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Poster
                AsyncImage(url: URL(string: movie.poster_url ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    case .failure:
                        Image(systemName: "film.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .padding(40)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color(UIColor.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    @unknown default:
                        EmptyView()
                    }
                }
                .accessibilityLabel("Movie poster for \(movie.title)")
                .accessibilityIdentifier("detailPoster")

                // MARK: - Title
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                // MARK: - Metadata
                VStack(alignment: .leading, spacing: 5) {
                    Label(movie.genre, systemImage: "theatermasks")
                        .accessibilityLabel("Genre: \(movie.genre)")
                    Label(movie.director, systemImage: "person.fill")
                        .accessibilityLabel("Director: \(movie.director)")
                    Label("Released: \(String(movie.release_year))", systemImage: "calendar")
                        .accessibilityLabel("Released in \(String(movie.release_year))")
                    Label("Score: \(String(format: "%.1f", movie.score * 10))/10", systemImage: "star.fill")
                        .accessibilityLabel("Score: \(String(format: "%.1f", movie.score * 10)) out of 10")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                // MARK: - Summary
                Text("Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                    .accessibilityAddTraits(.isHeader)

                Text(movie.summary.isEmpty ? "No summary available." : movie.summary)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle("Movie Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
