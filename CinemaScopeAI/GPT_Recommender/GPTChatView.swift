import SwiftUI

struct GPTChatView: View {
    @State private var viewModel = GPTChatViewModel()
    @State private var showErrorAlert = false
    @State private var searchText = ""

    private var filteredRecommendations: [Recommendation] {
        guard !searchText.isEmpty else { return viewModel.recommendations }
        return viewModel.recommendations.filter { movie in
            movie.title.localizedCaseInsensitiveContains(searchText) ||
            movie.genre.localizedCaseInsensitiveContains(searchText) ||
            movie.director.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Input Area
            TextEditor(text: $viewModel.currentInput)
                .frame(height: 120)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
                .accessibilityLabel("Movie recommendation prompt")
                .accessibilityHint("Enter what kind of movies you are looking for")
                .accessibilityIdentifier("gptInputField")

            Button {
                Task {
                    await viewModel.sendMessage()
                }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Ask GPT & Recommend")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityLabel("Ask GPT for recommendations")
            .accessibilityHint("Sends your prompt to GPT to get movie recommendations")
            .accessibilityIdentifier("askGPTButton")

            // MARK: - Content Area
            if viewModel.isLoading {
                skeletonLoadingView
            } else if let error = viewModel.errorMessage, viewModel.recommendations.isEmpty {
                ContentUnavailableView {
                    Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.retry()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("retryButton")
                }
            } else if !viewModel.recommendations.isEmpty {
                List(filteredRecommendations) { movie in
                    NavigationLink(value: movie) {
                        MovieCardView(movie: movie)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .accessibilityLabel("\(movie.title), \(movie.genre), directed by \(movie.director)")
                    .accessibilityHint("Double tap to view details")
                    .accessibilityIdentifier("gptMovieCard_\(movie.title)")
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Filter by title, genre, or director")
                .refreshable {
                    await viewModel.sendMessage()
                }
                .animation(.smooth, value: viewModel.recommendations)
            } else {
                ContentUnavailableView {
                    Label("Discover Movies", systemImage: "film.stack")
                } description: {
                    Text("Describe what kind of movie you're in the mood for and let AI find the perfect picks for you.")
                }
                .accessibilityIdentifier("emptyStateView")
            }

            Spacer(minLength: 0)
        }
        .padding()
        .alert("Error", isPresented: $showErrorAlert) {
            Button("Retry") {
                Task {
                    await viewModel.retry()
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            showErrorAlert = newValue != nil && !viewModel.recommendations.isEmpty
        }
    }

    // MARK: - Skeleton Loading

    private var skeletonLoadingView: some View {
        List(0..<5, id: \.self) { _ in
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 120)

                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 16)
                        .frame(maxWidth: 180)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 12)
                        .frame(maxWidth: 120)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 12)
                        .frame(maxWidth: 200)
                }
            }
            .padding(.vertical, 8)
            .redacted(reason: .placeholder)
        }
        .accessibilityLabel("Loading recommendations")
    }
}

#Preview {
    GPTChatView()
}
