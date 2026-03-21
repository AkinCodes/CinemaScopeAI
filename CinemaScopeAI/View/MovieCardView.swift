import SwiftUI

struct MovieCardView: View {
    let movie: Recommendation

    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Poster Thumbnail
            AsyncImage(url: URL(string: movie.poster_url ?? "")) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.systemGray5))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.systemGray5))
                        .overlay(
                            Image(systemName: "film.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityLabel("Poster for \(movie.title)")

            // MARK: - Details
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                    .accessibilityAddTraits(.isHeader)

                Text(movie.genre)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Genre: \(movie.genre)")

                Text("Directed by \(movie.director)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Released: \(String(movie.release_year))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Released in \(String(movie.release_year))")

                Text(movie.summary)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .accessibilityLabel("Summary: \(movie.summary)")
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
