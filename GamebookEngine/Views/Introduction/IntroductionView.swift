//
//  IntroductionView.swift
//  GamebookEngine
//
//  Created by Brad Root on 4/5/23.
//  Copyright © 2023 Brad Root. All rights reserved.
//

import SwiftUI
import CardStack

struct CardView: View {
    let text: String

    var body: some View {
        VStack {
                Text("Card")
                HStack {
                    Text(self.text)
                  Spacer()
                    Text("\(self.text) km away")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                .padding()
              }
              .background(Color.white)
              .cornerRadius(12)
              .shadow(radius: 4)
            }
    }

struct IntroductionView: View {
    @State var cards: [String] = ["Foo", "Bar", "Foo"]
    
    var body: some View {
        CardStack(
              direction: LeftRight.direction,
              data: cards,
              onSwipe: { text, direction in
                print("Swiped \(text) to \(direction)")
              },
              content: { text, _, _ in
                CardView(text: text)
              }
            )
            .padding()
            .scaledToFit()
            .frame(alignment: .center)
            .navigationBarTitle("Basic", displayMode: .inline)
          }
    }

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
