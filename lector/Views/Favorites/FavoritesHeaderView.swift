//
//  FavoritesHeaderView.swift
//  lector
//
//  Created by Marlon Castro on 8/1/26.
//

import SwiftUI

struct FavoritesHeaderView: View {
  @Environment(\.colorScheme) private var colorScheme
  let filteredFavorites: [Book]

  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      Text("My Favorites")
        .font(.parkinsans(size: 20, weight: .regular))
        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.60) : .secondary)

      Text("Books")
        .font(.parkinsansMedium(size: 83))
        .foregroundStyle(
          colorScheme == .dark ? Color.white.opacity(0.75) : AppColors.matteBlack)
    }
    .frame(maxWidth: .infinity, alignment: .center)
  }
}
