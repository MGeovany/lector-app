import SwiftUI

struct ReaderBottomPagerView: View {
  @EnvironmentObject private var preferences: PreferencesViewModel

  let currentIndex: Int
  let totalPages: Int
  let onPrevious: () -> Void
  let onNext: () -> Void

  private var canGoPrevious: Bool { currentIndex > 0 }
  private var canGoNext: Bool { currentIndex < max(0, totalPages - 1) }
  private let hitWidth: CGFloat = 44
  private let hitHeight: CGFloat = 40

  var body: some View {
    HStack(spacing: 8) {
      Button {
        withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
          onPrevious()
        }
      } label: {
        Image(systemName: "chevron.left")
          .font(.system(size: 14, weight: .semibold))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(preferences.theme.surfaceText.opacity(canGoPrevious ? 0.22 : 0.06))
          // Keep a large hit target, but visually minimal.
          .frame(width: hitWidth, height: hitHeight)
      }
      .buttonStyle(ReaderPagerCapsuleButtonStyle(isEnabled: canGoPrevious, theme: preferences.theme))
      .disabled(!canGoPrevious)
      .accessibilityLabel("Previous page")
      .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in }.onEnded { _ in })

      Spacer(minLength: 0)

      Text("\(max(1, currentIndex + 1))/\(max(1, totalPages))")
        .font(.system(size: 11, weight: .semibold))
        .monospacedDigit()
        .foregroundStyle(preferences.theme.surfaceSecondaryText.opacity(0.35))
        .contentTransition(.numericText())
        .accessibilityLabel("Page \(max(1, currentIndex + 1)) of \(max(1, totalPages))")
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)

      Spacer(minLength: 0)

      Button {
        withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
          onNext()
        }
      } label: {
        Image(systemName: "chevron.right")
          .font(.system(size: 14, weight: .semibold))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(preferences.theme.surfaceText.opacity(canGoNext ? 0.22 : 0.06))
          // Keep a large hit target, but visually minimal.
          .frame(width: hitWidth, height: hitHeight)
      }
      .buttonStyle(ReaderPagerCapsuleButtonStyle(isEnabled: canGoNext, theme: preferences.theme))
      .disabled(!canGoNext)
      .accessibilityLabel("Next page")
      .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in }.onEnded { _ in })
    }
    .padding(.horizontal, 30)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(preferences.theme.surfaceBackground)
    )
  }
}

/// Capsule button: subtle background + border + press feedback.
private struct ReaderPagerCapsuleButtonStyle: ButtonStyle {
  let isEnabled: Bool
  let theme: ReadingTheme

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .contentShape(Capsule(style: .continuous))
      .background(
        Capsule(style: .continuous)
          .fill(theme.surfaceText.opacity(theme == .day ? 0.04 : 0.06))
      )
      .overlay(
        Capsule(style: .continuous)
          .stroke(
            theme.surfaceText.opacity(isEnabled ? (theme == .day ? 0.10 : 0.14) : 0.06),
            lineWidth: 1
          )
      )
      .opacity(configuration.isPressed ? 0.65 : 1.0)
      .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
      .animation(.spring(response: 0.16, dampingFraction: 0.9), value: configuration.isPressed)
  }
}
