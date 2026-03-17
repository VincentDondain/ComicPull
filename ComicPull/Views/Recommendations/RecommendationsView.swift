import SwiftUI

struct RecommendationsView: View {
    // TODO: Inject RecommendationsViewModel

    var body: some View {
        NavigationStack {
            Text("Recommendations powered by AI")
                .font(.title3)
                .foregroundStyle(.secondary)
                .navigationTitle("For You")
        }
    }
}

#Preview {
    RecommendationsView()
}
