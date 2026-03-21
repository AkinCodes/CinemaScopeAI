import SwiftUI

struct CinemaScopeAIInputForm: View {
    @Bindable var viewModel: CinemaScopeAIViewModel
    @Binding var showForm: Bool

    var body: some View {
        if showForm {
            VStack(spacing: 16) {
                Text("CinemaScopeAI")
                    .font(.title)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                TextField("Release Year", text: $viewModel.releaseYear)
                    .keyboardType(.numberPad)
                    .accessibilityLabel("Release year")
                    .accessibilityHint("Enter the release year for recommendations")
                    .accessibilityIdentifier("releaseYearField")

                TextField("Duration (e.g. 90 min, 2 Seasons)", text: $viewModel.durationText)
                    .accessibilityLabel("Duration")
                    .accessibilityHint("Enter the duration, for example 90 min or 2 Seasons")
                    .accessibilityIdentifier("durationField")

                TextField("Type (e.g. Movie, TV Show)", text: $viewModel.type)
                    .accessibilityLabel("Content type")
                    .accessibilityHint("Enter Movie or TV Show")
                    .accessibilityIdentifier("typeField")

                TextField("Rating (e.g. PG-13, TV-MA)", text: $viewModel.rating)
                    .accessibilityLabel("Content rating")
                    .accessibilityHint("Enter the content rating like PG-13 or TV-MA")
                    .accessibilityIdentifier("ratingField")

                Button(action: {
                    viewModel.fetchRecommendations()
                    showForm = false
                }) {
                    Text("Get Recommendations")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .accessibilityLabel("Get recommendations")
                .accessibilityHint("Fetches movie recommendations based on your criteria")
                .accessibilityIdentifier("getRecommendationsButton")
                .padding(.top)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}
