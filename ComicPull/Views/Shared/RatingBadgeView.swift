import SwiftUI

struct RatingBadgeView: View {
    let score: Double
    let maxScore: Double

    private var normalizedScore: Double {
        (score / maxScore) * 100
    }

    private var color: Color {
        switch normalizedScore {
        case 75...: .green
        case 50..<75: .yellow
        default: .red
        }
    }

    var body: some View {
        Text(String(format: "%.1f", score))
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
