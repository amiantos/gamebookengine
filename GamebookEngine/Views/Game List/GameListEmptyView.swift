//
//  GameListEmptyView.swift
//  GamebookEngine
//

import SwiftUI

struct GameListEmptyView: View {
    var onAction: (GameListAction) -> Void

    private let title = "No Gamebooks"
    private let systemImage = "books.vertical"
    private let message = "Create a gamebook, import one from a file, or add the examples. Not sure where to start? Press the ? button."

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(title)
                .font(.title2.bold())

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            actions
                .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var actions: some View {
        Button("Add Gamebook", systemImage: "plus") { onAction(.addGame) }
            .buttonStyle(.borderedProminent)
            
        Button("Get Help") { onAction(.help) }
    }
}
