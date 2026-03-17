import SwiftUI
import SwiftData

struct CollectionView: View {
    // TODO: Inject CollectionViewModel

    var body: some View {
        NavigationStack {
            Text("Your Collection")
                .font(.title)
                .foregroundStyle(.secondary)
                .navigationTitle("Collection")
        }
    }
}

#Preview {
    CollectionView()
}
