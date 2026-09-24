//
//  GameListView.swift
//  GamebookEngine
//

import SwiftUI

struct GameListView: View {
    @ObservedObject var model: GameListModel
    var onAction: (GameListAction) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 230), spacing: 20, alignment: .top)
    ]

    @Namespace private var editorZoom

    var body: some View {
        Group {
            if model.isEmpty {
                GameListEmptyView(onAction: onAction)
            } else {
                grid
            }
        }
        .background(Color("background").ignoresSafeArea())
        .fullScreenCover(item: $model.editingGame, onDismiss: { model.fetchGames() }) { game in
            GameEditorView(game: game) { model.editingGame = nil }
                .ignoresSafeArea()
                .interactiveDismissDisabled()
                .gameEditorZoomTransition(sourceID: game.objectID, in: editorZoom)
        }
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(model.games, id: \.objectID) { game in
                    GameListCard(game: game, onAction: onAction)
                        .gameEditorZoomSource(id: game.objectID, in: editorZoom)
                }
            }
            .animation(.spring(), value: model.games)
            .padding(20)
            .frame(maxWidth: .infinity)
        }
    }
}
