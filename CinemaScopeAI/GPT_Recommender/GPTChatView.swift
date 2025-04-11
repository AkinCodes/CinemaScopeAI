import SwiftUI

struct GPTChatView: View {
    @StateObject private var viewModel = GPTChatViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextEditor(text: $viewModel.currentInput)
                    .frame(height: 120)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                
                Button("Ask GPT & Recommend") {
                    Task {
                        await viewModel.sendMessage()
                    }
                }
                .disabled(viewModel.currentInput.isEmpty)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                if viewModel.isLoading {
                    ProgressView("Loading...").padding()
                } else if let error = viewModel.errorMessage {
                    Text("\(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                // Recommendations List
                if !viewModel.recommendations.isEmpty {
                    List(viewModel.recommendations) { movie in
                        NavigationLink(destination: CinemScopeAIDetailView(movie: movie)) {
                            HStack {
                                // Movie Poster
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
                    .refreshable {
                        await viewModel.sendMessage()
                    }
                } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                    Text("Start by asking for a movie recommendation")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("🎬 Ask CinemaScopeAI")
        }
    }
}
