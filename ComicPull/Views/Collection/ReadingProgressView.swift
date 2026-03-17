import SwiftUI

struct ReadingProgressView: View {
    let seriesName: String
    let readCount: Int
    let totalCount: Int

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(readCount) / Double(totalCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(seriesName)
                .font(.headline)

            ProgressView(value: progress) {
                Text("\(readCount)/\(totalCount) read")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .tint(progress >= 1.0 ? .green : .accentColor)
        }
    }
}
