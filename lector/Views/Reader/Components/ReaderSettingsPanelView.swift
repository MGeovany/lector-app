import SwiftUI

struct ReaderSettingsPanelView: View {
  @EnvironmentObject private var preferences: PreferencesViewModel

  let containerHeight: CGFloat
  @Binding var isPresented: Bool
  @Binding var dragOffset: CGFloat
  @Binding var isLocked: Bool
  @Binding var searchVisible: Bool
  @Binding var searchQuery: String

  @State private var localDragOffset: CGFloat = 0
  @State private var screen: Screen = .main
  @State private var fontPage: Int = 0

  private enum Screen {
    case main
    case textCustomize
  }

  var body: some View {
    VStack(spacing: 0) {
      if isPresented {
        VStack(spacing: 0) {
          header
          ScrollView {
            VStack(spacing: 14) {
              if screen == .main {
                mainSettings
              } else {
                textCustomizeSettings
              }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
          }
        }
        .frame(maxWidth: .infinity)
        .frame(height: containerHeight * 0.55)
        .background(
          preferences.theme == .day
            ? Color(
              #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1.0))
            : preferences.theme == .night
              ? Color(red: 10.0 / 255.0, green: 10.0 / 255.0, blue: 10.0 / 255.0)
              : preferences.theme.surfaceBackground
        )
        .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
        .offset(y: max(0, localDragOffset))
        .animation(nil, value: localDragOffset)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .frame(maxWidth: .infinity, alignment: .bottom)
    .onChange(of: isPresented) { _, showing in
      if !showing {
        dragOffset = 0
        localDragOffset = 0
        screen = .main
        fontPage = 0
      } else {
        localDragOffset = 0
        screen = .main
        fontPage = 0
      }
    }
  }

  private var header: some View {
    VStack(spacing: 0) {
      Image(systemName: "chevron.down")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(preferences.theme.surfaceSecondaryText.opacity(0.40))
        .frame(maxWidth: .infinity)
        .frame(height: 20)
        .contentShape(Rectangle())
        .onTapGesture {
          withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            isPresented = false
            dragOffset = 0
          }
        }

      Text(screen == .main ? "Reader Settings" : "Text Customize")
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(preferences.theme.surfaceSecondaryText.opacity(0.40))
        .padding(.bottom, 20)
    }
    .contentShape(Rectangle())
    .highPriorityGesture(
      DragGesture(minimumDistance: 2)
        .onChanged { value in
          if value.translation.height > 0 {
            localDragOffset = value.translation.height
          }
        }
        .onEnded { _ in
          let finalOffset = localDragOffset
          let threshold: CGFloat = 100

          if finalOffset > threshold {
            dragOffset = 0
            localDragOffset = 0
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
              isPresented = false
            }
          } else {
            dragOffset = 0
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
              localDragOffset = 0
            }
          }
        }
    )
  }

  private var mainSettings: some View {
    let gap: CGFloat = 16

    let themeH: CGFloat = 80
    let searchH: CGFloat = 80
    let tallH: CGFloat = 140
    let bottomH: CGFloat = 80
    let textH: CGFloat = searchH + tallH - bottomH

    let totalH: CGFloat = themeH + gap + searchH + gap + tallH

    return GeometryReader { geo in
      let totalW = geo.size.width
      let leftW = (totalW - gap) * 0.80
      let rightW = (totalW - gap) * 0.20

      let searchColW = rightW
      let textColW = leftW - gap - searchColW

      HStack(alignment: .top, spacing: gap) {
        VStack(spacing: gap) {
          debugBox("Theme")
            .frame(height: themeH)

          HStack(alignment: .top, spacing: gap) {
            VStack(spacing: gap) {
              debugBox("Text")
                .frame(height: textH)

              HStack(spacing: gap) {
                debugBox("Offline")
                  .frame(maxWidth: .infinity)
                  .frame(height: bottomH)

                debugBox("Lock")
                  .frame(maxWidth: .infinity)
                  .frame(height: bottomH)
              }
            }
            .frame(width: textColW)

            VStack(spacing: gap) {
              debugBox("Search")
                .frame(height: searchH)

              debugBox("Text Size")
                .frame(height: tallH)
            }
            .frame(width: searchColW)
          }
        }
        .frame(width: leftW)

        VStack(spacing: gap) {
          debugBox("Voice")
            .frame(height: themeH)

          debugBox("Transitions")
            .frame(height: searchH)

          debugBox("Brightness")
            .frame(height: tallH)
        }
        .frame(width: rightW)
      }
    }
    .frame(height: totalH)
  }

  private func debugBox(_ title: String) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(Color.blue, lineWidth: 3)

      Text(title)
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(Color.blue)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }
  }

  private var textCustomizeSettings: some View {
    VStack(spacing: 16) {
      debugBox("Text Customize Screen")
        .frame(maxWidth: .infinity)
        .frame(height: 220)

      Button {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
          screen = .main
        }
      } label: {
        Text("Back")
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(preferences.theme.surfaceText.opacity(0.92))
          .padding(.horizontal, 18)
          .padding(.vertical, 12)
          .background(
            Capsule(style: .continuous)
              .fill(
                preferences.theme.surfaceText.opacity(preferences.theme == .night ? 0.10 : 0.06))
          )
          .overlay(
            Capsule(style: .continuous)
              .stroke(preferences.theme.surfaceText.opacity(0.12), lineWidth: 1)
          )
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.plain)
      .padding(.top, 6)
    }
  }
}
