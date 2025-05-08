import SwiftUI

struct CinemaScopeAIView: View {
    @StateObject private var viewModel = CinemaScopeAIViewModel()
    @State private var showForm = true

    var body: some View {
        NavigationView {
            VStack {
                if showForm {
                    CinemaScopeAIInputForm(viewModel: viewModel, showForm: $showForm)
                }

                if viewModel.isLoading {
                    ProgressView("Fetching Recommendations...")
                } else if !viewModel.recommendations.isEmpty {
                    List(viewModel.recommendations) { rec in
                        NavigationLink(destination: CinemScopeAIDetailView(movie: rec)) {
                            HStack {
                                AsyncImage(url: URL(string: rec.poster_url ?? "")) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 80, height: 120)
                                .cornerRadius(8)

                                VStack(alignment: .leading) {
                                    Text(rec.title).font(.headline)
                                    Text("Released: \(rec.release_year)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(rec.summary)
                                        .font(.caption)
                                        .lineLimit(3)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }

                    Button(action: {
                        viewModel.releaseYear = ""
                        viewModel.durationText = ""
                        viewModel.type = ""
                        viewModel.rating = ""
                        viewModel.recommendations = []
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
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("CinemaScopeAI")
        }
    }
}

#Preview {
    CinemaScopeAIView()
}
