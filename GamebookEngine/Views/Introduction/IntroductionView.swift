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
        .background(Color(UIColor(white: 0.95, alpha: 1)))
        .foregroundColor(Color.black)
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}

struct IntroductionView: View {
    @Environment(\.dismiss) var dismiss

    @State var cards: [CardData] = [
        //        CardData(
//            title: "Salutations", text: "Welcome to Gamebook Engine, the all-in-one app for creating "
//                + "and playing interactive stories, entirely on your phone or "
//                + "tablet. No account needed, no cloud services, total privacy.", image: Image("magic-icon")
//        ),
        CardData(
            title: "Create", text: "Edit gamebooks or create your own! Gamebook Engine has "
                + "a fully-featured interface for creating full length choosable path adventure "
                + "games.", image: Image("create-icon")
        ),
        CardData(
            title: "Share", text: "Stories written with Gamebook Engine can be exported to a "
                + "plain text file that you can send to your friends. To play, they "
                + "just need their own copy of Gamebook Engine.", image: Image("share-icon")
        ),
        CardData(
            title: "Play", text: "Gamebook Engine comes "
                + "with a few simple games built in that you can play, but it’s more fun to play "
                + "games made by friends and family. Get creative!", image: Image("play-icon")
        ),
    ]

    var body: some View {
        VStack {
            if UIDevice.current.userInterfaceIdiom == .phone {
                Spacer()
            }
            Spacer()
            HStack {
                Image("icon-ios")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(15)
                    .shadow(radius: 5, x: 2, y: 2)
                    .padding(.trailing, 10)
                Text("Welcome to \nGamebook Engine")
                    .multilineTextAlignment(.leading)
                    .font(.title)
            }
            Text("Gamebook Engine is an all-in-one app for creating "
                + "and playing interactive stories, entirely on your device. "
                + "No sign-up or internet access required.")
                .font(.body)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .frame(maxWidth: 540)
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
                self.dismiss()
            }, label: {
                Text("Get Started Now")
                    .padding()
                    .background(Color(UIColor(named: "containerBackground")!))
                    .foregroundColor(Color(UIColor(named: "text")!))
                    .cornerRadius(100)
            })
            Spacer()
            if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.orientation == .portrait {
                Spacer()
            }
        }
        .background(Color(UIColor(named: "background")!))
        .ignoresSafeArea(.all, edges: .vertical)
        .onAppear {
            UserDatabase.standard.set(true, forKey: .shownIntroductionScreen)
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
