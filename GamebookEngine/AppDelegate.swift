//
//  AppDelegate.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/15/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var temp: Int?
    var window: UIWindow?
    let navigationController = UINavigationController(rootViewController: GameListTableViewController())

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Import Introduction
        UserDatabase.standard.createIntroGameIfNeeded()

        Log.logLevel = .debug
        Log.useEmoji = true

        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return false }
        window.rootViewController = GameListTableViewController()
        window.makeKeyAndVisible()
        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Log.info("Open URL: \(url)")
        _ = url.startAccessingSecurityScopedResource()
        guard let jsonData = try? Data(contentsOf: url) else { return false }
        url.stopAccessingSecurityScopedResource()
        GameSerializer.standard.gameFromJSONData(jsonData)
        return true
    }

    func applicationWillResignActive(_: UIApplication) {}

    func applicationDidEnterBackground(_: UIApplication) {}

    func applicationWillEnterForeground(_: UIApplication) {}

    func applicationDidBecomeActive(_: UIApplication) {}

    func applicationWillTerminate(_: UIApplication) {}
}
