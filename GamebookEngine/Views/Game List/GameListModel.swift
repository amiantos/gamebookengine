//
//  GameListModel.swift
//  GamebookEngine
//

import Foundation

final class GameListModel: ObservableObject {
    @Published private(set) var games: [Game] = []
    @Published private(set) var hasLoaded = false
    @Published var editingGame: Game?

    func fetchGames() {
        GameDatabase.standard.fetchGames { games in
            guard let games = games else { return }
            DispatchQueue.main.async {
                self.games = games
                self.hasLoaded = true
            }
        }
    }

    var isEmpty: Bool {
        hasLoaded && games.isEmpty
    }

    func deleteGame(_ game: Game) {
        games.removeAll { $0 == game }
        GameDatabase.standard.deleteGame(game) { remainingGame in
            guard remainingGame != nil else { return }
            self.fetchGames()
        }
    }
}
