//
//  GameExportFormat.swift
//  GamebookEngine
//

enum GameExportFormat: CaseIterable, Identifiable {
    case gbook
    case html

    var id: Self { self }

    var title: String {
        switch self {
        case .gbook: return "Export as .gbook"
        case .html: return "Export as .html"
        }
    }
}
