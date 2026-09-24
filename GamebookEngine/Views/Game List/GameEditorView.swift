//
//  GameEditorView.swift
//  GamebookEngine
//

import SwiftUI
import UIKit

struct GameEditorView: UIViewControllerRepresentable {
    let game: Game
    var onExit: () -> Void

    func makeUIViewController(context _: Context) -> UINavigationController {
        let gameOverview = GameOverviewViewController()
        gameOverview.game = game
        gameOverview.onExit = onExit
        let navController = UINavigationController(rootViewController: gameOverview)
        navController.navigationBar.tintColor = .secondaryLabel
        return navController
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}
}

extension View {
    @ViewBuilder
    func gameEditorZoomSource(id: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) {
            matchedTransitionSource(id: id, in: namespace) { source in
                source
                    .background(Color("containerBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func gameEditorZoomTransition(sourceID: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) {
            navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            self
        }
    }
}
