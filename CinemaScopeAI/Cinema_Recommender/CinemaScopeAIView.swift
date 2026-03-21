import SwiftUI

struct CinemaScopeAIView: View {
    @State private var viewModel = CinemaScopeAIViewModel()
    @State private var showForm = true
    @State private var showErrorAlert = false
    @State private var searchText = ""

    private var filteredRecommendations: [Recommendation] {
        guard !searchText.isEmpty else { return viewModel.recommendations }
        return viewModel.recommendations.filter { rec in
            rec.title.localizedCaseInsensitiveContains(searchText) ||
            rec.genre.localizedCaseInsensitiveContains(searchText) ||
            rec.director.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack {
            if showForm {
                CinemaScopeAIInputForm(viewModel: viewModel, showForm: $showForm)
            }

            if viewModel.isLoading {
                skeletonLoadingView
            } else if !viewModel.recommendations.isEmpty {
                List(filteredRecommendations) { rec in
                    NavigationLink(value: rec) {
                        MovieCardView(movie: rec)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .accessibilityLabel("\(rec.title), \(rec.genre), directed by \(rec.director)")
                    .accessibilityHint("Double tap to view details")
                    .accessibilityIdentifier("movieCard_\(rec.title)")
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Filter by title, genre, or director")
                .refreshable {
                    viewModel.fetchRecommendations()
                }
                .animation(.smooth, value: viewModel.recommendations)

                startOverButton
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView {
                    Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Retry") {
                        viewModel.retry()
                        showForm = false
                    }
                    .accessibilityIdentifier("retryButton")

                    Button("Start Over") {
                        viewModel.reset()
                        showForm = true
                    }
                    .accessibilityIdentifier("startOverErrorButton")
                }
            } else if !showForm {
                ContentUnavailableView {
                    Label("No Results Found", systemImage: "magnifyingglass")
                } description: {
                    Text("Your search didn't return any recommendations. Try adjusting your criteria.")
                } actions: {
                    Button("Try Again") {
                        viewModel.reset()
                        showForm = true
                    }
                }
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("Retry") {
                viewModel.retry()
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

    // MARK: - Start Over Button

    private var startOverButton: some View {
        Button(action: {
            viewModel.reset()
            showForm = true
        }) {
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 20))
                Text("Start Over")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .accessibilityLabel("Start over")
        .accessibilityHint("Clear results and enter new search criteria")
        .accessibilityIdentifier("startOverButton")
    }
}

#Preview {
    CinemaScopeAIView()
}
