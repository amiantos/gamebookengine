//
//  GameListCard.swift
//  GamebookEngine
//

import SwiftUI

struct GameListCard: View {
    @ObservedObject var game: Game
    var onAction: (GameListAction) -> Void

    @State private var frameInWindow: CGRect = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(game.name)
                .font(.title)
                .foregroundStyle(.primary)

            Text(game.author)
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            if let about = game.about, !about.isEmpty {
                Text(about)
                    .font(.subheadline)
                    .foregroundStyle(Color("text"))
                    .lineLimit(4)
                    .padding(.top, 16)
            }
            Spacer(minLength: 20)
            controls
        }
        .multilineTextAlignment(.leading)
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .gameListCardBackground()
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onTapGesture { onAction(.play(game)) }
        .contextMenu {
            Button("Play", systemImage: "play") { onAction(.play(game)) }
            Button("Edit", systemImage: "pencil") { onAction(.edit(game)) }
            secondaryActions
        }
        .background(
            GeometryReader { proxy in
                Color.clear.preference(key: CardFramePreferenceKey.self, value: proxy.frame(in: .global))
            }
        )
        .onPreferenceChange(CardFramePreferenceKey.self) { frameInWindow = $0 }
        .accessibilityElement(children: .contain)
    }

    private var controls: some View {
        HStack(spacing: 10) {
            Button { onAction(.play(game)) } label: {
                Label("Play", systemImage: "play.fill")
                    .lineLimit(1)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .gameListControlBackground()
            }
            .accessibilityLabel("Play \(game.name)")

            Button { onAction(.edit(game)) } label: {
                Label("Edit", systemImage: "pencil")
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
                    .gameListControlBackground()
            }

            Menu {
                secondaryActions
            } label: {
                Label("More", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
                    .gameListControlBackground()
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color("button"))
    }

    @ViewBuilder
    private var secondaryActions: some View {
        Menu("Export", systemImage: "square.and.arrow.up") {
            ForEach(GameExportFormat.allCases) { format in
                Button(format.title) {
                    onAction(.export(game, format, sourceRect: frameInWindow))
                }
            }
        }

        Divider()
        
        Button("Delete", systemImage: "trash", role: .destructive) {
            onAction(.delete(game))
        }
    }
}

private struct CardFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
