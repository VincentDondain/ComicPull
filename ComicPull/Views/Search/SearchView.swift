import SwiftUI

struct SearchView: View {
    // TODO: Inject SearchViewModel

    var body: some View {
        NavigationStack {
            Text("Search comics")
                .font(.title3)
                .foregroundStyle(.secondary)
                .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
}
