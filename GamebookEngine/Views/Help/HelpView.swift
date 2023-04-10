//
//  HelpView.swift
//  GamebookEngine
//
//  Created by Brad Root on 4/8/23.
//  Copyright © 2023 Brad Root. All rights reserved.
//

import SwiftUI

struct HelpContainer: View {
    @Environment(\.openURL) var openURL

    let title: String
    let content: String
    let url: URL
    let cta: String

    var body: some View {
        VStack {
            Text(title)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fixedSize(horizontal: false, vertical: true)
                .padding(EdgeInsets(top: 22, leading: 22, bottom: 4, trailing: 22))

            Text(content)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
                .padding(EdgeInsets(top: 0, leading: 22, bottom: 8, trailing: 22))

            Button {
                openURL(url)
            } label: {
                Text(cta)
                    .fontWeight(.medium)
                    .foregroundColor(Color("button"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(EdgeInsets(top: 6, leading: 0, bottom: 8, trailing: 0))
                    .background(Color("background"))
                    .cornerRadius(5)
                    .padding(EdgeInsets(top: 0, leading: 22, bottom: 22, trailing: 22))
            }
        }
        .background(Color("containerBackground"))
        .foregroundColor(Color("text"))
        .cornerRadius(10)
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .shadow(color: Color(white: 0, opacity: 0.1), radius: 10)

    }
}

struct HelpView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HelpContainer(title: "Documentation", content: "Need help understanding what a gamebook is, and how Gamebook Engine helps you write them? Check out the Wiki for a deep dive on Gamebook structure.", url: URL(string: "https://github.com/amiantos/gamebookengine/wiki")!, cta: "Go to the Wiki")
                    HelpContainer(title: "Report Bugs", content: "If you find bugs, GitHub Issues is the best place to report them. Gamebook Engine is free open source software. That means the entire source code is available online for you to look at, modify, or use in your own projects.", url: URL(string: "https://github.com/amiantos/gamebookengine/issues")!, cta: "Report Issues on GitHub")

                    HelpContainer(title: "Discord Community", content: "Want to chat with the developer and other Gamebook Engine users? Did you write a great gamebook and want to get opinions on it? Join the Discord community.", url: URL(string: "https://discord.gg/QncPzv4PXc")!, cta: "Join on Discord")

                    HelpContainer(title: "Email Brad", content: "If none of those other options are working out for you, you can always email me directly. My name is Brad. Say hello!", url: URL(string: "mailto:bradroot@me.com?subject=Gamebook%20Engine%20Feedback")!, cta: "Email bradroot@me.com")
                }
            }
            .navigationTitle("Get Help")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
