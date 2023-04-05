//
//  IntroductionView.swift
//  GamebookEngine
//
//  Created by Brad Root on 4/5/23.
//  Copyright © 2023 Brad Root. All rights reserved.
//

import CardStack
import SwiftUI

struct CardData: Identifiable {
    var id = UUID()
    let title: String
    let text: String
    let image: Image
}

struct CardView: View {
    let data: CardData

    var body: some View {
        VStack {
            Text(self.data.title)
                .font(.largeTitle)
                .padding()
            Spacer()
            GeometryReader { geo in
                self.data.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.8)
                    .frame(width: geo.size.width, height: geo.size.height)
            }
            Spacer()
            Text(self.data.text)
                .lineLimit(4)
                .font(.body)
                .minimumScaleFactor(0.5)
                .padding(24)
        }
        .background(Color(UIColor(named: "containerBackground")!))
        .foregroundColor(.black)
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}

struct IntroductionView: View {
    @State var cards: [CardData] = [
//        CardData(
//            title: "Salutations", text: "Welcome to Gamebook Engine, the all-in-one app for creating "
//                + "and playing interactive stories, entirely on your phone or "
//                + "tablet. No account needed, no cloud services, total privacy.", image: Image("magic-icon")
//        ),
        CardData(
            title: "Create", text: "Edit gamebooks or create your own! Gamebook Engine has "
                + "a fully-featured interface for creating full length choosable path adventure "
                + "games where readers get to influence the story.", image: Image("create-icon")
        ),
        CardData(
            title: "Play", text: "And of course, you can play gamebooks! Gamebook Engine comes "
                + "with a few simple games built in that you can play, but it’s more fun to play "
                + "games made by friends and family.", image: Image("play-icon")
        ),
        CardData(
            title: "Share", text: "Stories written with Gamebook Engine can be exported to a "
                + "plain text (JSON formatted) file that you can send to your friends. To play, they "
                + "just need their own copy of Gamebook Engine.", image: Image("share-icon")
        ),
    ]

    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to\n Gamebook Engine")
                .multilineTextAlignment(.center)
                .font(.title)
            Text("Gamebook Engine is an all-in-one app for creating "
                + "and playing interactive stories, entirely on your device. "
                + "No signup required, and no data is ever collected, ensuring total privacy.")
                .font(.body)
                .minimumScaleFactor(0.5)
                .padding()
            CardStack(
                direction: LeftRight.direction,
                data: cards,
                onSwipe: { text, direction in
                    print("Swiped \(text) to \(direction)")
                    self.cards.append(text)
                },
                content: { data, _, _ in
                    CardView(data: data)
                }
            )
            .padding()
            .scaledToFit()
            .frame(alignment: .center)
            .frame(maxWidth: 400)
            Spacer()
            Button(action: {
                print("Do Stuff")
            }, label: {
                Text("Get Started Now")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(Color.white)
                    .cornerRadius(100)
            })
            Spacer()
        }
        .background(Color(UIColor(named: "background")!))
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
