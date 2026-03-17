import SwiftUI

struct ReviewSectionView: View {
    let communityRating: Double?
    let userScore: Int?
    let userReviewText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let rating = communityRating {
                HStack {
                    Text("Community")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    RatingBadgeView(score: rating, maxScore: 5.0)
                }
            }

            if let score = userScore {
                HStack {
                    Text("Your Rating")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    RatingBadgeView(score: Double(score), maxScore: 10.0)
                }
            }

            if let text = userReviewText, !text.isEmpty {
                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
