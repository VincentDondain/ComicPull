import SwiftUI

struct ComicCardView: View {
    let title: String
    let issueNumber: String
    let publisher: String?
    let coverURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            CoverImageView(url: coverURL)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(title)
                .font(.headline)
                .lineLimit(1)

            Text("#\(issueNumber)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let publisher {
                Text(publisher)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
