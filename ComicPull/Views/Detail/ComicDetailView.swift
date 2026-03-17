import SwiftUI

struct ComicDetailView: View {
    let comicID: Int

    var body: some View {
        ScrollView {
            Text("Comic Detail")
                .font(.title)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Details")
    }
}
