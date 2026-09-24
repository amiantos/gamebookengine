//
//  View+GameListCard.swift
//  GamebookEngine
//

import SwiftUI

extension View {
    /// Matches `ContainerView`: rounded white card with a soft shadow.
    func gameListCardBackground() -> some View {
        background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("containerBackground"))
                .shadow(color: .black.opacity(0.1), radius: 10)
        )
    }

    /// Rounded fill used behind buttons that live inside a card.
    func gameListControlBackground() -> some View {
        background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color("background"))
        )
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
