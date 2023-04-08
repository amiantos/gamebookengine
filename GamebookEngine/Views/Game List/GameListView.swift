//
//  GameListView.swift
//  GamebookEngine
//
//  Created by Brad Root on 4/7/23.
//  Copyright © 2023 Brad Root. All rights reserved.
//

import SwiftUI

struct GameCard: View {
    let game: Game

    var body: some View {
        HStack {
            VStack {
                Text(game.name)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(EdgeInsets(top: 22, leading: 22, bottom: 4, trailing: 22))
                Text(game.author)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.secondary)
                    .padding(EdgeInsets(top: 0, leading: 22, bottom: 8, trailing: 22))
                Text(game.about ?? "")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 22, bottom: 8, trailing: 22))
                Text("Play Gamebook")
                    .fontWeight(.medium)
                    .foregroundColor(Color("button"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(EdgeInsets(top: 6, leading: 0, bottom: 8, trailing: 0))
                    .background(Color("background"))
                    .cornerRadius(5)
                    .padding(EdgeInsets(top: 0, leading: 22, bottom: 22, trailing: 22))


            }
            .background(Color("containerBackground"))
            .foregroundColor(Color("text"))
            .cornerRadius(10)
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 0))
            .shadow(color: Color(white: 0, opacity: 0.1), radius: 10)



            VStack {
                Button {
                    print("Play")
                } label: {
                    Image("play")
                        .foregroundColor(Color("button"))
                }.frame(width: 50, height: 30, alignment: .center)

                Button {
                    print("Play")
                } label: {
                    Image("edit")
                        .foregroundColor(Color("button"))
                }.frame(width: 50, height: 30, alignment: .center)

                Button {
                    print("Play")
                } label: {
                    Image("export")
                        .foregroundColor(Color("button"))
                }.frame(width: 50, height: 30, alignment: .center)

                Button {
                    print("Play")
                } label: {
                    Image("delete")
                        .foregroundColor(Color("button"))
                }.frame(width: 50, height: 30, alignment: .center)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
        }
    }
}


struct GameListView: View {
    @State private var games: [Game] = []

    var body: some View {
        NavigationStack {
            List(games, id: \.uuid) { game in
                GameCard(game: game)
                    .listRowBackground(Color("background"))
//                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .foregroundColor(Color("text"))
            .background(Color("background"))
            .scrollContentBackground(.hidden)
            .navigationTitle("Your Gamebooks")
            .navigationBarTitleTextColor(.secondary)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("About tapped!")
                    } label: {
                        Image("add")
                            .foregroundColor(Color("button"))
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Help") {
                        print("Help tapped!")
                    }.foregroundColor(Color("button"))
                }
            }
        }
        .onAppear(perform: fetchGames)
    }

    func fetchGames() {
        GameDatabase.standard.fetchGames { games in
            if let games = games {
                DispatchQueue.main.async {
                    self.games = games
                }
            }
        }
    }
}

struct GameListView_Previews: PreviewProvider {
    static var previews: some View {
        GameListView()
    }
}
