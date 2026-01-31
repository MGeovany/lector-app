import SwiftUI

struct ReaderAskAIState {
  var prompt: String = ""
  var messages: [ReaderChatMessage] = []

  mutating func send(_ text: String) {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }

    messages.append(.init(role: .user, text: trimmed))
    prompt = ""

    messages.append(.init(role: .assistant, text: "Got it. (wire your AI call here)"))
  }
}

struct ReaderChatMessage: Identifiable, Equatable {
  enum Role {
    case user
    case assistant
  }

  let id = UUID()
  let role: Role
  let text: String
}

struct ReaderSettingsAskAIView: View {
  @EnvironmentObject private var preferences: PreferencesViewModel

  @Binding var askAI: ReaderAskAIState
  let onBack: () -> Void

  @FocusState private var isFocused: Bool

  var body: some View {
    let hasMessages = !askAI.messages.isEmpty

    VStack(spacing: hasMessages ? 12 : 0) {
      if hasMessages {
        messageList
          .frame(maxHeight: .infinity)
      }

      composer
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: hasMessages ? .top : .bottom)
    .padding(.horizontal, 20)
    .padding(.top, hasMessages ? 8 : 0)
    .padding(.bottom, 12)
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
        isFocused = true
      }
    }
  }

  private var messageList: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(spacing: 12) {
          ForEach(askAI.messages) { message in
            messageRow(for: message)
              .id(message.id)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.top, 6)
        .padding(.bottom, 6)
      }
      .onAppear { scrollToBottom(proxy) }
      .onChange(of: askAI.messages) { _, _ in scrollToBottom(proxy) }
    }
  }

  private var composer: some View {
    HStack(spacing: 10) {
      HStack(spacing: 10) {
        TextField("Ask something", text: $askAI.prompt, axis: .vertical)
          .textFieldStyle(.plain)
          .font(.parkinsans(size: 15, weight: .regular))
          .foregroundStyle(preferences.theme.surfaceText.opacity(0.95))
          .focused($isFocused)
          .lineLimit(1...4)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .background(inputBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

      Button {
        let text = askAI.prompt
        withAnimation(.spring(response: 0.30, dampingFraction: 0.88)) {
          askAI.send(text)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
          isFocused = true
        }
      } label: {
        Image(systemName: "arrow.up")
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(preferences.theme.surfaceText.opacity(canSend ? 0.92 : 0.35))
          .frame(width: 38, height: 38)
          .background(preferences.theme.surfaceText.opacity(0.09), in: Circle())
      }
      .buttonStyle(.plain)
      .disabled(!canSend)
    }
  }

  private var canSend: Bool {
    !askAI.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private var inputBackground: some ShapeStyle {
    if preferences.theme == .night {
      return AnyShapeStyle(Color.white.opacity(0.08))
    }
    return AnyShapeStyle(Color.black.opacity(0.05))
  }

  private func messageRow(for message: ReaderChatMessage) -> some View {
    HStack {
      if message.role == .assistant {
        messageBubble(message, isUser: false)
        Spacer(minLength: 20)
      } else {
        Spacer(minLength: 20)
        messageBubble(message, isUser: true)
      }
    }
  }

  private func messageBubble(_ message: ReaderChatMessage, isUser: Bool) -> some View {
    Text(message.text)
      .font(.parkinsans(size: 14, weight: .regular))
      .foregroundStyle(isUser ? userTextColor : preferences.theme.surfaceText.opacity(0.92))
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .background(
        bubbleBackground(isUser: isUser), in: RoundedRectangle(cornerRadius: 16, style: .continuous)
      )
      .frame(maxWidth: 420, alignment: isUser ? .trailing : .leading)
  }

  private func bubbleBackground(isUser: Bool) -> some ShapeStyle {
    if isUser {
      return AnyShapeStyle(preferences.theme.accent)
    }
    let opacity = preferences.theme == .night ? 0.14 : 0.08
    return AnyShapeStyle(preferences.theme.surfaceText.opacity(opacity))
  }

  private var userTextColor: Color {
    if preferences.theme == .night {
      return Color.black.opacity(0.85)
    }
    return Color.white
  }

  private func scrollToBottom(_ proxy: ScrollViewProxy) {
    guard let last = askAI.messages.last else { return }
    DispatchQueue.main.async {
      withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
        proxy.scrollTo(last.id, anchor: .bottom)
      }
    }
  }
}
