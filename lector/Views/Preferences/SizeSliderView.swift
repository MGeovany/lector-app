import SwiftUI

struct SizeSliderView: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let valueText: (Double) -> String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.parkinsansBold(size: 13))
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.85) : AppColors.matteBlack.opacity(0.85))
                Spacer()
                Text(valueText(value))
                    .font(.parkinsansSemibold(size: 13))
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.55) : .secondary)
            }

            Slider(value: $value, in: range, step: step)
                .tint(colorScheme == .dark ? Color.white.opacity(0.85) : AppColors.matteBlack)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.10) : Color(.separator).opacity(0.6), lineWidth: 1)
        )
    }
}
