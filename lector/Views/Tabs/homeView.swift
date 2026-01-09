import SwiftUI

/// Thin wrapper to preserve tab routing if older code referenced `homeView`.
/// The real implementation is `Views/Home/HomeView.swift`.
struct homeView: View {
  var body: some View {
    HomeView()
  }
}

#Preview {
  homeView()
    .environmentObject(PreferencesViewModel())
}
