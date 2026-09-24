//
//  GameListAction.swift
//  GamebookEngine
//

import CoreGraphics

enum GameListAction {
    case play(Game)
    case edit(Game)
    case export(Game, GameExportFormat, sourceRect: CGRect)
    case delete(Game)
    case addGame
    case help
}
