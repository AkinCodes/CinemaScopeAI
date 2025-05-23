import SwiftUI

struct ViewModelSwitcherView: View {
    @State private var selectedMode: InputMode = .manual

    var body: some View {
        NavigationView {
            VStack {
                Picker("Mode", selection: $selectedMode) {
                    ForEach(InputMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedMode == .manual {
                    CinemaScopeAIView() // Recommender view
                } else {
                    GPTChatView() // GPT prompt view
                }
            }
            .navigationTitle("🎬 CinemaScopeAI")
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



struct ViewModelSwitcherView2: View {
    @State private var selectedMode: InputMode = .manual

    var body: some View {
        NavigationView {
            VStack {
                Picker("Mode", selection: $selectedMode) {
                    ForEach(InputMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedMode == .manual {
                    GPTChatView()
                } else {
                    CinemaScopeAIView()
                }
            }
            .navigationTitle("Akin")
        }
    }
}
