//
//  SceneDelegate.swift
//  BRGamebookEngine
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: GameListTableViewController())
        window.makeKeyAndVisible()
        self.window = window
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        Log.info("Open URL: \(url)")
        _ = url.startAccessingSecurityScopedResource()
        guard let jsonData = try? Data(contentsOf: url) else { return }
        url.stopAccessingSecurityScopedResource()
        GameSerializer.standard.gameFromJSONData(jsonData)
    }
}
