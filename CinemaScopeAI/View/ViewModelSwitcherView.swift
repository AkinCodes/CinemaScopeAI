import SwiftUI

struct ViewModelSwitcherView: View {
    @State private var selectedMode: InputMode = .manual

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Mode", selection: $selectedMode) {
                    ForEach(InputMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .accessibilityLabel("Recommendation mode selector")
                .accessibilityHint("Switch between manual input and GPT-powered recommendations")
                .accessibilityIdentifier("modePicker")

                Group {
                    if selectedMode == .manual {
                        CinemaScopeAIView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    } else {
                        GPTChatView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.smooth(duration: 0.35), value: selectedMode)
            }
            .navigationTitle("CinemaScopeAI")
            .navigationDestination(for: Recommendation.self) { movie in
                CinemaScopeAIDetailView(movie: movie)
            }
        }
    }
}

enum InputMode: String, CaseIterable {
    case manual = "Manual"
    case gpt = "GPT"
}

#Preview {
    ViewModelSwitcherView()
}
