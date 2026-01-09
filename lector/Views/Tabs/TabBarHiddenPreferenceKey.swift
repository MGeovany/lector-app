import SwiftUI

/// Preference used to hide/show the custom tab bar rendered by `MainTabView`.
/// Default is `false` (tab bar visible).
struct TabBarHiddenPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        // If any child requests hiding the tab bar, hide it.
        value = value || nextValue()
    }
}

