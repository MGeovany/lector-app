//
//  lectorApp.swift
//  lector
//
//  Created by Marlon Castro on 5/1/26.
//

import SwiftUI

#if canImport(Sentry)
  import Sentry
#endif

@main
struct lectorApp: App {
  @StateObject private var preferences = PreferencesViewModel()
  @StateObject private var subscription = SubscriptionStore()

  init() {
    FontRegistrar.registerCinzelDecorativeIfNeeded()
    FontRegistrar.registerParkinsansIfNeeded()

    #if canImport(Sentry)
      SentrySDK.start { options in
        options.dsn =
          "https://d41087119879e606dd86848f8f1d864e@o4510713078218752.ingest.us.sentry.io/4510713082413056"

        #if DEBUG
          options.environment = "debug"
          options.debug = true
        #else
          options.environment = "release"
          options.debug = false
        #endif

        let short =
          (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "0"
        let build =
          (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "0"
        let bundleID = Bundle.main.bundleIdentifier ?? "lector"
        options.releaseName = "\(bundleID)@\(short)+\(build)"

        // Focus on crashes/errors; keep performance sampling off by default.
        options.tracesSampleRate = 0.0
        options.attachStacktrace = true
      }

      let crumb = Breadcrumb(level: .info, category: "app")
      crumb.message = "app_launched"
      SentrySDK.addBreadcrumb(crumb)
    #endif
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        // Base typography for the whole app (views can override with `.font(...)`).
        .environment(\.font, .custom("Parkinsans-Regular", size: 16))
        .environmentObject(preferences)
        .environmentObject(subscription)
    }
  }
}
