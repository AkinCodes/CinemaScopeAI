import SwiftUI

struct CinemaScopeAIInputForm: View {
    @ObservedObject var viewModel: CinemaScopeAIViewModel
    @Binding var showForm: Bool

    var body: some View {
        if showForm {
            VStack(spacing: 16) {
                Text("CinemaScopeAI")
                    .font(.title)
                    .fontWeight(.bold)

                TextField("Release Year", text: $viewModel.releaseYear)
                    .keyboardType(.numberPad)

                TextField("Duration (e.g. 90 min, 2 Seasons)", text: $viewModel.durationText)

                TextField("Type (e.g. Movie, TV Show)", text: $viewModel.type)

                TextField("Rating (e.g. PG-13, TV-MA)", text: $viewModel.rating)

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
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}
